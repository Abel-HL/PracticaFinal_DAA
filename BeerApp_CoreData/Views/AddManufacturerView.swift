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
    @State private var statusMessage : String = "Introduce un nombre y selecciona una imagen"
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Nuevo Fabricante")) {
                HStack{
                    Text("Nombre: ")
                    TextField("Fabricante", text: $manufacturerName)
                        .onChange(of: manufacturerName) { _ in
                            checkNewManufacturerFields()
                        }
                        .multilineTextAlignment(.trailing)
                }
                
                Picker("País de Origen", selection: $manufacturerCountry) {
                    ForEach(sortedCountries, id: \.self) { country in
                        Text("\(country.flag) \(country.name)").tag(country)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: manufacturerCountry) { _ in
                    checkImported()
                }
                
                
                Section {
                    if let selectedImage = selectedImage {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 340)
                                
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
                            .padding(2)
                            
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
                
                Button(action: {
                    checkImported()
                }) {
                    HStack {
                        Image(systemName: isImported ? "checkmark.square.fill" : "square")
                            .foregroundColor(isImported ? .blue : .gray)
                        Text("Importada")
                            .foregroundColor(isImported ? .blue : .black)
                    }
                }
                
            }
            Section {
                Button(action: {
                    addManufacturer()
                }) {
                    Text("Guardar Fabricante")
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
        .navigationTitle("Añadir Fabricante")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: ManufacturersView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Fabricantes")
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    
    
    func addManufacturer(){
        viewModel.selectedList = manufacturerCountry.code == "ES" ? "Nacionales" : "Importadas"
        viewModel.addManufacturer(name: manufacturerName, countryCode: manufacturerCountry.code, image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!)
        presentationMode.wrappedValue.dismiss()
    }
    
    
    
    private func checkImported() {
        isImported = manufacturerCountry.name.lowercased() != "spain"
    }
    
    
    func checkNewManufacturerFields(){
        DispatchQueue.main.async {
            statusMessage = manufacturerName.isEmpty && selectedImage == nil ? "Introduce un nombre y selecciona una imagen" :
                            manufacturerName.isEmpty ? "Introduce un nombre" :
                            selectedImage == nil ? "Selecciona una imagen" : ""
        }
    }
    
    
    
    func checkButtonAvailable() -> Bool{
        return manufacturerName.isEmpty || selectedImage == nil
    }
}
