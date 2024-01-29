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
    @Published var manufacturer: ManufacturerEntity?
    
    @Published var selectedList: String = "Nationals"
    @Published var beerTypes : [String] = []
    
    @Published var beers: [BeerEntity] = []
    @Published var beer: BeerEntity?
    @Published var deleteBeersList: [UUID] = []
    
    init() {
        getNationalManufacturers()
    }
    
    
    //  Manufacturers
    func getAllManufacturers(){
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        
        do {
            manufacturers = try manager.context.fetch(request)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    
    func selectedManufacturers(){
        if self.selectedList == "Nationals"{
            getNationalManufacturers()
            return
        }
        getImportedManufacturers()
        return
    }
    
    
    func getNationalManufacturers() {
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        let predicate = NSPredicate(format: "countryCode == %@", "ES")
        request.predicate = predicate
        do {
            manufacturers = try manager.context.fetch(request)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    
    func getImportedManufacturers(){
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        let predicate = NSPredicate(format: "countryCode != %@", "ES")
        request.predicate = predicate
        
        do {
            manufacturers = try manager.context.fetch(request)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    
    func addManufacturer(name: String, countryCode: String, image: UIImage, favorite: Bool){
        if let compressedImageData = ImageProcessor.compressImage(image) {
            let newManufacturer = ManufacturerEntity(context: manager.context)
            newManufacturer.id = UUID()
            newManufacturer.name = name
            newManufacturer.countryCode = countryCode
            newManufacturer.favorite = favorite
            newManufacturer.imageData = compressedImageData // Asigna la imagen comprimida al atributo imageData de la entidad
            newManufacturer.beers = []  //  Ya que inicialmente no tenemos cervezas asociadas
        }
        selectedManufacturers()
        save()
    }
    
    func updateManufacturer(forID id: UUID,
                             newName: String,
                             newCountryCode: String,
                             newImage: UIImage?,
                             newFavorite: Bool) {
        let context = manager.container.viewContext
        
        let fetchRequest: NSFetchRequest<ManufacturerEntity> = ManufacturerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let manufacturerToUpdate = result.first {
                if manufacturerToUpdate.name != newName {
                    manufacturerToUpdate.name = newName
                }
                if manufacturerToUpdate.countryCode != newCountryCode {
                    manufacturerToUpdate.countryCode = newCountryCode
                }
                if manufacturerToUpdate.favorite != newFavorite {
                    manufacturerToUpdate.favorite = newFavorite
                }
                if let compressedImageData = ImageProcessor.compressImage(newImage!), manufacturerToUpdate.imageData != compressedImageData {
                    manufacturerToUpdate.imageData = compressedImageData
                }
                
                save()
                selectedManufacturers()
                // Agrega cualquier otra lógica necesaria después de guardar la actualización
            }
        } catch {
            print("Error updating manufacturer: \(error.localizedDescription)")
        }
    }
    
    func changeFavoriteManufacturer(){
        guard let id = self.manufacturer?.id else {
            // Manejar el caso donde el ID es nulo
            return
        }
        
        let context = manager.container.viewContext
        
        let fetchRequest: NSFetchRequest<ManufacturerEntity> = ManufacturerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let manufacturerToUpdate = result.first {
                //print("Antes togel")
                //print(manufacturerToUpdate.favorite)
                manufacturerToUpdate.favorite.toggle()
                //print("Dsps togel")
                //print(manufacturerToUpdate.favorite)
                save()
                selectedManufacturers()
            }
        } catch {
            print("Error updating manufacturer: \(error.localizedDescription)")
        }
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
    
    
    func addBeer(newBeer beer: BeerEntity) {
        let context = manager.container.viewContext
        let newBeer = BeerEntity(context: context)
        newBeer.id = beer.id
        newBeer.name = beer.name
        newBeer.type = beer.type
        newBeer.alcoholContent = beer.alcoholContent
        newBeer.calories = beer.calories
        newBeer.favorite = beer.favorite
        newBeer.imageData = beer.imageData
        newBeer.manufacturer = beer.manufacturer
        save()
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
            newBeer.manufacturer = manufacturer     //Asociamos la nueva cerveza al fabricante en cuestión
        }
        
        save()
        getBeers()
        getUniqueBeerTypes(isFavorite: false)
    }
    
    
//#warning("Hay que cambiar este getBeers para que por Defecto se haga el getBeers filtrado por sortCriteria = .Name")
    func getBeers() {
        guard let currentManufacturer = self.manufacturer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        let predicate = NSPredicate(format: "manufacturer == %@", currentManufacturer)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "type", ascending: true) // Ordenar por el atributo 'type'
        fetchRequest.sortDescriptors = [sortDescriptor] // Agregar el descriptor de ordenación a la solicitud de búsqueda
        
        do {
            self.beers = try manager.container.viewContext.fetch(fetchRequest)
            getUniqueBeerTypes(isFavorite: false)
        } catch {
            print("Error fetching beers: \(error.localizedDescription)")
        }
    }
    
    
    func getBeersByType(by type: String) {
        guard let currentManufacturer = self.manufacturer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        let predicate = NSPredicate(format: "manufacturer == %@ AND type == %@", currentManufacturer, type)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "type", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor] // Agregar el descriptor de ordenación a la solicitud de búsqueda
        
        do {
            self.beers = try manager.container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching beers: \(error.localizedDescription)")
        }
    }
    
    
    func sortAndFilterBeers(filter searchText: String, sort sortCriteria: SortCriteria, isFavorite favSelection: Bool){
        if favSelection{
            self.getFavoritesBeers()
        }else{
            self.getBeers()
        }
        
        guard !searchText.isEmpty else {
            self.filterBeers(by: sortCriteria)
            return
        }
        
        self.filterBeers(by: sortCriteria)
        self.beers = self.beers.filter {$0.name!.localizedCaseInsensitiveContains(searchText)}
    }
    
    
    func filterBeers(by criteria: SortCriteria) {
        switch criteria {
        case .name:
            self.beers.sort { $0.name! < $1.name! } // Ordenar por nombre
        case .calories:
            self.beers.sort { $0.calories < $1.calories } // Ordenar por calorías
        case .alcoholContent:
            self.beers.sort { $0.alcoholContent < $1.alcoholContent } // Ordenar por contenido de alcohol
        case .favorites:
            self.beers.sort { $0.favorite && !$1.favorite } // Ordenar por favoritos
        }
    }
    
    /*
     func updateBeerDetails(forID id: UUID, newBeer: BeerEntity, image: UIImage) {
     getBeers()
     
     // Eliminar la cerveza existente
     deleteBeerById(withID: id)
     
     // Agregar la nueva cerveza
     addBeer(newBeer: newBeer)
     }
     */
    
    func updateBeer(forID id: UUID,
                    newName: String,
                    newType: String,
                    newAlcoholContent: Float,
                    newCalories: Int16,
                    newFavorite: Bool,
                    newImage: UIImage?) {
        let context = manager.container.viewContext
        
        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let beerToUpdate = result.first {
                if beerToUpdate.name != newName {
                    beerToUpdate.name = newName
                }
                if beerToUpdate.type != newType {
                    beerToUpdate.type = newType
                }
                if beerToUpdate.alcoholContent != newAlcoholContent {
                    beerToUpdate.alcoholContent = newAlcoholContent
                }
                if beerToUpdate.calories != newCalories {
                    beerToUpdate.calories = newCalories
                }
                if beerToUpdate.favorite != newFavorite {
                    beerToUpdate.favorite = newFavorite
                }
                if let compressedImageData = ImageProcessor.compressImage(newImage!), beerToUpdate.imageData != compressedImageData {
                    beerToUpdate.imageData = compressedImageData
                }
                if beerToUpdate.manufacturer != manufacturer {
                    beerToUpdate.manufacturer = self.manufacturer
                }
                
                save()
                getUniqueBeerTypes(isFavorite: false)
            }
        } catch {
            print("Error updating beer: \(error.localizedDescription)")
        }
    }
    
    
    func addAllTypeToDeleteBeersList(forType type: String) {
        guard let currentManufacturer = self.manufacturer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "manufacturer == %@ AND type == %@", currentManufacturer, type)
        
        do {
            let beersToDelete = try manager.container.viewContext.fetch(fetchRequest)
            let beerIDs = beersToDelete.compactMap { $0.id }
            self.deleteBeersList.append(contentsOf: beerIDs)
        } catch {
            print("Error fetching beers to delete: \(error.localizedDescription)")
        }
    }
    
    
    func deleteBeer(indexSet: IndexSet){
        indexSet.map { beers[$0]}.forEach(manager.container.viewContext.delete)
        save()
    }
    
    
    func deleteSelectedBeers(isFavorite favSelection: Bool, orderBy sortCriteria : SortCriteria) {
        for id in self.deleteBeersList {
            let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let beerToDelete = try? manager.container.viewContext.fetch(fetchRequest).first {
                manager.container.viewContext.delete(beerToDelete)
            }
        }
        save()
        if favSelection{
            getFavoritesBeers()
            getUniqueBeerTypes(isFavorite: favSelection)
        }else{
            getUniqueBeerTypes(isFavorite: favSelection)
            getBeersByBeerTypesAndSortCriteria(sortCriteria: sortCriteria)
        }
        self.deleteBeersList = []
    }
    
    
    func deleteAllBeers(){
        beers.forEach { beer in
            manager.container.viewContext.delete(beer)
        }
        save()
        getBeers()
    }
    
    func save(){
        manager.save()
    }
    
    
    func getUniqueBeerTypes(isFavorite favoriteSelected: Bool) {
        guard let currentManufacturer = self.manufacturer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BeerEntity")
        var predicateFormat = "manufacturer == %@"
        let predicateArgs: [Any] = [currentManufacturer]
        
        if favoriteSelected {
            predicateFormat += " AND favorite == true"
        }
        
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        fetchRequest.propertiesToFetch = ["type"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        
        // Definir el criterio de ordenación por 'type' de manera alfabética
        let sortDescriptorType = NSSortDescriptor(key: "type", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorType]
        
        do {
            let results = try manager.container.viewContext.fetch(fetchRequest)
            let types = results.compactMap { ($0 as? [String: Any])?["type"] as? String }
            self.beerTypes = Array(Set(types)).sorted() // Ordenar alfabéticamente
        } catch {
            print("Error fetching unique beer types: \(error.localizedDescription)")
        }
    }
    
    
    func getBeersByBeerTypesAndSortCriteria(sortCriteria: SortCriteria) {
        guard let currentManufacturer = self.manufacturer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        
        // Establecer un predicado para filtrar por el fabricante actual
        let predicate = NSPredicate(format: "manufacturer == %@", currentManufacturer)
        fetchRequest.predicate = predicate
        
        var sortKey: String = ""
        // Definir el sortDescriptor secundario según el sortCriteria
        switch sortCriteria {
        case .name:
            sortKey = "name"
        case .calories:
            sortKey = "calories"
        case .alcoholContent:
            sortKey = "alcoholContent"
        case .favorites:
            sortKey = "favorite"
        }
        
        let primarySortDescriptor = NSSortDescriptor(key: "type", ascending: true) // Ordenar por el atributo 'type'
        let secondarySortDescriptor = NSSortDescriptor(key: sortKey, ascending: true) // Sort descriptor secundario según el sortCriteria
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor] // Agregar los sort descriptors a la solicitud de búsqueda
        
        do {
            // Fetch beers based on the specified sort criteria and manufacturer
            self.beers = try manager.container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching beers: \(error.localizedDescription)")
        }
    }
    
    
    func getFavoritesBeers() {
        guard let currentManufacturer = self.manufacturer else {
            return
        }
        
        
        let fetchRequest: NSFetchRequest<BeerEntity> = BeerEntity.fetchRequest()
        let manufacturerPredicate = NSPredicate(format: "manufacturer == %@", currentManufacturer)
        
        // Predicado para buscar favoritas
        let favoritesPredicate = NSPredicate(format: "favorite == %@", NSNumber(value: true))
        
        // Combinar los predicados utilizando NSCompoundPredicate
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [manufacturerPredicate, favoritesPredicate])
        
        fetchRequest.predicate = compoundPredicate
        
        let sortDescriptor = NSSortDescriptor(key: "type", ascending: true) // Ordenar por el atributo 'type'
        fetchRequest.sortDescriptors = [sortDescriptor] // Agregar el descriptor de ordenación a la solicitud de búsqueda
        
        do {
            self.beers = try manager.container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching filtered beers: \(error.localizedDescription)")
        }
    }
    
    
    //InitialDataLoader
    func addManufacturerAndBeerForInitialData(name: String, manufacturerCountryCode: String, beerName: String, beerType: String, beerAlcoholContent: Float, beerCalories: Int16, beerFavorite: Bool, manufacturerFavorite: Bool, manufacturerImage: UIImage, beerImage: UIImage) {
        
        if let compressedManufacturerImageData = ImageProcessor.compressImage(manufacturerImage),
           let compressedBeerImageData = ImageProcessor.compressImage(beerImage) {
            
            // Agrega el fabricante
            let newManufacturer = ManufacturerEntity(context: manager.context)
            newManufacturer.id = UUID()
            newManufacturer.name = name
            newManufacturer.countryCode = manufacturerCountryCode
            newManufacturer.favorite = manufacturerFavorite
            newManufacturer.imageData = compressedManufacturerImageData
            newManufacturer.beers = []
            
            self.manufacturer = newManufacturer
            
            // Agrega la cerveza asociada al fabricante
            let newBeer = BeerEntity(context: manager.context)
            newBeer.id = UUID()
            newBeer.name = beerName
            newBeer.alcoholContent = beerAlcoholContent
            newBeer.calories = beerCalories
            newBeer.type = beerType
            newBeer.imageData = compressedBeerImageData
            newBeer.favorite = beerFavorite
            newBeer.manufacturer = newManufacturer
            
            // Guarda los cambios
            save()
            
            // Refresca los datos necesarios
            selectedManufacturers()
            getBeers()
            getUniqueBeerTypes(isFavorite: false)
        }
    }
}
