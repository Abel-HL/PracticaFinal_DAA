//
//  AddManufacturerView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//

import SwiftUI

struct AddManufacturerView: View {
    
    @State private var manufacturerName = ""
    @State private var manufacturerCountry : CountryInfo = CountryInfo.Spain
    @State private var isImported: Bool = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isFavorite : Bool = false
    #warning("Quitar esto del statusMessage, dejarlo como el AddBeerView")
    @State private var statusMessage : String = "Enter a name and select an image"
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        Form {
            Section(header: Text("New Manufacturer")) {
                NameComponentView(varName: $manufacturerName, field: "Manufacturer")
                
                Picker("Country of Origin", selection: $manufacturerCountry) {
                    ForEach(sortedCountries, id: \.self) { country in
                        Text("\(country.flag) \(country.name)").tag(country)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: manufacturerCountry) { _ in
                    checkImported()
                }
                
                Button(action: {
                    checkImported()
                }) {
                    HStack {
                        Text("Imported")
                            .foregroundColor(isImported ? .blue : .black)
                        Spacer()
                        Image(systemName: isImported ? "checkmark.square.fill" : "square")
                            .foregroundColor(isImported ? .blue : .gray)
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
                    FavoriteComponentView(isFavorite: $isFavorite, field: "star")
                }
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
    
    
    
    func addManufacturer(){
        viewModel.selectedList = manufacturerCountry.code == "ES" ? "Nationals" : "Imported"
        viewModel.addManufacturer(name: manufacturerName, countryCode: manufacturerCountry.code, image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!, favorite: isFavorite)
        presentationMode.wrappedValue.dismiss()
    }
    
    
    
    private func checkImported() {
        isImported = manufacturerCountry.name.lowercased() != "spain"
    }
    
    
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
