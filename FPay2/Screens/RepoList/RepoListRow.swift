//
//  RepoListRow.swift
//  FPay2
//
//  Created by Vikranth Kumar on 23/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import SwiftUI

struct RepoListRow: View {
    
    let repo: Repo
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.repo.name)
            HStack(alignment: .center) {
                Text("Stars: \(self.repo.starsCount), Forks: \(self.repo.forksCount)")
                    .font(.caption).italic()
                    .foregroundColor(.secondary)
            }
        }
    }
}
