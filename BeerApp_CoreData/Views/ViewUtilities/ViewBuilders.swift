//
//  ViewBuilders.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 12/12/23.
//

import Foundation

// ViewBuilders.swift

import SwiftUI

struct ViewBuilders {
    @ViewBuilder static func dynamicStatusLabel(for statusMessage: String) -> some View {
        if !statusMessage.isEmpty {
            Text(statusMessage)
                .foregroundColor(.red)
        } else {
            EmptyView()
        }
    }

}
