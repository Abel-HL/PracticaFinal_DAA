//
//  FavoriteComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct FavoriteComponentView: View {
    
    @Binding var isFavorite: Bool
    
    var body: some View {
        Button(action: {
            isFavorite.toggle()
        }) {
            HStack {
                Text("Favorite")
                    .foregroundColor(isFavorite ? .red : .black)
                Spacer()
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
        }
    }
}
