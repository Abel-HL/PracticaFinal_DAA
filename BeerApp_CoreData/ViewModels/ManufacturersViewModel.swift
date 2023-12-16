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
    @Published var deleteBeersList: [UUID] = []
    
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
        getBeers()
    }
    
    //  Beers
    func addBeer(name: String, type: String,
                 alcoholContent: Float,
                 calories: Int16,
                 favorite: Bool,
                 image: UIImage,
                 manufacturer: ManufacturerEntity){
        
        if let compressedImageData = ImageProcessor.compressImage(image) {
            let newBeer = BeerEntity(context: manager.context)
            newBeer.id = UUID()
            newBeer.name = name
            newBeer.alcoholContent = alcoholContent
            newBeer.calories = calories
            newBeer.type = type
            newBeer.imageData = compressedImageData
            newBeer.favorite = favorite
            
            //Asociamos la nueva cerveza al fabricante en cuestión
            newBeer.manufacturer = manufacturer
        }
        
        print("Beer Added")
        save()
        getBeers()
        
    }
    
    #warning("Hay que cambiar este getBeers para que por Defecto se haga el getBeers filtrado por sortCriteria = .Name")
    func getBeers() {
        guard let currentManufacturer = self.manufacturer else {
            print("Manufacturer is nil")
            return
        }

        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        
        // Establecer un predicado para filtrar por el fabricante actual
        let predicate = NSPredicate(format: "manufacturer == %@", currentManufacturer)
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "type", ascending: true) // Ordenar por el atributo 'type'
        fetchRequest.sortDescriptors = [sortDescriptor] // Agregar el descriptor de ordenación a la solicitud de búsqueda
        
        do {
            // Fetch beers based on the specified sort criteria and manufacturer
            self.beers = try manager.container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching beers: \(error.localizedDescription)")
        }
    }
    
    func sortAndFilterBeers(filter searchText: String, sort sortCriteria: SortCriteria){
        self.getBeers()
        guard !searchText.isEmpty else {
            self.filterBeers(by: sortCriteria)
            return
        }
        
        self.filterBeers(by: sortCriteria)
        self.beers = self.beers.filter {$0.name!.localizedCaseInsensitiveContains(searchText)}
        //return filteredBeers
    }
    
    func filterBeers(by criteria: SortCriteria) {
        switch criteria {
        case .name:
            self.beers.sort { $0.name! < $1.name! } // Ordenar por nombre
            print(beers)
        case .calories:
            self.beers.sort { $0.calories < $1.calories } // Ordenar por calorías
            print(beers)
        case .alcoholContent:
            self.beers.sort { $0.alcoholContent < $1.alcoholContent } // Ordenar por contenido de alcohol
            print(beers)
        case .favorites:
            self.beers.sort { $0.favorite && !$1.favorite } // Ordenar por favoritos
            print(beers)
        }
    }
    
    
    func deleteBeer(indexSet: IndexSet){
        indexSet.map { beers[$0]}.forEach(manager.container.viewContext.delete)
        save()
    }
    
    func deleteSelectedBeers() {
        
        for id in self.deleteBeersList {
            let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let beerToDelete = try? manager.container.viewContext.fetch(fetchRequest).first {
                manager.container.viewContext.delete(beerToDelete)
            }
        }
        save()
        getBeers()
    }
    
    func deleteAllBeers(){
        beers.forEach { beer in
            manager.container.viewContext.delete(beer)
        }
        save()
        getBeers()
    }
        
    
#warning("cambiar este getBeers")
    func save(){
        manager.save()
        //getAllManufacturers()
    }
    
    /*
    func filterBeers(for sortCriteria: SortCriteria) {
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
     */
}
