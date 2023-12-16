//
//  FieldBindings.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 16/12/23.
//

import Foundation
import SwiftUI

func alcoholContentBinding(alcoholContent: Binding<String>, textColor: Binding<Color>) -> Binding<String> {
    return Binding(
        get: {
            if !alcoholContent.wrappedValue.isEmpty {
                return alcoholContent.wrappedValue
            } else {
                return ""
            }
        },
        set: { newValue in
            let validation = Validators.validateAlcoholContent(newValue)
            alcoholContent.wrappedValue = validation.value
            textColor.wrappedValue = validation.color
        }
    )
}

func caloriesBinding(calories: Binding<String>, textColor: Binding<Color>) -> Binding<String> {
    return Binding(
        get: {
            if let caloriesValue = Int(calories.wrappedValue), caloriesValue >= 0 {
                return String(caloriesValue)
            } else {
                return "" // O cualquier valor por defecto o manejo de errores
            }
        },
        set: { newValue in
            let validation = Validators.validateCalories(newValue)
            calories.wrappedValue = validation.value
            textColor.wrappedValue = validation.color
        }
    )
}

// Define similar functions for name if needed...
