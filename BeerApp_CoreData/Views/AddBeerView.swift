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
    
    @State private var alcoholContentTextColor: Color = .red
    @State private var beerNameTextColor: Color = .red
    @State private var caloriesTextColor: Color = .red
    //@State private var statusMessage : String = "Enter a name and select an image"
    
    @State private var orientation: UIDeviceOrientation
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    
    init() {
        _orientation = State(initialValue: UIDevice.current.orientation)
    }
    /*
    var sortedCountries: [CountryInfo] {
        return CountryInfo.allCases.sorted { $0.name < $1.name }
    }
    */
    
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
                    .frame(width: 80, height: 80)
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
                hasImage = selectedImage != nil ? true : false
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
        /*Section {
            if let selectedImage = selectedImage {
                VStack {
                    HStack {
                        Spacer()
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 140)
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        self.hasImage = false
                        self.selectedImage = nil
                        //checkNewBeerFields()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Delete Image")
                        }
                    }
                    .padding(2)
                }
                .onAppear {
                    self.hasImage = true // Cuando hay una imagen, establece hasImage como true al cargar la vista
                    //checkNewBeerFields()
                }
                
            } else {
                Button(action: {
                    self.isImagePickerPresented.toggle()
                }) {
                    HStack {
                        Text("Select Image")
                        Spacer()
                        Image(systemName: "photo")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(2)
                }
                .background(isShaking ? Color.red.opacity(0.3) : Color.clear)
                .cornerRadius(8)
                .offset(x: isShaking ? -5 : 0) // Cambia la posición en el eje x
                
            }
        }
    }*/
        
    private var form: some View{
        Form {
            Section(header: Text("New Beer Details")) {

                NameComponentView(varName: $beerName, field: "Beer")
                
                AlcoholComponentView(alcoholContent: $alcoholContent, alcoholContentTextColor: $alcoholContentTextColor)
                
                CaloriesComponentView(calories: $calories, caloriesTextColor: $caloriesTextColor)
                
                BeerTypePickerComponentView(selectedBeerType: $beerType)
                
                FavoriteComponentView(isFavorite: $isFavorite, field: "heart")
            }
            
            #warning("Revisar esto del shake con los attempts")
            /*Section {
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
                    ButtonSaveTextComponentView(label: "Save Beer", isButtonDisabled: checkButtonAvailable())
                }
                .disabled(checkButtonAvailable())
                
                // Label dinámico
                //ViewBuilders.dynamicStatusLabel(for: statusMessage)
            }*/
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Add Beer")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    addBeer()
                }) {
                    ButtonSaveTextComponentView(label: "Save Beer", isButtonDisabled: checkButtonAvailable())
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
            /*ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: BeersView(manufactFavorite: viewModel.manufacturer!.favorite)) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text((viewModel.manufacturer?.name) ?? "Example")
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
    
    
#warning("Revisar esta sección -> Revisar '!' forzado en el ultimo param de addBeer -> Pasar con el ?? -1 y que en el viewModel se compruebe")
#warning("Revisar esta sección -> Revisar porque se debe seleccionar una imagen")
    func addBeer(){
        viewModel.addBeer(name: beerName,
                          type: beerType.rawValue,
                          alcoholContent: Float(alcoholContent)!,
                          calories: Int16(calories)!,
                          favorite: isFavorite,
                          image: (selectedImage ?? UIImage(systemName: "xmark.circle"))!,
                          manufacturer: viewModel.manufacturer!)
        
        presentationMode.wrappedValue.dismiss()
    }
    
    /*
    func checkNewBeerFields() {
        DispatchQueue.main.async {
            statusMessage = determineStatusMessage()
        }
    }
    
    private func determineStatusMessage() -> String {
        if beerName.isEmpty && hasImage == false {
            return "Enter a name and select an image"
        } else if beerName.isEmpty {
            return "Enter a name"
        } else if hasImage == false {
            return "Select an image"
        } else {
            return ""
        }
    }
     */
    
    func checkButtonAvailable() -> Bool {
        return hasImage == false || !Validators.validateBeerInput(alcoholContent: alcoholContent,
                                       calories: calories,
                                       beerName: beerName)
    }
}
