//
//  InitialDataLoader.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 25/12/23.
//

import Foundation
import CoreData

struct InitialDataLoader {
    static func importInitialDataIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "isJSONImported") else {
            print("JSON data already imported")
            return
        }

        guard let url = Bundle.main.url(forResource: "your_json_file_name", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let jsonData = try Data(contentsOf: url)
            guard let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
                print("Error parsing JSON")
                return
            }

            let context = PersistenceController.shared.container.viewContext
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            for breweryDict in jsonArray {
                // Your logic to create and populate CoreData entities goes here
                // Refer to previous examples for parsing and saving data to CoreData
            }

            try context.save()
            print("Data imported successfully")

            // Update UserDefaults to mark JSON as imported
            UserDefaults.standard.set(true, forKey: "isJSONImported")
        } catch {
            print("Error importing data: \(error.localizedDescription)")
        }
    }
}

