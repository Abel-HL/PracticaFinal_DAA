//
//  ImportedComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 26/1/24.
//

import SwiftUI

struct ImportedComponentView: View {
    
    @Binding var isImported: Bool
    
    var body: some View {
        Button(action: {
            //checkImported()
        }) {
            HStack {
                Text("Imported")
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: isImported ? "checkmark.square.fill" : "square")
                    .foregroundColor(isImported ? .blue : .gray)
            }
        }
    }
}
