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
    static let shared = ManufacturersViewModel()    //Singleton
    
    let manager = PersistenceController.shared
    
    @Published var manufacturers: [ManufacturerEntity] = []
    @Published var selectedList: String = "Nacionales"
    @Published var manufacturer: ManufacturerEntity?
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
    
    func selectedManufacturers(){
        if self.selectedList == "Nacionales"{
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
    
    func addManufacturer(name: String, countryCode: String, image: UIImage){
        if let compressedImageData = ImageProcessor.compressImage(image) {
            let newManufacturer = ManufacturerEntity(context: manager.context)
            newManufacturer.id = UUID()
            newManufacturer.name = name
            newManufacturer.countryCode = countryCode
            newManufacturer.imageData = compressedImageData // Asigna la imagen comprimida al atributo imageData de la entidad
            newManufacturer.beers = []  //  Ya que inicialmente no tenemos cervezas asociadas
        }
        print("Añadido")
        selectedManufacturers()
        save()
    }
    
    func deleteManufacturer(indexSet: IndexSet){
        indexSet.map { manufacturers[$0]}.forEach(manager.container.viewContext.delete)
        selectedManufacturers()
        save()
    }
    
    func deleteAllManufacturers(){
        manufacturers.forEach { manufacturer in
            manager.container.viewContext.delete(manufacturer)
        }
        selectedManufacturers()
        save()
    }
    
    // Manufacturer
    func setManufacturer(for manufacturer: ManufacturerEntity){
        self.manufacturer = manufacturer
        getBeers(for: SortCriteria.name)
    }
    
    //  Beers
    func addBeer(name: String, type: String,
                 alcoholContent: Float,
                 calories: Int16,
                 favorite: Bool,
                 image: UIImage,
                 manufacturer: ManufacturerEntity){
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
        
        //Asociamos la nueva cerveza al fabricante en cuestión
        newBeer.manufacturer = manufacturer
        
        print("Beer Added")
        //selectedManufacturers()
        save()
    }
    
    #warning("Hay que cambiar este getBeers para que por Defecto se haga el getBeers filtrado por sortCriteria = .Name")
    func getBeers(for sortCriteria: SortCriteria) {
        guard let currentManufacturer = self.manufacturer else {
            print("Manufacturer is nil")
            return
        }

        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        
        // Establecer un predicado para filtrar por el fabricante actual
        let predicate = NSPredicate(format: "manufacturer == %@", currentManufacturer)
        fetchRequest.predicate = predicate
        
        var sortDescriptor: NSSortDescriptor
        
        switch sortCriteria {
        case .name:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        case .calories:
            sortDescriptor = NSSortDescriptor(key: "calories", ascending: true)
        case .alcoholContent:
            sortDescriptor = NSSortDescriptor(key: "alcoholContent", ascending: true)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            // Fetch beers based on the specified sort criteria and manufacturer
            self.beers = try manager.container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching beers: \(error.localizedDescription)")
        }
    }
    
    func deleteBeer(indexSet: IndexSet){
        indexSet.map { beers[$0]}.forEach(manager.container.viewContext.delete)
        save()
    }
    
    func deleteAllBeers(){
        beers.forEach { beer in
            manager.container.viewContext.delete(beer)
        }
        save()
    }
        
    
#warning("cambiar este getBeers")
    func save(){
        manager.save()
        getBeers(for: SortCriteria.name)
        //getAllManufacturers()
    }
}
