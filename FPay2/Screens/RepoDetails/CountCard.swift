//
//  CountCard.swift
//  FPay2
//
//  Created by Vikranth Kumar on 23/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import SwiftUI

struct CountCard: View {
    
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(self.title)
                .foregroundColor(Color.black)
                .font(.headline)
                .fontWeight(.medium)
            Spacer()
            Text("\(self.count)")
                .foregroundColor(Color.black)
                .font(.headline)
                .fontWeight(.medium)
        }
        .padding(10)
        .background(Color.secondary)
        .cornerRadius(10)
    }
}
