//
//  Validators.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 16/12/23.
//

import Foundation
import SwiftUI

struct Validators {
    static func validateAlcoholDecimal(_ newValue: String) -> Bool {
        let decimalRegex = #"^(100(\.00?)?|(\d{1,2}(\.\d{0,2})?))?$"#
        let range = NSRange(location: 0, length: newValue.utf16.count)
        let regex = try! NSRegularExpression(pattern: decimalRegex, options: .caseInsensitive)
        let matches = regex.matches(in: newValue, options: [], range: range)
        return !matches.isEmpty
    }
    
    static func validateAlcoholContent(_ input: String) -> (valid: Bool, value: String, color: Color) {
        if let value = Float(input), value >= 0.0, value <= 100.0 {
            return (true, input, .green)
        } else {
            return (false, input, .red)
        }
    }
    
    
    static func validateCaloriesTextField(_ newValue: String) -> Bool {
        let decimalRegex = #"^(500|[1-4]?\d{0,2}|0)?$"#
        let range = NSRange(location: 0, length: newValue.utf16.count)
        let regex = try! NSRegularExpression(pattern: decimalRegex, options: .caseInsensitive)
        let matches = regex.matches(in: newValue, options: [], range: range)
        return !matches.isEmpty
    }
    
    static func validateCalories(_ input: String) -> (valid: Bool, value: String, color: Color) {
        if let value = Int16(input), value >= 0, value <= 500 {
            return (true, input, .green)
        } else {
            return (false, input, .red)
        }
    }
    
    static func validateName(_ input: String) -> (valid: Bool, value: String, color: Color) {
        if (4...24).contains(input.count) {
            return (true, input, .green)
        } else {
            return (false, input, .red)
        }
    }
    
    static func validateInput(alcoholContent: String, calories: String, beerName: String) -> Bool {
        let isAlcoholContentValid = (0.0...100.0).contains(Float(alcoholContent) ?? -1)
        let areCaloriesValid = (0...500).contains(Int(calories) ?? -1)
        let isBeerNameValidLength = (4...24).contains(beerName.count)
        
        return isAlcoholContentValid &&
        areCaloriesValid && isBeerNameValidLength
    }
}
