//
//  ContentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//

import SwiftUI
import CoreData

struct ManufacturersView: View {
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared

    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $viewModel.selectedList, label: Text("Type")) {
                    Text("Nationals").tag("Nationals")
                    Text("Imported").tag("Imported")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: viewModel.selectedList) { list in
                    viewModel.selectedManufacturers()
                }
                
                List {
                    ForEach(viewModel.manufacturers) { manufacturer in
                        ManufacturerRow(manufacturer: manufacturer)
                        /*
                         NavigationLink(value: manufacturer){
                            //ManufacturerRow(manufacturer: manufacturer)
                         }//.opacity(0.0)
                         */
                    }
                    .onDelete{ indexSet in
                        viewModel.deleteManufacturer(indexSet: indexSet)
                    }

                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Manufacturers")
            .navigationBarTitleDisplayMode(.large)
            /*.navigationDestination(for: ManufacturerEntity.self){ manufacturer in
                BeersView(manufacturer: manufacturer)
            }*/
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        viewModel.deleteAllManufacturers()
                    }) {
                        Label("Delete Manufacturer", systemImage: "trash")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.selectedList = "Imported"
                        viewModel.addManufacturer(name: "Prueba", countryCode: "CN", image: UIImage(named: "Logos/MahouLogo")!, favorite: true)
                    }) {
                        Label("Add Manufacturer", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddManufacturerView()) {
                        Text("Add")
                    }
                }
            }
        }
    }
}


struct ManufacturerRow: View {
    var manufacturer: ManufacturerEntity
    @StateObject var viewModel = ManufacturersViewModel.shared
    @StateObject var countryService = CountryService.shared
    
    init(manufacturer: ManufacturerEntity) {
        self.manufacturer = manufacturer
    }
    
    var body: some View {
        NavigationStack{
            HStack {
                if let imageData = manufacturer.imageData,
                   let uiImage = ImageProcessor.getImageFromData(imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .cornerRadius(5)
                } else {
                    Image(systemName: "square.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                }
                Text(manufacturer.name ?? "")
                
                NavigationLink(destination: BeersView(manufactFavorite: manufacturer.favorite).onAppear {
                    viewModel.setManufacturer(for: manufacturer)
                }) {
                    //Text("Añadir")
                }   .opacity(0.0)
                /*
                 NavigationLink(destination: BeersView(manufacturer: manufacturer)) {
                    //Text("Añadir")
                }   .opacity(0.0)
                 */
                if manufacturer.favorite{
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                }
                Spacer()
                /*if manufacturer.countryCode != "ES"{
                    Text(searchFlag(countryCode: manufacturer.countryCode ?? "") ?? "")
                }*/
                if let countryCode = manufacturer.countryCode, countryCode != "ES" {
                    if let country = countryService.countries.first(where: { $0.countryCode == countryCode }) {
                        if !country.flagEmoji.isEmpty {
                            Text(country.flagEmoji)
                        } else {
                            Image(systemName: "flag.slash")
                        }
                    }
                }
            }
            /*
            .navigationDestination(for: ManufacturerEntity.self){ manufacturer in
                BeersView(manufacturer: manufacturer)
                //Text("Pantalla Detalles")
            }
             */
        }
    }
    
    /*
    func searchFlag(countryCode: String) -> String? {
        guard let country = CountryInfo.allCases.first(where: { $0.code == countryCode }) else {
            return nil // Código de país no encontrado
        }
        return country.flag // Devolver la bandera del país correspondiente al código
    }
     */
}


#Preview {
    ManufacturersView()//.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
