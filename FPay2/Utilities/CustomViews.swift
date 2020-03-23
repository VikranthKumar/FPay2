//
//  CustomViews.swift
//  FPay2
//
//  Created by Vikranth Kumar on 22/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import UIKit
import SwiftUI
import KingfisherSwiftUI

// MARK:- Activity Indicator
struct ActivityIndicator: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .medium)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}

// MARK:- Refresh View
struct Refresh: View {
    
    let callback: (() -> Void)
    let message: String
    var isForRow = false
    
    var body: some View {
        VStack(spacing: 15.0) {
            Button(action: {
                self.callback()
            }) {
                Image("refresh")
                    .renderingMode(.template)
                    .accentColor(Color.primary)
            }
            Text(message)
                .font(self.isForRow ? .caption : .body)
                .fontWeight(self.isForRow ? .regular : .semibold)
                .multilineTextAlignment(.center)
        }
    }
    
}

// MARK:- URLImage
struct URLImage: View {
    let url: String
    
    var body: some View {
        if let urlFormat = URL(string: self.url) {
            return AnyView(
                KFImage(urlFormat)
                    .resizable()
                    .scaledToFill()
                    .background(Color.primary)
            )
        } else {
            return AnyView(
                Text("placeholder")
            )
        }
    }
    
}
