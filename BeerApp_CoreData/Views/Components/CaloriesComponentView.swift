//
//  CaloriesComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 7/1/24.
//

import SwiftUI

struct CaloriesComponentView: View {
    @Binding var calories: String
    @Binding var caloriesTextColor: Color
    
    var body: some View {
        HStack {
            Text("Calories:")
            Spacer()
            TextField("0-500", text: caloriesBinding(calories: $calories, textColor: $caloriesTextColor))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: calories) { newValue in
                    if !Validators.validateCaloriesTextField(newValue) {
                        calories = ""
                    }
                }
            Text("kcal").foregroundColor($caloriesTextColor.wrappedValue)
        }
    }
}

