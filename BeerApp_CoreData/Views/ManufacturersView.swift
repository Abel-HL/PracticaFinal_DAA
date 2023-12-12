//
//  ContentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//

import SwiftUI
import CoreData

struct ManufacturersView: View {
    @ObservedObject var viewModel = ManufacturersViewModel()
    @State var selectedList = "Nacionales"

    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $selectedList, label: Text("Tipo")) {
                    Text("Nacionales").tag("Nacionales")
                    Text("Importadas").tag("Importadas")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedList) { list in
                    viewModel.selectedManufacturers(selectedList: list)
                }
                
                List {
                    ForEach(viewModel.manufacturers) { manufacturer in
                        ManufacturerRow(manufacturer: manufacturer/*, selectedList: $selectedList*/)
                    }
                    .onDelete(perform: viewModel.deleteManufacturer)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Lista de Fabricantes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                //ToolbarItem(placement: .topBarLeading) {
                    //MenuView()
                //}
                ToolbarItem {
                    Button(action: {
                        viewModel.deleteAllManufacturers(selectedList: selectedList)
                    }) {
                        Label("Delete Manufacturer", systemImage: "trash")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        selectedList = "Importadas"
                        viewModel.addManufacturer(name: "Prueba", countryCode: "CN", selectedList: selectedList)
                    }) {
                        Label("Add Manufacturer", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddManufacturerView(viewModel : viewModel, selectedList: $selectedList)) {
                        Text("Añadir")
                    }
                }
            }
        }
    }
}


struct ManufacturerRow: View {
    var manufacturer: ManufacturerEntity
    //@Binding var selectedList: String
    //@EnvironmentObject var manufacturerListViewModel: ManufacturerListViewModel
    //@StateObject var manufacturerDetailViewModel: ManufacturerDetailViewModel
    //@EnvironmentObject var manufacturerListViewModel: ManufacturerListViewModel
    
    init(manufacturer: ManufacturerEntity/*, selectedList: Binding<String>*/) {
        self.manufacturer = manufacturer
        //self._selectedList = selectedList
        //_manufacturerDetailViewModel = StateObject(wrappedValue: ManufacturerDetailViewModel(selectedManufacturer: manufacturer))
    }
    
    var body: some View {
        //NavigationLink(destination: ManufacturerDetailView(manufacturerDetailViewModel: manufacturerDetailViewModel).environmentObject(manufacturerListViewModel)) {
            HStack {
                /*if let imagePath = Bundle.main.url(forResource: manufacturer.imageURL, withExtension: nil),
                   let imageData = try? Data(contentsOf: imagePath),
                   let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                } else {
                    Image(systemName: "square.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                }*/
                Text(manufacturer.name ?? "")
                Spacer()
                if manufacturer.countryCode != "ES"{
                    Text(searchFlag(countryCode: manufacturer.countryCode ?? "") ?? "")
                }
            }
        //}
        /*.onAppear{
            //manufacturerDetailViewModel.selectedManufacturer = manufacturer
        }*/
    }
    
    func searchFlag(countryCode: String) -> String? {
        guard let country = CountryInfo.allCases.first(where: { $0.code == countryCode }) else {
            return nil // Código de país no encontrado
        }

        return country.flag // Devolver la bandera del país correspondiente al código
    }
}


#Preview {
    ManufacturersView()//.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}




/*
 @StateObject var viewModel = ManufacturersViewModel()

 var body: some View {
     NavigationView {
         List {
             ForEach(viewModel.manufacturers) { manufacturer in
                 NavigationLink(
                     destination: Text("Item at \(manufacturer.name ?? "")")
                 ) {
                     Text(manufacturer.name ?? "")
                 }
             }
             .onDelete(perform: viewModel.deleteManufacturer)
         }
         .toolbar {
             ToolbarItem {
                 Button(action: {
                     viewModel.addManufacturer(name: "Prueba", countryCode: "ES")
                 }) {
                     Label("Add Item", systemImage: "plus")
                 }
             }
         }
         Text("Select an item")
     }
 }
 */
