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
    @State private var isImagePickerPresented = false
    @State private var isFavorite : Bool = false
    #warning("Quitar esto del statusMessage, dejarlo como el AddBeerView")
    @State private var statusMessage : String = "Enter a name and select an image"
    
    @ObservedObject var countryService = CountryService.shared
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    
    init() {
        countryService.getCountriesData()
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
        Form {
            Section(header: Text("New Manufacturer")) {
                NameComponentView(varName: $manufacturerName, field: "Manufacturer")
                
                CountryPickerComponentView(manufacturerCountry: $manufacturerCountry, isImported: $isImported)
                
                ImportedComponentView(isImported: $isImported)
                
                Section {
                    if let selectedImage = selectedImage {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 240)
                                
                                Spacer()
                            }
                            
                            Button(action: {
                                self.isImagePickerPresented.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Change Image")
                                }
                            }
                            .padding(2)
                            
                        }
                        
                    } else {
                        Button(action: {
                            self.isImagePickerPresented.toggle()
                        }) {
                            HStack {
                                Text("Select Image")
                                Spacer()
                                Image(systemName: "photo")
                            }
                        }
                    }
                }
                
                
                FavoriteComponentView(isFavorite: $isFavorite, field: "star")
            }
            Section {
                Button(action: {
                    addManufacturer()
                }) {
                    Text("Save Manufacturer")
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
        /*.onAppear {
            // Llamar a la función para obtener los datos de los países cuando la vista aparece
            countryService.getCountriesData()
        }*/
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Add Manufacturer")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: ManufacturersView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Manufacturers")
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    
    #warning("// == configuration.nationalCountry ? \"Nationals\" : \"Imported\"")
    func addManufacturer(){
        viewModel.selectedList = manufacturerCountry == "ES" ? "Nationals" : "Imported" // == configuration.nationalCountry ? "Nationals" : "Imported"
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
        return manufacturerName.isEmpty || selectedImage == nil
    }
}
