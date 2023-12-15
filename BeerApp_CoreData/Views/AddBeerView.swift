//
//  AddBeerView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI


struct AddBeerView: View {
    
    @State private var beerName = ""
    @State private var alcoholContent: Float = -1
    @State private var calories: Int16 = -1
    @State private var beerType: String = "Pilsen"
    @State private var isFavorite : Bool = false
    //@State private var isImported: Bool = false
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    @State private var statusMessage : String = "Introduce un nombre y selecciona una imagen"
    //@Binding var selectedList: String
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Detalles de la Nueva Cerveza")) {
#warning("Revisar si poner aqui el HStack del otro proyecto")
                TextField("Nombre de la cerveza: ", text: $beerName)
                    .onChange(of: beerName) { _ in
                        checkNewBeerFields()
                    }
                
                HStack {
                    Text("Graduación alcohólica:")
                    Spacer()
                    TextField("0-100", text: Binding(
                        get: {
                            if alcoholContent >= 0 {
                                return String(alcoholContent)
                            } else {
                                return "0-100" // O cualquier valor por defecto que desees mostrar
                            }
                        },
                        set: { alcoholContent = Float($0) ?? 0.0 }
                    ))
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 80)
                    .multilineTextAlignment(.trailing)
                    Text("%")
                }
                
                HStack {
                    Text("Aporte calórico:")
                    Spacer()
                    #warning("Hacer la reutilizacion de codigo para estos get-set")
                    TextField("Aporte calórico", text: Binding(
                        get: {
                            if calories >= 0 {
                                return String(calories)
                            } else {
                                return "0-100" // O cualquier valor por defecto que desees mostrar
                            }
                        },
                        set: { calories = Int16($0) ?? 0 }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    Text("kcal")
                }
                
                HStack {
                    Picker(selection: $beerType, label: Text("Tipo de Cerveza")) {
                        Text("Pilsen").tag("Pilsen")
                        Text("Lager").tag("Lager")
                        Text("Prueba").tag("Prueba")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Button(action: {
                    isFavorite.toggle()
                }) {
                    HStack {
                        Image(systemName: isFavorite ? "checkmark.square.fill" : "square")
                            .foregroundColor(isFavorite ? .blue : .gray)
                        Text("Favorita")
                            .foregroundColor(isFavorite ? .blue : .black)
                    }
                }

                
                
                Section {
                    if let selectedImage = selectedImage {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 240) // Límite de altura deseado
                                
                                Spacer()
                            }
                            
                            Button(action: {
                                self.isImagePickerPresented.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Cambiar Imagen")
                                }
                            }
                            .padding(2) // Añade espacios alrededor del botón
                            
                        }
                        
                    } else {
                        Button(action: {
                            self.isImagePickerPresented.toggle()
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                Text("Seleccionar Imagen")
                            }
                        }
                    }
                }
            }
            
            
            Section {
                Button(action: {
                    addBeer()
                }) {
                    Text("Guardar Cerveza")
                        .foregroundColor(checkButtonAvailable() ? Color.white.opacity(0.5) : Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(checkButtonAvailable() ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(checkButtonAvailable())
                
                // Label dinámico
                ViewBuilders.dynamicStatusLabel(for: statusMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Añadir Cerveza")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: BeersView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Lista de Cervezas")
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    
#warning("Revisar esta sección -> Revisar '!' forzado en el ultimo param de addBeer")
    func addBeer(){
        viewModel.addBeer(name: beerName,
                          type: "Lager",
                          alcoholContent: 5.0,
                          calories: 150,
                          favorite: isFavorite,
                          image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!,
                          manufacturer: viewModel.manufacturer!)
        
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func checkNewBeerFields() {
        DispatchQueue.main.async {
            statusMessage = determineStatusMessage()
        }
    }
    
    // Determine the appropriate status message based on field values
    private func determineStatusMessage() -> String {
        if beerName.isEmpty && selectedImage == nil {
            return "Introduce un nombre y selecciona una imagen"
        } else if beerName.isEmpty {
            return "Introduce un nombre"
        } else if selectedImage == nil {
            return "Selecciona una imagen"
        } else if alcoholContent < 0.0 {
            return "Introduce un contenido de alcohol válido (0-100)"
        } else if calories < 0 {
            return "Introduce un valor válido para las calorías"
        } else {
            return ""
        }
    }
    
    // Check if any of the mandatory fields are empty
    func checkButtonAvailable() -> Bool {
        return beerName.isEmpty || selectedImage == nil || alcoholContent < 0.0 || calories < 0
    }
}


 
 
/*
struct AddBeerView2: View {
    @State private var beerName: String = ""
    @State private var alcoholContent: Float = 0.0
    @State private var calories: UInt16 = 0
    @State private var beerType: String = "Pilsner"
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var showImagePicker = false
    @State private var selectedImage: Image?
    @State private var beerImageURL: URL?
    
    @Environment(\.presentationMode) var presentationMode
    
    func saveImageToDocumentsDirectory(image: UIImage, fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            if let data = image.jpegData(compressionQuality: 1.0) {
                try data.write(to: fileURL)
                return fileURL
            }
        } catch {
            print("Error saving image: \(error)")
        }
        
        return nil
    }
    
    var body: some View {
        Form {
            Section(header: Text("Detalles de la Nueva Cerveza")) {
                HStack {
                    Text("Nombre:")
                    Spacer()
                    TextField("Nombre", text: $beerName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Graduación alcohólica:")
                    Spacer()
                    TextField("0-100", text: Binding(
                        get: { String(alcoholContent) },
                        set: { alcoholContent = Float($0) ?? 0.0 }
                    ))
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 80)
                    .multilineTextAlignment(.trailing)
                    Text("%")
                }
                
                HStack {
                    Text("Aporte calórico:")
                    Spacer()
                    TextField("Aporte calórico", text: Binding(
                        get: { String(calories) },
                        set: { calories = UInt16($0) ?? 0 }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    Text("kcal")
                }
                
                HStack {
                    Picker(selection: $beerType, label: Text("Tipo de Cerveza")) {
                        Text("Pilsen").tag("Pilsen")
                        Text("Lager").tag("Lager")
                        Text("Prueba").tag("Prueba")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    VStack {
                        
                        PhotosPicker("Seleccionar imagen", selection: $avatarItem, matching: .images)
                        if let avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                    }
                    .onChange(of: avatarItem) { _ in
                        Task {
                            if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    avatarImage = Image(uiImage: uiImage)
                                    
                                    // Guardar la imagen seleccionada en el directorio de documentos
                                    beerImageURL = saveImageToDocumentsDirectory(image: uiImage, fileName: "\(beerName).jpg")
                                    
                                    return
                                }
                            }
                            print("Failed")
                        }
                    }
                }
            }
            
            Section {
                Button(action: {
                    if validateInput() {
                        saveNewBeer()
                    } else {
                        // Manejar la validación fallida
                        print("Fallo")
                    }
                }) {
                    Text("Guardar Cerveza")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Añadir Cerveza")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: BeerDetailView(beerDetailViewModel: beerDetailViewModel)) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        //Text("\(beerDetailViewModel.selectedBeer.name)")
                    }
                }
            }
        }
        
        
    }
    
    
    func validateInput() -> Bool {
        if alcoholContent >= 0.0, alcoholContent <= 100.0 {
            return true
        }
        return false
    }
    func saveNewBeer() {
        guard let beerImageURL = beerImageURL else {
            print("No se ha seleccionado una imagen")
            return
        }
        /*
         //#warning("Change photo attribute")
         let newBeer = Beer(name: beerName, type: beerType, alcoholContent: alcoholContent, calories: calories, bundlePhoto: beerImageURL.absoluteString)
         
         if beerDetailViewModel.addNewBeer(newBeer: newBeer) {
         beerListViewModel.updateCollection(with: beerDetailViewModel.selectedBeer)
         }
         */
        // Cerrar la vista después de guardar
        presentationMode.wrappedValue.dismiss()
    }
    
}

/*
 #Preview {
 AddBeerView()
 }
 */
*/
