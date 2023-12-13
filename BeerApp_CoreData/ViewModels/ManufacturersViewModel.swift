//
//  ManufacturersViewModel.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//
import Foundation
import CoreData
import UIKit


class ManufacturersViewModel: ObservableObject{
    
    let manager = PersistenceController.shared
    @Published var manufacturers: [ManufacturerEntity] = []
    @Published var beers: [BeerEntity] = []
    
    init() {
        getNationalManufacturers()
    }
    
    //  Manufacturers
    
    func getAllManufacturers(){
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        
        do {
            manufacturers = try manager.context.fetch(request)
            print(manufacturers)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    func selectedManufacturers(selectedList: String){
        if selectedList == "Nacionales"{
            getNationalManufacturers()
            return
        }
        
        getImportedManufacturers()
        return
    }
    
    func getNationalManufacturers() {
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        
        // Agregar un predicado para filtrar por countryCode "ES"
        let predicate = NSPredicate(format: "countryCode == %@", "ES")
        request.predicate = predicate
        
        do {
            manufacturers = try manager.context.fetch(request)
            //print(manufacturers)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    func getImportedManufacturers(){
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        
        // Agregar un predicado para filtrar por countryCode "ES"
        let predicate = NSPredicate(format: "countryCode != %@", "ES")
        request.predicate = predicate
        
        do {
            manufacturers = try manager.context.fetch(request)
            //print(manufacturers)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    func addManufacturer(name: String, countryCode: String, image: UIImage, selectedList: String){
        if let compressedImageData = ImageProcessor.compressImage(image) {
            let newManufacturer = ManufacturerEntity(context: manager.context)
            newManufacturer.id = UUID()
            newManufacturer.name = name
            newManufacturer.countryCode = countryCode
            newManufacturer.imageData = compressedImageData // Asigna la imagen comprimida al atributo imageData de la entidad
            newManufacturer.beers = []  //  Ya que inicialmente no tenemos cervezas asociadas
        }
        print("Añadido")
        selectedManufacturers(selectedList: selectedList)
        save()
    }
    
    func deleteManufacturer(indexSet: IndexSet){
        indexSet.map { manufacturers[$0]}.forEach(manager.container.viewContext.delete)
        save()
    }
    
    func deleteAllManufacturers(selectedList: String){
        manufacturers.forEach { manufacturer in
            manager.container.viewContext.delete(manufacturer)
        }
        selectedManufacturers(selectedList: selectedList)
        save()
    }
    
    
    
    //  Beers
    func addBeer(name: String, type: String,
                 alcoholContent: Float,
                 calories: Int16,
                 favorite: Bool,
                 image: UIImage){
        //if let compressedImageData = ImageProcessor.compressImage(image) {
        let newBeer = BeerEntity(context: manager.context)
        newBeer.id = UUID()
        newBeer.name = name
        newBeer.alcoholContent = alcoholContent
        newBeer.calories = calories
        newBeer.type = type
        //newBeer.imageData = compressedImageData
        newBeer.favorite = favorite
        //}
        
        print("Beer Added")
        //selectedManufacturers(selectedList: selectedList)
        save()
        getBeers()
    }
    
    
    func getBeers(){
        let request = NSFetchRequest<BeerEntity>(entityName: "BeerEntity")
        
        do {
            beers = try manager.context.fetch(request)
            print(beers)
        } catch let error {
            print("Error getting Beers -> fetch error: \(error)")
        }
    }
    
    func deleteBeer(indexSet: IndexSet){
        indexSet.map { beers[$0]}.forEach(manager.container.viewContext.delete)
        getBeers()
        save()
    }
    
    func deleteAllBeers(){
        beers.forEach { beer in
            manager.container.viewContext.delete(beer)
        }
        getBeers()
        save()
    }
    
    
    
    func save(){
        manager.save()
        //getAllManufacturers()
    }
}
