//
//  InitialDataLoader.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 25/12/23.
//
import Foundation
import CoreData
import UIKit

class DataLoader {
    static let initialDataLoadedKey = "InitialDataLoaded"

    static func loadInitialDataIfNeeded() {
        let isInitialDataLoaded = UserDefaults.standard.bool(forKey: initialDataLoadedKey)

        guard !isInitialDataLoaded else {
            // Los datos ya han sido cargados, no es necesario cargarlos de nuevo
            return
        }

        // Lógica para cargar datos iniciales
        loadInitialData()

        // Marcar que los datos iniciales han sido cargados
        UserDefaults.standard.set(true, forKey: initialDataLoadedKey)
    }

    private static func loadInitialData() {
        let viewModel = ManufacturersViewModel.shared
        
        let beerData: [(manufacturerName: String, manufacturerCountryCode: String, beerName: String, beerType: String, beerAlcoholContent: Float, beerCalories: Int16, beerFavorite: Bool, manufacturerFavorite: Bool, manufacturerImageName: String, beerImageName: String)] = [
            ("Prueba 1", "ES", "Lager 5.0 50", "Lager", 5.0, 50, false, true, "Logos/MahouLogo", "Photos/MahouCan"),
            ("Prueba 2", "ES", "Lager 3.0 70", "Lager", 3.0, 70, false, false, "Logos/MahouLogo2", "Photos/MahouBottle"),
            ("Prueba 3", "NL", "Lager 5.0 50", "Lager", 5.0, 50, false, false, "Imported/Logos/HeinekenLogo", "Imported/Photos/HeinekenCan"),
            ("Prueba 4", "NL", "Lager 5.0 50", "Lager", 5.0, 50, false, true, "Imported/Logos/HeinekenLogo2", "Imported/Photos/HeinekenBottle")
        ]
        
        let beerTypes: [(name: String, type: String, alcoholContent: Float, calories: Int16, favorite: Bool)] = [
            ("Pilsen 4.0 150", "Pilsen", 4.0, 150, false),
            ("Pilsen 6.5 120", "Pilsen", 6.5, 120, true)
        ]
        
        for data in beerData {
            viewModel.addManufacturerAndBeerForInitialData(
                name: data.manufacturerName,
                manufacturerCountryCode: data.manufacturerCountryCode,
                beerName: data.beerName,
                beerType: data.beerType,
                beerAlcoholContent: data.beerAlcoholContent,
                beerCalories: data.beerCalories,
                beerFavorite: data.beerFavorite,
                manufacturerFavorite: data.manufacturerFavorite,
                manufacturerImage: UIImage(named: "\(data.manufacturerImageName)")!,
                beerImage: UIImage(named: "\(data.beerImageName)") ?? UIImage(systemName: "xmark.circle.fill")!
            )
            
            for beerType in beerTypes {
                viewModel.addBeer(
                    name: beerType.name,
                    type: beerType.type,
                    alcoholContent: beerType.alcoholContent,
                    calories: beerType.calories,
                    favorite: beerType.favorite,
                    image: UIImage(named: "\(data.beerImageName)") ?? UIImage(systemName: "xmark.circle.fill")!,
                    manufacturer: viewModel.manufacturer!
                )
            }
        }
        
        // Guarda los cambios
        PersistenceController.shared.save()
    }
}

