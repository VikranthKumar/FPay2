//
//  ViewModifiers.swift
//  FPay2
//
//  Created by Vikranth Kumar on 22/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import SwiftUI

extension View {
    
    func fullWidth(alignment: Alignment) -> some View {
        self
            .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }
    
    func fullHeight(alignment: Alignment) -> some View {
        self
            .frame(minHeight: 0, maxHeight: .infinity, alignment: alignment)
    }
    
}
