//
//  RepoListView.swift
//  FPay2
//
//  Created by Vikranth Kumar on 21/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import SwiftUI
import SwiftDux

struct RepoListView: ConnectableView {
    
    @State var isFirstAppreance = true
    
    struct Props: Equatable {
        @Binding var search: String
        var repoListState: RepoListState
    }
    
    @State private var showActionSheet: Bool = false
    @MappedDispatch() private var dispatch
    
    
    func map(state: AppState, binder: StateBinder) -> Props? {
        Props(
            search: binder.bind(state.repoListState.searchText) {
                RepoListAction.updateSearch(text: $0)
            },
            repoListState: state.repoListState
        )
    }
    
    
    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                HStack {
                    if props.repoListState.isSearching {
                        ActivityIndicator()
                            .frame(width: 25.0)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .frame(width: 25)
                    }
                    TextField("Search", text: props.$search)
                        .accentColor(Color.primary)
                    if props.repoListState.showCancelSearch {
                        Button(action: {
                            self.dispatch(RepoListAction.cancelSearch)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .frame(width: 25)
                        }
                    }
                    if !props.repoListState.repoList.repos.isEmpty {
                        Button(action: {
                            self.showActionSheet.toggle()
                        }) {
                            Image("sort")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.secondary)
                                .frame(width: 25)
                        }
                    }
                }
                .padding()
                Divider()
                if props.repoListState.showSearchError {
                    Refresh(callback: {
                        self.dispatch(RepoListAction.search())
                    }, message: props.repoListState.searchErrorMessage)
                        .fullHeight(alignment: .center)
                } else {
                    List {
                        ForEach(props.repoListState.repoList.repos) { repo in
                            NavigationLink(destination: RepoDetailsView(pathEnd: repo.fullName)) {
                                RepoListRow(repo: repo)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        if props.repoListState.showPaginationError {
                            Refresh(callback: {
                                self.dispatch(RepoListAction.search())
                            }, message: props.repoListState.paginationErrorMessage, isForRow: true)
                                .fullWidth(alignment: .center)
                        } else if props.repoListState.repoList.repos.count < props.repoListState.repoList.totalCount {
                            ActivityIndicator()
                                .fullWidth(alignment: .center)
                                .onAppear(dispatch: RepoListAction.paginate())
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Repositories"))
            .onAppear(perform: {
                if self.isFirstAppreance {
                self.dispatch(RepoListAction.search())
                }
                self.isFirstAppreance = false
            })
            .actionSheet(isPresented: self.$showActionSheet) {
                ActionSheet(title: Text("Sort"), buttons: [
                    .default(Text("Stars: High to Low")) {self.dispatch(RepoListAction.sort(type: .starsHL))},
                    .default(Text("Stars: Low to High")) {self.dispatch(RepoListAction.sort(type: .starsLH))},
                    .default(Text("Forks: High to Low")) {self.dispatch(RepoListAction.sort(type: .forksHL))},
                    .default(Text("Forks: Low to High")) {self.dispatch(RepoListAction.sort(type: .forksLH))},
                    .cancel()
                ])
            }
        }
    }
    
}


