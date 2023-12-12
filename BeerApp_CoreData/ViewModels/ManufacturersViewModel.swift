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
    
    init() {
        getNationalManufacturers()
    }
    
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
        if let data = image.pngData(){
            let newManufacturer = ManufacturerEntity(context: manager.context)
            newManufacturer.name = name
            newManufacturer.countryCode = countryCode
            newManufacturer.imageData = data // Asigna la imagen en forma de Data al atributo imageData de la entidad
            // Aquí puedes realizar más configuraciones y guardar la entidad en CoreData
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
    
    func saveImageToCoreData(image: UIImage){
        if let data = image.pngData(){
            let newManufacturer = ManufacturerEntity() // Crea una nueva instancia de ManufacturerEntity
            newManufacturer.imageData = data // Asigna la imagen en forma de Data al atributo imageData de la entidad
            // Aquí puedes realizar más configuraciones y guardar la entidad en CoreData
        }
    }
    
    func save(){
        manager.save()
        //getAllManufacturers()
    }
    
}
