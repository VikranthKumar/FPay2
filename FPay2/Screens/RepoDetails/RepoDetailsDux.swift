//
//  RepoDetailsDux.swift
//  FPay2
//
//  Created by Vikranth Kumar on 23/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import Foundation
import SwiftDux
import Combine
import SwiftUI

// MARK:- State
struct RepoDetailsState: StateType {
        
    var isSearching: Bool = false
    var showSearchError: Bool = false
    var searchErrorMessage: String = ""
    
    var repoDetails: RepoDetails = RepoDetails()
}

struct RepoDetails: Parsable {
    var name: String = ""
    var description: String = ""
    var starsCount: Int = 0
    var watchersCount: Int = 0
    var forksCount: Int = 0
    var owner: Owner = Owner()
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case starsCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case owner 
        
    }
}

struct Owner: Parsable {
    var name: String = ""
    var avatar: String = ""
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case avatar = "avatar_url"
    }
}

// MARK:- Action
enum RepoDetailsAction: Action {
    
    // AnyCancellable
    static var cancellable = Set<AnyCancellable>()
    
    // Search
    case startSearch
    case stopSearch
    case showSearchError(message: String)
    case hideSearchError
    
    case setRepoDetails(repoDetails: RepoDetails)
        
    // Action Plans
    static func search(pathEnd: String) -> ActionPlan<AppState> {
        ActionPlan<AppState> { store in
            RepoDetailsAction.cancellable.removeAll()
            store.send(RepoDetailsAction.startSearch)
            APIService().response(from: RepoDetailsRequest(pathEnd: pathEnd))
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        store.send(RepoDetailsAction.hideSearchError)
                    case .failure(let error):
                        store.send(RepoDetailsAction.showSearchError(message: error.localizedDescription))
                        store.send(RepoDetailsAction.setRepoDetails(repoDetails: RepoDetails()))
                    }
                    store.send(RepoDetailsAction.stopSearch)
                }, receiveValue: { repoDetails in
                    store.send(RepoDetailsAction.setRepoDetails(repoDetails: repoDetails))
                })
                .store(in: &RepoDetailsAction.cancellable)
        }
    }
    
}

// MARK:- Reducer
final class RepoDetailsReducer: Reducer {
    
    func reduce(state: RepoDetailsState, action: RepoDetailsAction) -> RepoDetailsState {
        var state = state
        switch action {
        // Search
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
            
        case .setRepoDetails(let repoDetails):
            state.repoDetails = repoDetails
        }
        return state
    }
    
}
