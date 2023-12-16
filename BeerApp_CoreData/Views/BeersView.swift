//
//  BeersView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI


struct BeersView: View {
    
    @State private var searchText = ""
    //@State private var currentBeerType: String = "nil"
    @State private var sortCriteria: SortCriteria = .name
    
    @State private var showActionSheet = false
    @State private var showDeleteView = false
    @State private var allSelected = false
    
    @State private var isSelected = false
    //@State private var editMode: EditMode = .inactive
    
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.editMode) var editMode
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                /*
                 List {
                 ForEach(viewModel.beers) { beer in
                 if currentBeerType != beer.type {
                 ForEach(viewModel.beers.filter { $0.type == beer.type }) { filteredBeer in
                 BeerRow(beer: filteredBeer)
                 }
                 }
                 }
                 }
                 }
                 */
                
                List {
                    ForEach(viewModel.beers) { beer in
                        HStack{
                            
                            BeerRow(beer: beer)
                        }
                    }
                    .onDelete(perform: viewModel.deleteBeer)
                }
                
                .onChange(of: sortCriteria) { newCriteria in
                    viewModel.sortAndFilterBeers(filter: searchText, sort: newCriteria)
                }
                .onChange(of: searchText) { newSearchText in
                    viewModel.sortAndFilterBeers(filter: newSearchText, sort: sortCriteria)
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(viewModel.manufacturer?.name ?? "")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                //EditButton()
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
                        //viewModel.deleteAllBeers()
                        viewModel.addBeer(name: "Hola 5.0 50",
                                          type: "Lager",
                                          alcoholContent: 5.0,
                                          calories: 50,
                                          favorite: false,
                                          image: (UIImage(named: "BeerLogo") ?? UIImage(systemName: "xmark.circle.fill"))!,
                                          manufacturer: viewModel.manufacturer!)
                    }) {
                        Label("Delete Beer", systemImage: "trash")
                    }
                }
                
#warning("Eliminar este BarItem")
                ToolbarItem {
                    Button(action: {
                        viewModel.addBeer(name: "Prueba 3.0 80",
                                          type: "Lager",
                                          alcoholContent: 3.0,
                                          calories: 80,
                                          favorite: true,
                                          image: (UIImage(named: "BeerLogo") ?? UIImage(systemName: "xmark.circle.fill"))!,
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
                
                //
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Button(action: {
                        //beersToDelete = []
                        // Si editMode está en .inactive, llama a deleteSelectedBeers() del viewModel
                        if editMode?.wrappedValue == .active {
                            viewModel.deleteSelectedBeers()
                            searchText = ""
                        }
                        
                        editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
                        
                        print(editMode?.wrappedValue == .inactive ? viewModel.deleteBeersList : "")
                        //showDeleteView.toggle()
                    }) {
                        Image(systemName: "trash")
                        //Text("Eliminar Cerveza")
                        Text(editMode?.wrappedValue == .active ? "Eliminar" : "Eliminar Cervezas")
                            .fontWeight(.bold)
                    }
                    //.environment(\.editMode, $editMode)
                    //.disabled(viewModel.manufacturer.beerTypes.values.flatMap { $0 }.isEmpty)
                    /*.sheet(isPresented: $showDeleteView, onDismiss: {
                        //viewModel.deleteBeersSelected()
                    }) {
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
                            .default(Text("Favorites")) { sortCriteria = .favorites },
                            .cancel()
                        ])
                    }
                }
            }
        }
    }
}
    /*
    func filteredBeers(by sortCriteria : SortCriteria) {
        guard !searchText.isEmpty else {
            viewModel.getBeers()
            viewModel.filterBeers(by: sortCriteria)
            return
        }
        viewModel.getBeers()
        viewModel.filterBeers(by: sortCriteria)
        viewModel.beers = viewModel.beers.filter {$0.name!.localizedCaseInsensitiveContains(searchText)}
        //return filteredBeers
    }
     */


struct BeerRow: View {
    var beer: BeerEntity // Suponiendo que tienes un modelo Beer
    @StateObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.editMode) var editMode
    @State private var isSelected = false
    
    
    init(beer: BeerEntity) {
        self.beer = beer
    }
        
    var body: some View {
        NavigationStack{
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
                
                if editMode?.wrappedValue == .active {
                    Button(action: {
                        isSelected.toggle()
                        if isSelected {
                            viewModel.deleteBeersList.append(beer.id!) // Agrega el ID de la cerveza a la lista
                        } else {
                            if let index = viewModel.deleteBeersList.firstIndex(of: beer.id!) {
                                viewModel.deleteBeersList.remove(at: index) // Elimina el ID de la cerveza de la lista
                            }
                        }
                    }) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                    }
                    .padding(.trailing)
                }
                if let imageData = beer.imageData,
                   let uiImage = ImageProcessor.getImageFromData(imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                } else {
                    Image(systemName: "square.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                }
                Text(beer.name ?? "")
                
                /*
                NavigationLink(destination: BeerDetailView()) {
                    //Text("Añadir")
                }   .opacity(0.0)
                 */
                /*
                 NavigationLink(destination: BeersView(beer: beer)) {
                    //Text("Añadir")
                }   .opacity(0.0)
                 */
            }
            /*
            .navigationDestination(for: ManufacturerEntity.self){ manufacturer in
                BeersView(manufacturer: manufacturer)
                //Text("Pantalla Detalles")
            }
             */
        }
        //}
        /*.onAppear{
            //manufacturerDetailViewModel.selectedManufacturer = manufacturer
        }*/
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
