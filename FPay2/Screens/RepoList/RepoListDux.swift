//
//  RepoListDux.swift
//  FPay2
//
//  Created by Vikranth Kumar on 22/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import Foundation
import SwiftDux
import Combine
import SwiftUI

// MARK:- State
struct RepoListState: StateType {
    
    var searchText: String = ""
    
    var page: Int = 1
    var sort: String = ""
    var order: String = ""
    
    var showCancelSearch: Bool = false
    
    var isSearching: Bool = false
    var showSearchError: Bool = false
    var searchErrorMessage: String = ""
    
    var isPaginating: Bool = false
    var showPaginationError: Bool = false
    var paginationErrorMessage: String = ""
    
    var repoList: RepoList = RepoList()
}

struct RepoList: Parsable {
    var totalCount: Int = 0
    var repos: [Repo] = []
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case repos = "items"
    }
}

struct Repo: IdParsable {
    var id: Int
    var name: String
    var fullName: String
    var starsCount: Int
    var forksCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case starsCount = "stargazers_count"
        case forksCount = "forks_count"
        
    }
}

// MARK:- Action
enum RepoListAction: Action {
    
    // AnyCancellable
    static var cancellable = Set<AnyCancellable>()
    
    // Sort
    case clearForSort
    case sort(type: String)
    case order(type: String)
    
    // Search
    case updateSearch(text: String)
    case cancelSearch
    
    case startSearch
    case stopSearch
    case showSearchError(message: String)
    case hideSearchError
    
    case setRepoList(repoList: RepoList)
    
    // Pagination
    case pagination
    
    case startPagination
    case stopPagination
    case showPaginationError(message: String)
    case hidePaginationError
    
    case updateRepoList(repoList: RepoList)
        
    // Action Plans
    static func search() -> ActionPlan<AppState> {
        ActionPlan<AppState> { store in
            store.didChange
                .map { _ in store.state.repoListState.searchText }
                .filter{!$0.isEmpty}
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .flatMap { searchText in
                    return Future { promise in
                        RepoListAction.cancellable.removeAll()
                        let repoListState = store.state.repoListState
                        store.send(repoListState.page == 1 ? RepoListAction.startSearch : RepoListAction.startPagination)
                        APIService().response(from: SearchRepoRequest(query: searchText, sort: repoListState.sort, order: repoListState.order, page: repoListState.page))
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    store.send(repoListState.page == 1 ? RepoListAction.hideSearchError : RepoListAction.hidePaginationError)
                                case .failure(let error):
                                    if repoListState.page == 1 {
                                        store.send(RepoListAction.showSearchError(message: error.localizedDescription))
                                        promise(.success(RepoListAction.setRepoList(repoList: RepoList())))
                                    } else {
                                        store.send(RepoListAction.showPaginationError(message: error.localizedDescription))
                                        promise(.success(RepoListAction.updateRepoList(repoList: RepoList())))
                                    }
                                }
                                store.send(repoListState.page == 1 ? RepoListAction.stopSearch : RepoListAction.stopPagination)
                            }, receiveValue: { repoList in
                                if repoListState.page == 1 {
                                    promise(.success(RepoListAction.setRepoList(repoList: repoList)))
                                } else {
                                    promise(.success(RepoListAction.updateRepoList(repoList: repoList)))
                                }
                            })
                            .store(in: &RepoListAction.cancellable)
                    }
                    
            }
        }
    }
    
    static func paginate() -> ActionPlan<AppState> {
        ActionPlan<AppState> { store in
            store.send(RepoListAction.pagination)
            store.send(RepoListAction.search())
        }
    }
    
    static func sort(type: RepoListSort) -> ActionPlan<AppState> {
        ActionPlan<AppState> { store in
        store.send(RepoListAction.clearForSort)
            switch type {
            case .starsHL:
            store.send(RepoListAction.sort(type: "stars"))
                store.send(RepoListAction.order(type: "desc"))
            case .starsLH:
                store.send(RepoListAction.sort(type: "stars"))
                store.send(RepoListAction.order(type: "asc"))
            case .forksHL:
                store.send(RepoListAction.sort(type: "forks"))
                store.send(RepoListAction.order(type: "desc"))
            case .forksLH:
                store.send(RepoListAction.sort(type: "forks"))
                store.send(RepoListAction.order(type: "asc"))
            }
            store.send(RepoListAction.search())
        }
    }
}

// MARK:- Reducer
final class RepoListReducer: Reducer {
    
    func reduce(state: RepoListState, action: RepoListAction) -> RepoListState {
        var state = state
        switch action {
        // Sort
        case .clearForSort:
           state.page = 1
        case .sort(let sortType):
            state.sort =  sortType
        case .order(let orderType):
            state.order =  orderType
            
        // Search
        case .updateSearch(let text):
            state.page = 1
            state.searchText = text
            state.showCancelSearch = !text.isEmpty
            if text.isEmpty {
                RepoListAction.cancellable.removeAll()
                state.repoList = RepoList()
            }
        case .cancelSearch:
            state.page = 1
            state.searchText = ""
            state.showCancelSearch = false
            RepoListAction.cancellable.removeAll()
            state.repoList = RepoList()
        case .startSearch:
            state.isSearching = true
        case .stopSearch:
            state.isSearching = false
        case .showSearchError(let message):
            state.showSearchError = true
            state.searchErrorMessage = message
        case .hideSearchError:
            state.showSearchError = false
            state.searchErrorMessage = ""
            
        case .setRepoList(let repoList):
            state.repoList = repoList
            
        // Pagination
        case .pagination:
            state.page += 1
            
        case .startPagination:
            state.isPaginating = true
        case .stopPagination:
            state.isPaginating = false
        case .showPaginationError(let message):
            state.showPaginationError = true
            state.paginationErrorMessage = message
        case .hidePaginationError:
            state.showPaginationError = false
            state.paginationErrorMessage = ""
            
        case .updateRepoList(let repoList):
            state.repoList.repos.append(contentsOf: repoList.repos)
        }
        return state
    }
    
}
