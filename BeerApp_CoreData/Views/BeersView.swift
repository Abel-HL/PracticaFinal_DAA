//
//  BeersView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI

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

/*
#Preview {
    BeersView()
}
*/


/*
struct BeersView2: View {
    @State private var searchText = ""
    @State private var sortCriteria: SortCriteria? = nil
            
    @State private var showActionSheet = false
    @State var previousType: String = "Prueba"
    
    @State private var showDeleteView = false
    @State private var selectedBeerIndexes = Set<Int>()
    @State private var allSelected = false
    @State private var availableBeersIDs = [String]()
    @State private var beersToDelete = [String]()
    
    @EnvironmentObject var manufacturerListViewModel: ManufacturerListViewModel
    @ObservedObject var manufacturerDetailViewModel: ManufacturerDetailViewModel
    
    
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding(.horizontal)
            
            List {
                ForEach(filteredAndSortedBeers().keys.sorted(), id: \.self) { beerType in
                    if !(filteredAndSortedBeers()[beerType]?.isEmpty ?? true) {
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
                            ForEach(filteredAndSortedBeers()[beerType] ?? []) { beer in
                                BeerRow(beer: beer, manufacturerImage: manufacturerDetailViewModel.selectedManufacturer.imageURL)
                                    //selectedBeerIDs.append(beer.id)
                                    .environmentObject(manufacturerDetailViewModel) // Pasando manufacturerDetailViewModel a BeerRow
                                    .onAppear {
                                        if !availableBeersIDs.contains(beer.id) {
                                            availableBeersIDs.append(beer.id)
                                        }
                                    }
                            }
                            //.onDelete(perform: deleteBeer)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(manufacturerDetailViewModel.selectedManufacturer.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: ManufacturerListView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Lista de Fabricantes")
                    }
                }
            }
                        
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AddBeerView().environmentObject(manufacturerDetailViewModel)) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Beer")
                    }
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                
                Button(action: {
                    beersToDelete = []
                    showDeleteView.toggle()
                }) {
                    Image(systemName: "trash")
                    Text("Eliminar Cerveza")
                }
                .disabled(manufacturerDetailViewModel.selectedManufacturer.beerTypes.values.flatMap { $0 }.isEmpty)
                .sheet(isPresented: $showDeleteView, onDismiss: {
                    deleteBeers()
                }) {
                    DeleteMultipleBeersView(
                        beers: Array(manufacturerDetailViewModel.selectedManufacturer.beerTypes.values.joined()),
                        selectedBeerIndexes: $selectedBeerIndexes,
                        allSelected: $allSelected,
                        availableBeersIDs: $availableBeersIDs,
                        beersToDelete: $beersToDelete
                    )
                }
                
            
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    showActionSheet = true
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortCriteria?.rawValue ?? "Ordenar")
                }
                .disabled(manufacturerDetailViewModel.selectedManufacturer.beerTypes.values.flatMap { $0 }.isEmpty)
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
    
    func deleteBeers(){
        if manufacturerDetailViewModel.deleteBeers(withIDs: beersToDelete) {
            availableBeersIDs = availableBeersIDs.filter { !beersToDelete.contains($0) }
            // Si la eliminación es exitosa, actualiza la colección en manufacturerListViewModel
            manufacturerListViewModel.updateCollection(with: manufacturerDetailViewModel.selectedManufacturer)
        }
    }
    
    func filteredAndSortedBeers() -> [String: [Beer]] {
        guard !searchText.isEmpty else {
            return sortBeers(manufacturerDetailViewModel.selectedManufacturer.beerTypes)
        }
        
        let filteredTypes = sortBeers(manufacturerDetailViewModel.selectedManufacturer.beerTypes.mapValues { beers in
            beers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        })
        return filteredTypes
    }
    
    func sortBeers(_ beerTypes: [String: [Beer]]) -> [String: [Beer]] {
        guard let criteria = sortCriteria else {
            return beerTypes
        }
        
        switch criteria {
        case .name:
            return beerTypes.mapValues { $0.sorted(by: { $0.name < $1.name }) }
        case .calories:
            return beerTypes.mapValues { $0.sorted(by: { $0.calories < $1.calories }) }
        case .alcoholContent:
            return beerTypes.mapValues { $0.sorted(by: { $0.alcoholContent < $1.alcoholContent }) }
        }
    }
}



struct BeerRow: View {
    var beer: Beer // Suponiendo que tienes un modelo Beer
    @State private var selectedImage: UIImage?
    var manufacturerImage: String
    @EnvironmentObject var manufacturerDetailViewModel: ManufacturerDetailViewModel // Aquí se recibe manufacturerDetailViewModel
        
    var body: some View {
        NavigationLink(destination: BeerDetailView(beer: beer, manufacImage: manufacturerImage).environmentObject(manufacturerDetailViewModel)) {
            HStack {
                if let loadedImage = selectedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                    
                } else if let imagePath = Bundle.main.url(forResource: beer.bundlePhoto, withExtension: nil),
                          let imageData = try? Data(contentsOf: imagePath),
                          let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                } else if let imagePath = Bundle.main.url(forResource: manufacturerImage, withExtension: nil),
                          let imageData = try? Data(contentsOf: imagePath),
                          let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                } else{
                    Text("No se encontró ninguna imagen")
                }
                Text(beer.name)
            }
            .onAppear {
                loadImage(from: beer.photoURL)
            }
        }
    }
    
    private func loadImage(from url: URL?) {
        guard let url = url else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.selectedImage = loadedImage
                }
            }
        }.resume()
    }
}



struct DeleteMultipleBeersView: View {
    @State private var beers: [Beer]
    @Binding private var selectedBeerIndexes: Set<Int>
    @Binding private var allSelected: Bool
    @Binding private var availableBeersIDs: [String]
    @Binding private var beersToDelete: [String]
    @Environment(\.presentationMode) var presentationMode
    
    init(beers: [Beer], selectedBeerIndexes: Binding<Set<Int>>, allSelected: Binding<Bool>,availableBeersIDs: Binding<[String]>, beersToDelete: Binding<[String]>) {
        self._beers = State(initialValue: beers)
        self._selectedBeerIndexes = selectedBeerIndexes
        self._allSelected = allSelected
        self._availableBeersIDs = availableBeersIDs
        self._beersToDelete = beersToDelete
    }
    
    var body: some View {
        VStack {
            Button(action: {
                selectedBeerIndexes = allSelected ? Set<Int>() : Set(beers.indices)
                allSelected.toggle()
            }) {
                Text(allSelected ? "Deseleccionar todas" : "Seleccionar todas")
            }
            .padding()
                        
            List {
                ForEach(beers.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            if self.selectedBeerIndexes.contains(index) {
                                self.selectedBeerIndexes.remove(index)
                            } else {
                                self.selectedBeerIndexes.insert(index)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedBeerIndexes.contains(index) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedBeerIndexes.contains(index) ? .blue : .gray)
                                Text(beers[index].name)
                                    .foregroundColor(selectedBeerIndexes.contains(index) ? .blue : .black)
                            }
                        }
                        
                        //Spacer()
                    }
                    .contentShape(Rectangle()) // Asegura que la fila sea tappable en cualquier lugar
                }
                //.listRowInsets(EdgeInsets()) // Elimina los márgenes adicionales en las filas
            }
            .scrollContentBackground(.hidden)
            .background(Color.red)
            
            Button(action: {
                deleteSelectedBeers()
                
            }) {
                Text("Eliminar cervezas seleccionadas")
                    .foregroundColor(.white)
                    .padding()
                    //.frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            //.padding()
            
            //Spacer()
            
            //Divider()
            //Lo he puesto como boton porque seguro algún usuario en vez de realizar el gesto de deslizamiento pulsa este "botón"
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            
            Text("Desliza hacia abajo para cerrar")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.bottom, 20)
        }
    }
    
    func deleteSelectedBeers() {
        for beerID in availableBeersIDs {
            if selectedBeerIndexes.contains(beers.firstIndex { $0.id == beerID } ?? 0) {
                beersToDelete.append(beerID)
            }
        }
        
        print(beersToDelete)
        selectedBeerIndexes = Set<Int>()
        allSelected = false
        // Una vez que se han eliminado las cervezas, cierra esta vista
        presentationMode.wrappedValue.dismiss()
    }
}



struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Buscar cerveza", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}




/*
 #Preview {
 ManufacturerDetailView()
 }
 */

*/
