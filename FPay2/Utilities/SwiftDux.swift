//
//  SwiftDux.swift
//  FPay2
//
//  Created by Vikranth Kumar on 21/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import SwiftDux
import Combine
import Foundation


// MARK:- Store Configuration
func configureStore() -> Store<AppState> {
    Store(state: AppState(), reducer: AppReducer())
}

// MARK:- State
struct AppState: StateType {
    var repoListState: RepoListState = RepoListState()
    var repoDetailsState: RepoDetailsState = RepoDetailsState()
}

// MARK:- Reducer
final class AppReducer: Reducer {
    
    let repoListReducer = RepoListReducer()
    let repoDetailsReducer = RepoDetailsReducer()
    
    func reduce(state: AppState, action: Action) -> AppState {
        reduceNext(state: state, action: action)
    }
    
    func reduceNext(state: AppState, action: Action) -> AppState {
        return State(
            repoListState: repoListReducer.reduceAny(state: state.repoListState, action: action),
            repoDetailsState: repoDetailsReducer.reduceAny(state: state.repoDetailsState, action: action)
        )
    }
    
}
