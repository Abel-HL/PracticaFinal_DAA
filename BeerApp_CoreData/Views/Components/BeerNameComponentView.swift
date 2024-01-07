//
//  beerNameComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct BeerNameComponentView: View {
    
    @Binding var beerName: String
    
    var body: some View {
        HStack {
            Text("Name:")
            //Spacer()
            TextField("Beer Name", text: $beerName)
                //.frame(maxWidth: .infinity)
                .multilineTextAlignment(.trailing)
            
            if Validators.validateName(beerName).valid {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            }
        }
        /*
        .onChange(of: beerName) { _ in
            //checkNewBeerFields()
        }
         */
    }
}

