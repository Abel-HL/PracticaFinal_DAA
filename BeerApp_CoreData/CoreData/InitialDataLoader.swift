//
//  InitialDataLoader.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 25/12/23.
//
import Foundation
import CoreData

/*
extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

struct InitialDataLoader {
    static func importInitialDataIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "isJSONImported") else {
            print("JSON data already imported")
            return
        }
        
        guard let url = Bundle.main.url(forResource: "initialData", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let context = PersistenceController.shared.container.viewContext
            jsonDecoder.userInfo[.context!] = context
            let breweryArray = try jsonDecoder.decode([Brewery].self, from: jsonData)
            
            for brewery in breweryArray {
                let manufacturer = ManufacturerEntity(context: context)
                manufacturer.id = UUID()
                manufacturer.name = brewery.name
                manufacturer.countryCode = brewery.countryCode
                
                if let breweryImageData = brewery.imageData {
                    manufacturer.imageData = breweryImageData.data(using: .utf8)
                }
                
                for beerType in brewery.beerTypes {
                    let beer = BeerEntity(context: context)
                    beer.id = UUID()
                    beer.name = beerType.name
                    beer.type = beerType.type
                    beer.alcoholContent = beerType.alcoholContent
                    beer.calories = beerType.calories
                    
                    if let beerImageData = beerType.imageData {
                        beer.imageData = beerImageData.data(using: .utf8)
                    }
                    
                    beer.manufacturer = manufacturer
                }
            }
            
            try context.save()
            print("Data imported successfully")
            
            UserDefaults.standard.set(true, forKey: "isJSONImported")
        } catch {
            print("Error importing data: \(error.localizedDescription)")
        }
    }
}

struct Brewery: Codable {
    let name: String
    let countryCode: String
    let beerTypes: [BeerType]
    let imageData: String?
}

struct BeerType: Codable {
    let name: String
    let type: String
    let alcoholContent: Float
    let calories: Int16
    let imageData: String?
}
*/
