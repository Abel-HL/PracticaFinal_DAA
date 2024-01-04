//
//  SearchBar.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 15/12/23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search Beer", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}
