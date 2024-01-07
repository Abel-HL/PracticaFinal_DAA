//
//  AlcoholComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct AlcoholComponentView: View {
    @Binding var alcoholContent: String
    @Binding var alcoholContentTextColor: Color

    var body: some View {
        HStack {
            Text("Alcohol Content:")
            Spacer()
            TextField("0-100", text: alcoholContentBinding(alcoholContent: $alcoholContent, textColor: $alcoholContentTextColor), onEditingChanged: { _ in }, onCommit: {
            })
            .keyboardType(.decimalPad)
            .frame(maxWidth: 80)
            .multilineTextAlignment(.trailing)
            .onChange(of: alcoholContent) { newValue in
                if !Validators.validateAlcoholDecimal(newValue) {
                    alcoholContent = ""
                }
            }
            Text("%").foregroundColor($alcoholContentTextColor.wrappedValue)
        }
    }
}
