//
//  ManufacturersViewModel.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//
import Foundation
import CoreData

class ManufacturersViewModel: ObservableObject{
    
    let manager = PersistenceController.shared
    @Published var manufacturers: [ManufacturerEntity] = []
    
    init() {
        getManufacturers()
    }
    
    func getManufacturers(){
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        
        do {
            manufacturers = try manager.context.fetch(request)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    
    func addManufacturer(name: String, countryCode: String){
        let newManufacturer = ManufacturerEntity(context: manager.context)
        newManufacturer.name = name
        newManufacturer.countryCode = countryCode
        print("Añadido")
        save()
    }
    
    func deleteManufacturer(indexSet: IndexSet){
        indexSet.map { manufacturers[$0]}.forEach(manager.container.viewContext.delete)
        save()
    }
    
    func deleteAllManufacturers(){
        manufacturers.forEach { manufacturer in
            manager.container.viewContext.delete(manufacturer)
        }
        save()
    }
    
    func save(){
        manager.save()
        getManufacturers()
    }
    
}
