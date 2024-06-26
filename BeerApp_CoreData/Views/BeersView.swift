//
//  BeersView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI


struct BeersView: View {
    
    @State private var searchText = ""
    @State private var currentBeerType: String = "Lager"
    @State private var sortCriteria: SortCriteria = .name
    
    @State private var showActionSheet = false
    @State private var showDeleteView = false
    @State private var allSelected = false
    
    @State private var isSelected = false
    //@State private var editMode: EditMode = .inactive
    @State private var manufacturerFavorite: Bool// Estado del botón favorito
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    init(manufactFavorite: Bool) {
        _manufacturerFavorite = State(initialValue: manufactFavorite)
        //self.beerTypes = viewModel.getUniqueBeerTypes(isFavorite: onlyFavorites)
    }
   
    
    var body: some View {
        NavigationStack {
            ContentView(searchText: $searchText, sortCriteria: $sortCriteria, manufactFavorite: $manufacturerFavorite)
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel =  ManufacturersViewModel.shared
    //#warning("En esta view pueden ser @State y en la BeerView eliminar esas variables")
    @Binding var searchText: String
    @State private var onlyFavorites: Bool = false // Estado del botón favorito
    @Binding private var manufacturerFavorite: Bool// Estado del botón favorito
    @Binding var sortCriteria: SortCriteria // Asumiendo que tienes un enum SortCriteria

    @State private var showActionSheet = false
    
    @Environment(\.editMode) var editMode
    
    init(searchText: Binding<String>, sortCriteria: Binding<SortCriteria>, manufactFavorite: Binding<Bool>) {
        _searchText = searchText
        _sortCriteria = sortCriteria
        _manufacturerFavorite = manufactFavorite
        //self.beerTypes = viewModel.getUniqueBeerTypes(isFavorite: onlyFavorites)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Cambiar el estado de favorito al presionar el botón
                    onlyFavorites.toggle()
                    if onlyFavorites {
                        viewModel.getFavoritesBeers()
                    }else{
                        viewModel.getBeers()
                        viewModel.getUniqueBeerTypes(isFavorite: false)
                    }
                }) {
                    Image(systemName: onlyFavorites ? "heart.fill" : "heart")
                        .foregroundColor(onlyFavorites ? .red : .black) // Cambiar el color si está seleccionado
                        .padding(.leading, 10) // Añadir padding al botón
                }
                
                Spacer() // Espaciador para centrar los elementos
                
                SearchBar(text: $searchText)
                    .autocapitalization(.none) // Desactivar autocorrección
                    .padding(.horizontal, 8) // Ajustar el padding horizontal del SearchBar
                    .frame(maxWidth: .infinity) // Ocupar el espacio disponible
                    .padding(.trailing, 16) // Añadir padding al final del SearchBar
            }
            .padding(.horizontal, 8) // Padding horizontal para el HStack
            .onAppear{
                print("Appear manufFavs")
                print(manufacturerFavorite)
            }
            List {
                ForEach(viewModel.beerTypes, id: \.self) { beerType in
                    BeerSectionView(beerType: beerType, searchText: $searchText)
                }
            }
                .onChange(of: sortCriteria) { newCriteria in
                    viewModel.sortAndFilterBeers(filter: searchText, sort: newCriteria, isFavorite: onlyFavorites)
                }
                .onChange(of: searchText) { newSearchText in
                    viewModel.sortAndFilterBeers(filter: newSearchText, sort: sortCriteria, isFavorite: onlyFavorites)
                }
                .onChange(of: onlyFavorites) { newFavs in
                    viewModel.getUniqueBeerTypes(isFavorite: newFavs)
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
                        Text("Manufacturers")
                    }
                }
            }
            ToolbarItem {
                Button(action: {
                    //viewModel.deleteAllBeers()
                    //viewModel.changeFavorite()
                    manufacturerFavorite.toggle()
                    viewModel.changeFavoriteManufacturer()
                }) {
                    Image(systemName: manufacturerFavorite ? "star.fill" : "star")
                        .foregroundColor(Color.yellow)
                }
            }
            /*ToolbarItem {
                Button(action: {
                    //viewModel.deleteAllBeers()
                    viewModel.addBeer(name: "Pilsen 3.0 150",
                                      type: "Pilsen",
                                      alcoholContent: 3.0,
                                      calories: 150,
                                      favorite: true,
                                      image: (UIImage(named: "BeerLogo") ?? UIImage(systemName: "xmark.circle.fill"))!,
                                      manufacturer: viewModel.manufacturer!)
                }) {
                    Label("Delete Beer", systemImage: "trash")
                }
            }*/
            /*
            ToolbarItem {
                Button(action: {
                    viewModel.addBeer(name: "Lager 5.0 50",
                                      type: "Lager",
                                      alcoholContent: 5.0,
                                      calories: 50,
                                      favorite: false,
                                      image: (UIImage(named: "Photos/MahouCan") ?? UIImage(systemName: "xmark.circle.fill"))!,
                                      manufacturer: viewModel.manufacturer!)
                }) {
                    Label("Add Beer", systemImage: "plus")
                }
            }*/
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AddBeerView()) {
                    Text("Add")
                }
            }
            
            //
            ToolbarItemGroup(placement: .bottomBar) {
                
                Button(action: {
                    // beersToDelete = []
                    // Si editMode está en .inactive, llama a deleteSelectedBeers() del viewModel
                    if editMode?.wrappedValue == .active {
                        viewModel.deleteSelectedBeers(isFavorite: onlyFavorites, orderBy: sortCriteria)
                        searchText = ""
                    }
                    
                    editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
                    //print(editMode?.wrappedValue == .inactive ? viewModel.deleteBeersList : "")
                }) {
                    Image(systemName: "trash")
                    Text(editMode?.wrappedValue == .active ? "Delete Selected" : "Delete Beers")
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    showActionSheet = true
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortCriteria.rawValue)
                }
                //.disabled()
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Order by"), buttons: [
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


struct BeerSectionView: View {
    @ObservedObject var viewModel =  ManufacturersViewModel.shared
    //@State var beerType: String
    let beerType: String
    @Binding var searchText: String
    
    var body: some View {
        Section(header: BeerSectionHeaderView(beerType: beerType)) {
            ForEach(viewModel.beers.filter { $0.type == beerType }) { beer in
                BeerRow(beer: beer)
            }
        }
    }
}

//#warning("Falta añadir al button el caso de q si ya se han añadido y se vuelve a pulsar se borren de la lista")
struct BeerSectionHeaderView: View {
    let beerType: String
    @Environment(\.editMode) var editMode
    @ObservedObject var viewModel =  ManufacturersViewModel.shared

    var body: some View {
        Button(action: {
            if editMode?.wrappedValue == .active{
                print("Seleccionadas todas las cervezas del tipo: \(beerType.capitalized)")
                viewModel.addAllTypeToDeleteBeersList(forType: beerType)
            }
        }) {
            Text(beerType)
        }
    }
}

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
                Spacer()
                if(beer.favorite){
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
                
                //#warning("Revisar esto porq igual es mejor usar solo el viewModel.beer en vez de pasarla por parametro")
                /*
                NavigationLink(value: beer) {
                }   //.opacity(0.0)
                    //.frame(width: 0, height: 0)
                */
                 
                
                 NavigationLink(destination: BeerDetailView(beer: beer)) {
                    //Text("Añadir")
                }   .opacity(0.0)
                    .frame(width: 0, height: 0)
                 
                    
            }
            /*
            .navigationDestination(for: BeerEntity.self){ beer in
                //BeerDetailView(beer: beer)
                //AddBeerView()
                AddManufacturerView()
            }
             */
            
            /*
            .navigationDestination(for: ManufacturerEntity.self){ manufacturer in
                BeersView(manufacturer: manufacturer)
                //Text("Pantalla Detalles")
            }
             */
        }
    }
}
