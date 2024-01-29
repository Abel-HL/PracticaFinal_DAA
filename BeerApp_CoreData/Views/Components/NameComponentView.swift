//
//  NameComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct NameComponentView: View {
    
    @Binding var varName: String
    @State var field: String
    
    var body: some View {
        HStack {
            Text("Name:")
            //Spacer()
            //#warning("Hacer este campo personalizable. Que el textField pueda poner Beer o Manufacturer Name")
            TextField("\(field) Name", text: $varName)
                //.frame(maxWidth: .infinity)
                .multilineTextAlignment(.trailing)
            
            if Validators.validateName(varName).valid {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            }
        }
        /*
        .onChange(of: varName) { _ in
            //checkNewBeerFields()
        }
         */
    }
}

