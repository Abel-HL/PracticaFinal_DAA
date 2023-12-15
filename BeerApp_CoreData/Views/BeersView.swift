//
//  BeersView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI


struct BeersView: View {
    
    @State private var searchText = ""
    @State private var sortCriteria: SortCriteria = .name
    
    @State private var showActionSheet = false
    @State private var showDeleteView = false
    @State private var allSelected = false
    
    
    #warning("Eliminar estas variables cuando cambie el buTTon del toolbar de PLUS")
    let beerName = "Prueba 5.0 150"
    let selectedImage = UIImage(named: "nombre_de_la_imagen")
    let alcoholContent = 5.0
    let calories: Int16 = 150
    let favorite = true
    
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                
                
                List {
                    ForEach(viewModel.beers) { beer in
                        Text(beer.name ?? "default value")
                    }
                    .onDelete(perform: viewModel.deleteBeer)
                }
                .onChange(of: sortCriteria){ newCriteria in
                    viewModel.getBeers(for: newCriteria)
                }
                 
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(viewModel.manufacturer?.name ?? "Hola ajaja")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: ManufacturersView()) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Lista de Fabricantes")
                        }
                    }
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.deleteAllBeers()
                    }) {
                        Label("Delete Beer", systemImage: "trash")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.addBeer(name: beerName,
                                          type: "Lager",
                                          alcoholContent: Float(alcoholContent),
                                          calories: calories,
                                          favorite: favorite,
                                          image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!,
                                          manufacturer: viewModel.manufacturer!)
                    }) {
                        Label("Add Beer", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddBeerView()) {
                        Text("Añadir")
                    }
                }
                
                //ToolbarItemGroup
                ToolbarItem(placement: .bottomBar) {
                    /*
                    Button(action: {
                        beersToDelete = []
                        showDeleteView.toggle()
                    }) {
                        Image(systemName: "trash")
                        Text("Eliminar Cerveza")
                    }
                    .disabled(viewModel.manufacturer.beerTypes.values.flatMap { $0 }.isEmpty)
                    .sheet(isPresented: $showDeleteView, onDismiss: {
                        deleteBeers()
                    }) {
                        DeleteMultipleBeersView(
                            beers: Array(viewModel.manufacturer.beerTypes.values.joined()),
                            selectedBeerIndexes: $selectedBeerIndexes,
                            allSelected: $allSelected,
                            availableBeersIDs: $availableBeersIDs,
                            beersToDelete: $beersToDelete
                        )
                    }
                     */
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showActionSheet = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortCriteria.rawValue)
                    }
                    //.disabled()
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(title: Text("Ordenar por"), buttons: [
                            .default(Text("Name")) { sortCriteria = .name },
                            .default(Text("Calories")) { sortCriteria = .calories },
                            .default(Text("Alcohol Content")) { sortCriteria = .alcoholContent },
                            .cancel()
                        ])
                    }
                }
            }
        }
    }
}



/*
struct BeersView: View {
    
    let beerName = "Mi cerveza"
    let selectedImage = UIImage(named: "nombre_de_la_imagen")
    let alcoholContent = 5.0
    let calories: Int16 = 150
    let favorite = true
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(viewModel.manufacturer?.name ?? "Default Value")
                    .font(.largeTitle)
                List {
                    ForEach(viewModel.beers) { beer in
                        Text(beer.name ?? "default value")
                    }
                    .onDelete(perform: viewModel.deleteBeer)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        viewModel.deleteAllBeers()
                    }) {
                        Label("Delete Beer", systemImage: "trash")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.addBeer(name: beerName,
                                          type: "Lager",
                                          alcoholContent: Float(alcoholContent),
                                          calories: calories,
                                          favorite: favorite,
                                          image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!,
                                          manufacturer: viewModel.manufacturer!)
                    }) {
                        Label("Add Beer", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddBeerView()) {
                        Text("Añadir")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        //.navigationTitle("Añadir Cerveza")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: ManufacturersView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Lista de Fabricantes")
                    }
                }
            }
        }
    }
}
 
 
 #Preview {
     BeersView()
 }
 
*/
