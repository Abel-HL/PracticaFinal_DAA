//
//  BeerTypePickerComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct BeerTypePickerComponentView: View {
    @Binding var selectedBeerType: BeerTypes
    
    var body: some View {
        HStack {
            Picker(selection: $selectedBeerType, label: Text("Beer Type")) {
                ForEach(BeerTypes.allCases, id: \.self) { beerType in
                    Text(beerType.rawValue).tag(beerType)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}
