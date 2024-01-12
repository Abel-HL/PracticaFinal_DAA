//
//  FavoriteComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct FavoriteComponentView: View {
    
    @Binding var isFavorite: Bool
    @State var field : String
    
    var body: some View {
        Button(action: {
            isFavorite.toggle()
        }) {
            HStack {
                Text("Favorite")
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: isFavorite ? "\(field).fill" : field)
                    .foregroundColor(isFavorite ? (field == "star" ? .yellow : .red) : .gray)
            }
        }
    }
}
