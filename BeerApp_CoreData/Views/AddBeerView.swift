//
//  AddBeerView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI


struct AddBeerView: View {
    
    @State private var beerName: String = ""
    @State private var alcoholContent: String = ""
    @State private var calories: String = ""
    @State private var beerType: BeerTypes = .lager
    @State private var isFavorite : Bool = false
    //@State private var isImported: Bool = false
    
    @State private var selectedImage: UIImage?
    @State private var hasImage = false
    @State private var isImagePickerPresented = false
    
    @State private var attempts = 0
    @State private var isShaking = false
    
    @State private var alcoholContentTextColor: Color = .black
    @State private var caloriesTextColor: Color = .black
    @State private var statusMessage : String = "Introduce un nombre y selecciona una imagen"
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Detalles de la Nueva Cerveza")) {
#warning("Revisar si poner aqui el HStack del otro proyecto")
                HStack{
                    Text("Nombre: ")
                    TextField("Cerveza", text: $beerName)
                        .onChange(of: beerName) { _ in
                            checkNewBeerFields()
                        }
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Graduación alcohólica:")
                    Spacer()
                    TextField("0-100", text: alcoholContentBinding(alcoholContent: $alcoholContent, textColor: $alcoholContentTextColor), onEditingChanged: { _ in }, onCommit: {
                    })
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 80)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: alcoholContent) { newValue in
                        //print(newValue)
                        if !Validators.validateAlcoholDecimal(newValue) {
                            alcoholContent = ""
                        }
                    }
                    Text("%").foregroundColor($alcoholContentTextColor.wrappedValue)
                }
                
                HStack {
                    Text("Aporte calórico:")
                    Spacer()
                    TextField("0-500", text: caloriesBinding(calories: $calories, textColor: $caloriesTextColor))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: calories) { newValue in
                            if !Validators.validateCaloriesTextField(newValue) {
                                calories = ""
                            }
                        }
                    Text("kcal").foregroundColor($caloriesTextColor.wrappedValue)
                }
                
                HStack {
                    Picker(selection: $beerType, label: Text("Tipo de Cerveza")) {
                        ForEach(BeerTypes.allCases, id: \.self) { beerType in
                            Text(beerType.rawValue).tag(beerType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Button(action: {
                    isFavorite.toggle()
                }) {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                        Text("Favorita")
                            .foregroundColor(isFavorite ? .red : .black)
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
                                self.hasImage = false
                                self.selectedImage = nil
                                checkNewBeerFields()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Eliminar Imagen")
                                }
                            }
                            .padding(2)
                        }
                        .onAppear {
                            self.hasImage = true // Cuando hay una imagen, establece hasImage como true al cargar la vista
                            checkNewBeerFields()
                        }
                        
                    } else {
                        Button(action: {
                            self.isImagePickerPresented.toggle()
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(.red)
                                Text("Seleccionar Imagen")
                            }
                            .padding(2)
                        }
                        .background(isShaking ? Color.red.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                        .offset(x: isShaking ? -5 : 0) // Cambia la posición en el eje x
                        
                    }
                }
            }
            
            
            Section {
                Button(action: {
                    // Si se supera el límite, activar el shake
                    attempts += 1
                    if attempts >= 2 {
                        withAnimation(Animation.default.repeatCount(4)) {
                            isShaking.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                            isShaking = false
                        }
                    }
                    addBeer()
                }) {
                    Text("Guardar Cerveza")
                        .foregroundColor(checkButtonAvailable() ? Color.white.opacity(0.5) : Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(checkButtonAvailable() ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                //.disabled(checkButtonAvailable())
                
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
                        Text((viewModel.manufacturer?.name)!)
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
                          type: beerType.rawValue,
                          alcoholContent: Float(alcoholContent)!,
                          calories: Int16(calories)!,
                          favorite: isFavorite,
                          image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!,
                          manufacturer: viewModel.manufacturer!)
        
        presentationMode.wrappedValue.dismiss()
        //attempts += 1
    }
    
    func checkNewBeerFields() {
        DispatchQueue.main.async {
            statusMessage = determineStatusMessage()
        }
    }
    
    private func determineStatusMessage() -> String {
        if beerName.isEmpty && hasImage == false {
            return "Introduce un nombre y selecciona una imagen"
        } else if beerName.isEmpty {
            return "Introduce un nombre"
        } else if hasImage == false {
            return "Selecciona una imagen"
        } else {
            return ""
        }
    }
    
    func checkButtonAvailable() -> Bool {
        return beerName.isEmpty || hasImage == false || Float(alcoholContent) ?? -1 < 0.0 || Int16(calories) ?? -1 < 0
    }
}
