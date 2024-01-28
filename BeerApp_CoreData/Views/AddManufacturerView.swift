//
//  AddManufacturerView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//

import SwiftUI

struct AddManufacturerView: View {
    
    @State private var manufacturerName = ""
#warning("Cambiar por manufacturerCountry: Country?")
    @State private var manufacturerCountry: String = ""  //Country?
    @State private var isImported: Bool = true
    
    @State private var selectedImage: UIImage?
    @State private var hasImage = false
    @State private var isImagePickerPresented = false
    
    @State private var isFavorite : Bool = false
    #warning("Quitar esto del statusMessage, dejarlo como el AddBeerView")
    @State private var statusMessage : String = "Enter a name and select an image"
    
    @State private var orientation: UIDeviceOrientation
    @ObservedObject var countryService = CountryService.shared
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    
    init() {
        
        _orientation = State(initialValue: UIDevice.current.orientation)
        countryService.getCountriesData()
        _manufacturerCountry = State(initialValue: countryService.countries.first?.countryCode ?? "")
    }
    // Obtener la lista de países usando CountryService
    /*
     var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
     */
    
    /*var sortedCountries: [Country] = {
        var countries: [Country] = []
        CountryService.shared.getCountriesData { result in
            countries = result
            print(result)
        }
        return countries
    }()*/
     
    
    var body: some View {
        Group {
            if orientation.isLandscape {
                // Landscape layout
                HStack {
                    imageButton
                    form
                }
            } else {
                // Portrait layout
                imageButton
                form
            }
        }
        .onAppear{
            orientation = UIDevice.current.orientation
        }
        .onRotate { newOrientation in
            orientation = newOrientation
            print("Orientation LandsCape?:")
            print(orientation.isLandscape)
        }
    }
        
        
    private var imageButton: some View{
        Button(action: {
            //showActionSheet = true
        }) {
            if let loadedImage = selectedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .cornerRadius(5)
                
            } else{
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.blue)
                    .frame(width: 140, height: 140)
            }
        }
        
        .padding(30)
        .overlay(alignment: .bottomLeading) {
            Button(action: {
                //ImagePicker(selectedImage: $selectedImage)
            }) {
                Image(systemName: "camera.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.borderless)
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                self.isImagePickerPresented.toggle()
                hasImage = true
                print(hasImage)
                //ImagePicker(selectedImage: $selectedImage)
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.borderless)
        }
    }
        
        
    private var form: some View{
        Form {
            Section(header: Text("New Manufacturer")) {
                NameComponentView(varName: $manufacturerName, field: "Manufacturer")
                
                CountryPickerComponentView(manufacturerCountry: $manufacturerCountry, isImported: $isImported)
                
                ImportedComponentView(isImported: $isImported)
                
                FavoriteComponentView(isFavorite: $isFavorite, field: "star")
            }
            /*
            Section {
                //SaveButtonsComponentView(field: "manufacturer")
                Button(action: {
                    addManufacturer()
                }) {
                    ButtonSaveTextComponentView(label: "Save Manufacturer", isButtonDisabled: checkButtonAvailable())
                }
                .disabled(checkButtonAvailable())
                // Label dinámico
                ViewBuilders.dynamicStatusLabel(for: statusMessage)
            }
             */
        }
        /*.onAppear {
            // Llamar a la función para obtener los datos de los países cuando la vista aparece
            countryService.getCountriesData()
        }*/
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Add Manufacturer")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    addManufacturer()
                }) {
                    ButtonSaveTextComponentView(label: "Save Manufacturer", isButtonDisabled: checkButtonAvailable())
                }
                .disabled(checkButtonAvailable())
                .frame(maxWidth: .infinity)
                .padding(8)
                .foregroundColor(.white)
                .background(!checkButtonAvailable() ? Color.blue.opacity(0.8) : Color.gray) // Cambio de color dependiendo validator
                .cornerRadius(8)
                
                //NavigationLink(destination: ManufacturerDetailView(manufacturerDetailViewModel: manufacturerDetailViewModel)) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Cancel")
                    }
                }
            }
            /*
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: ManufacturersView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Manufacturers")
                    }
                }
            }*/
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            hasImage = newImage != nil ? true : false
        }
    }
    
    
    #warning("// == configuration.nationalCountry ? \"Nationals\" : \"Imported\"")
    func addManufacturer(){
        viewModel.selectedList = manufacturerCountry == "ES" ? "Nationals" : "Imported" // == configuration.nationalCountry ? "Nationals" : "Imported"
        print("Veamos cual es el manufCountry: ")
        print(manufacturerCountry)
        viewModel.addManufacturer(name: manufacturerName, countryCode: manufacturerCountry, image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!, favorite: isFavorite)
        presentationMode.wrappedValue.dismiss()
    }
    
    
    
    private func checkImported() {
        print(manufacturerCountry)
        isImported = manufacturerCountry.lowercased() != "es"   //configuration.nationalCountryCode
    }
    
    
    #warning("Eliminar esto del StatusMensaje. Ponerlo como esta en el AddBeerView")
    func checkNewManufacturerFields(){
        DispatchQueue.main.async {
            statusMessage = manufacturerName.isEmpty && selectedImage == nil ? "Enter a name and select an image" :
                            manufacturerName.isEmpty ? "Enter a name" :
                            selectedImage == nil ? "Select an Image" : ""
        }
    }
    
    
    
    func checkButtonAvailable() -> Bool{
        return !Validators.validateManufacturerInput(manufacturerName: manufacturerName) || hasImage == false
    }
     
}
