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
    @Published var manufacturers: [Manufacturer] = []
    
    
    
    func getManufacturers(){
        let request = NSFetchRequest<ManufacturerEntity>(entityName: "ManufacturerEntity")
        
        do {
            manufacturers = try manager.context.fetch(request)
        } catch let error {
            print("Error getting Manufacturers -> fetch error: \(error)")
        }
    }
    
    
    func addManufacturer(){
        let newManufacturer = Manufacturer(context: manager.context)
        newManufacturer.name = "Prueba1"
        save()
    }
    
    /*func deleteManufacturer(){
        let newManufacturer = Manufacturer(context: manager.context)
        newManufacturer.name = "Prueba1"
        save()
    }*/
    
    func save(){
        manager.save()
    }
    
}
