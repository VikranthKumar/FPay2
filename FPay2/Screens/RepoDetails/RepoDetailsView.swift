//
//  RepoDetailsView.swift
//  FPay2
//
//  Created by Vikranth Kumar on 23/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import SwiftUI
import SwiftDux

struct RepoDetailsView: ConnectableView {
    
    let pathEnd: String
    
    @MappedDispatch() private var dispatch
    
    func map(state: AppState) -> RepoDetailsState? {
        state.repoDetailsState
    }
    
    func body(props: RepoDetailsState) -> some View {
        VStack {
            if props.isSearching {
                ActivityIndicator()
                    .fullHeight(alignment: .center)
            } else if props.showSearchError {
                Refresh(callback: {
                    self.dispatch(RepoDetailsAction.search(pathEnd: self.pathEnd))
                }, message: props.searchErrorMessage)
                    .fullHeight(alignment: .center)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(props.repoDetails.description)
                            .font(.subheadline).italic()
                            .multilineTextAlignment(.leading)
                        CountCard(title: "Stars", count: props.repoDetails.starsCount)
                        CountCard(title: "Forks", count: props.repoDetails.forksCount)
                        CountCard(title: "Watched", count: props.repoDetails.watchersCount)
                        Text("Created By:")
                            .font(.title)
                            .fontWeight(.bold)
                        HStack {
                            URLImage(url: props.repoDetails.owner.avatar)
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                                .padding(10)
                            Text(props.repoDetails.owner.name)
                                .foregroundColor(Color.black)
                                .font(.headline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .background(Color.secondary)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .navigationBarTitle(Text(props.repoDetails.name))
        .onAppear(dispatch: RepoDetailsAction.search(pathEnd: pathEnd))
    }
    
}
