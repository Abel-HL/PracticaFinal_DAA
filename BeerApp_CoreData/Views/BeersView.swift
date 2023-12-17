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
    
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
   
    
    var body: some View {
        NavigationStack {
            ContentView(searchText: $searchText, sortCriteria: $sortCriteria)
        }
    }
    
    /*
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                /*
                 List {
                     ForEach(viewModel.beers) { beer in
                         HStack{
                             BeerRow(beer: beer)
                         }
                     }
                     .onDelete(perform: viewModel.deleteBeer)
                 }
                */
                
                #warning("Esto falla y hace q salte el error en el body arriba")
                List {
                    ForEach(viewModel.getUniqueBeerTypes()) { beerType in
                            Section(header:
                                        Button(action: {
                                                print("Seleccionadas todas las cervezas del tipo: \(beerType.capitalized)")
                                            }) {
                                                HStack {
                                                    Image(systemName: "hand.tap.fill") // Icono de la mano de tap
                                                        .foregroundColor(.blue)
                                                    Text(beerType.capitalized)
                                                        .font(.footnote)
                                                        .foregroundStyle(Color.gray)
                                                        .fontWeight(.bold)
                                                }
                                            }
                                ) {
                                ForEach(viewModel.beers.filter { $0.type == beerType }){ beer in
                                        BeerRow(beer: beer)
                                }
                            
                            
                            //.onDelete(perform: viewModel.deleteBeer)
                            
                        }//Cierre Section
                    }
                }
                
                /*List {
                 ForEach(viewModel.getUniqueBeerTypes()) { beerType in
                     if beer.type != currentBeerType {
                         Section(header: sectionHeader(for: beer.type)) {
                             // Aquí puedes mostrar las cervezas del tipo actual si hay alguna lógica específica
                         }
                     } else {
                         BeerRow(beer: beer)
                     }
                 }
                 .onDelete(perform: viewModel.deleteBeer)
             }*/
                
                
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
                        // beersToDelete = []
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
                        Text(editMode?.wrappedValue == .active ? "Eliminar Seleccionadas" : "Eliminar Cervezas")
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
    }*/
    /*
    // Agrega esta función para gestionar el encabezado de la sección
    func sectionHeader(for type: String) -> some View {
        Button(action: {
            print("Seleccionadas todas las cervezas del tipo: \(type.capitalized)")
        }) {
            HStack {
                Image(systemName: "hand.tap.fill") // Icono de la mano de tap
                    .foregroundColor(.blue)
                Text(type.capitalized)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .fontWeight(.bold)
            }
        }
    }
     */
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



struct ContentView: View {
    @ObservedObject var viewModel =  ManufacturersViewModel.shared
    #warning("En esta view pueden ser @State y en la BeerView eliminar esas variables")
    @Binding var searchText: String
    @State private var isFavorited: Bool = false // Estado del botón favorito
    @Binding var sortCriteria: SortCriteria // Asumiendo que tienes un enum SortCriteria
    @Environment(\.editMode) var editMode
    @State private var showActionSheet = false
    var beerTypes: [String] = []
    
    init(searchText: Binding<String>, sortCriteria: Binding<SortCriteria>) {
        _searchText = searchText
        _sortCriteria = sortCriteria
        self.beerTypes = viewModel.getUniqueBeerTypes()    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Cambiar el estado de favorito al presionar el botón
                    isFavorited.toggle()
                    // Aquí puedes realizar la lógica para filtrar por favoritos o realizar cualquier otra acción necesaria
                    //viewModel.filterByFavorites(isFavorited)
                }) {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .foregroundColor(isFavorited ? .red : .black) // Cambiar el color si está seleccionado
                        .padding(.leading, 10) // Añadir padding al botón
                }
                
                Spacer() // Espaciador para centrar los elementos
                
                SearchBar(text: $searchText)
                    .padding(.horizontal, 8) // Ajustar el padding horizontal del SearchBar
                    .frame(maxWidth: .infinity) // Ocupar el espacio disponible
                    .padding(.trailing, 16) // Añadir padding al final del SearchBar
            }
            .padding(.horizontal, 8) // Padding horizontal para el HStack
            
            List {
                ForEach(beerTypes.indices, id: \.self) { index in
                    BeerSectionView(beerType: beerTypes[index], searchText: $searchText)
                }
            }
                .onChange(of: sortCriteria) { newCriteria in
                    viewModel.sortAndFilterBeers(filter: searchText, sort: newCriteria)
                }
                .onChange(of: searchText) { newSearchText in
                    viewModel.sortAndFilterBeers(filter: newSearchText, sort: sortCriteria)
                }
            
            // Resto de tu toolbar y elementos de navegación
            // ...
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle(viewModel.manufacturer?.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            //EditButton()
            ToolbarItem(placement: .topBarLeading) {
                Text("Lista de Fabricantes")
                    .foregroundStyle(Color.blue)
            }
            
            ToolbarItem {
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
            }
            
#warning("Eliminar este BarItem")
            ToolbarItem {
                Button(action: {
                    viewModel.addBeer(name: "Pilsen-Lager 5.0 50",
                                      type: "Lager",
                                      alcoholContent: 5.0,
                                      calories: 50,
                                      favorite: false,
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
                    // beersToDelete = []
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
                    Text(editMode?.wrappedValue == .active ? "Eliminar Seleccionadas" : "Eliminar Cervezas")
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

struct BeerSectionHeaderView: View {
    let beerType: String

    var body: some View {
        Button(action: {
            print("Seleccionadas todas las cervezas del tipo: \(beerType.capitalized)")
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
                    //.padding(.trailing)
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
