//
//  AddManufacturerView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 11/12/23.
//

import SwiftUI

struct AddManufacturerView: View {
    
    @State private var manufacturerName = ""
    @State private var manufacturerCountry : CountryInfo
    @State private var isImported: Bool = false
    @StateObject var viewModel = ManufacturersViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    
    init() {
        // Asignar el país por defecto en la inicialización
        _manufacturerCountry = State(initialValue: CountryInfo.Spain) //Cambiar el "Spain" por el account.configuration.country
    }
    
    var body: some View {
        Form {
            Section(header: Text("Nuevo Fabricante")) {
                TextField("Nombre del Fabricante", text: $manufacturerName)
                //TextField("País de Origen", text: $manufacturerCountry)
                
                Picker("País de Origen", selection: $manufacturerCountry) {
                    ForEach(sortedCountries, id: \.self) { country in
                        Text("\(country.flag) \(country.name)").tag(country)
                    }
                }
                .pickerStyle(.menu) // Puedes cambiar el estilo del picker si prefieres
                .onChange(of: manufacturerCountry) { _ in
                    checkImported()
                }
                
                /*
                Section {
                    if let selectedImage = selectedImage {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 340) // Límite de altura deseado
                                
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
                }*/
                
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
                    viewModel.addManufacturer(name: manufacturerName, countryCode: manufacturerCountry.code)
                    print("New Manufacturer")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Guardar Fabricante")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
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
                        Text("Lista de Fabricantes")
                    }
                }
            }
        }
        /*.sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }*/
    }
    
    private func checkImported() {
        if manufacturerCountry.name.lowercased() == "spain" {
            isImported = false
        } else {
            isImported = true
        }
    }
}

#Preview {
    AddManufacturerView()
}
