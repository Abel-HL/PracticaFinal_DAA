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
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var statusMessage = ""

    @Binding var selectedList: String
    
    @ObservedObject var viewModel: ManufacturersViewModel
    
    
    @Environment(\.presentationMode) var presentationMode
    
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    
    init(viewModel: ManufacturersViewModel, selectedList: Binding<String>) {
        // Asignar el viewModel recibido en la inicialización
        self.viewModel = viewModel
        self._selectedList = selectedList
        
        // Asignar el país por defecto en la inicialización
        _manufacturerCountry = State(initialValue: CountryInfo.Spain) // Cambiar "Spain" por el account.configuration.country
    }
    
    var body: some View {
        Form {
            Section(header: Text("Nuevo Fabricante")) {
                TextField("Nombre del Fabricante", text: $manufacturerName)
                    .onChange(of: manufacturerName) { _ in
                        checkNewManufacturerFields()
                    }
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
                        Text("Lista de Fabricantes")
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    
    
    func addManufacturer(){
        
        selectedList = manufacturerCountry.code == "ES" ? "Nacionales" : "Importadas"
        
        viewModel.addManufacturer(name: manufacturerName, countryCode: manufacturerCountry.code, image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!, selectedList: selectedList)
            
        
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


/*
#Preview {
    AddManufacturerView()
}
*/