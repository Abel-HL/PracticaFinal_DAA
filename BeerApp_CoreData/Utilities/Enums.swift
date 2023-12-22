//
//  Enums.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//

import Foundation

enum SortCriteria: String, CaseIterable {
    case name = "Name"
    case calories = "Calories"
    case alcoholContent = "Alcohol %"
    case favorites = "Favorites"
}

enum BeerTypes: String, CaseIterable {
    case lager = "Lager"
    case pilsen = "Pilsen"
    case stout = "Stout"
    case ale = "Ale"
    case ipa = "India Pale Ale"
    case wheat = "Wheat Beer"
    case porter = "Porter"
    case sour = "Sour Beer"
    case bock = "Bock Beer"
}



enum CountryInfo: CaseIterable {
    case China
    case India
    case UnitedStates
    case Indonesia
    case Pakistan
    case Brazil
    case Nigeria
    case Spain
    case France
    case Poland
    
    var name: String {
        switch self {
        case .China: return "China"
        case .India: return "India"
        case .UnitedStates: return "United States"
        case .Indonesia: return "Indonesia"
        case .Pakistan: return "Pakistan"
        case .Brazil: return "Brazil"
        case .Nigeria: return "Nigeria"
        case .Spain: return "Spain"
        case .France: return "France"
        case .Poland: return "Poland"
        }
    }
    
    var code: String {
        switch self {
        case .China: return "CN"
        case .India: return "IN"
        case .UnitedStates: return "US"
        case .Indonesia: return "ID"
        case .Pakistan: return "PK"
        case .Brazil: return "BR"
        case .Nigeria: return "NG"
        case .Spain: return "ES"
        case .France: return "FR"
        case .Poland: return "PL"
        }
    }
    
    var flag: String {
        switch self {
        case .China: return "🇨🇳"
        case .India: return "🇮🇳"
        case .UnitedStates: return "🇺🇸"
        case .Indonesia: return "🇮🇩"
        case .Pakistan: return "🇵🇰"
        case .Brazil: return "🇧🇷"
        case .Nigeria: return "🇳🇬"
        case .Spain: return "🇪🇸"
        case .France: return "🇫🇷"
        case .Poland: return "🇵🇱"
        }
    }
}

