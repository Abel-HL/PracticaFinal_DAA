//
//  BeerViewDetail.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 22/12/23.
//

import SwiftUI

struct BeerDetailView: View {
    @State private var beer: BeerEntity
        
    @State private var beerName: String
    @State private var alcoholContent: String
    @State private var calories: String
    @State private var selectedBeerType: BeerTypes
    @State private var isFavorite : Bool = false
    #warning("Hay q mirar como saber si ha cambiado de beer.imageData a una nueva imagen del ImagaPicker")
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var hasImageChanges = false
    
    @State private var alcoholContentTextColor: Color = .green
    @State private var caloriesTextColor: Color = .green
    
    
    
    
#warning("Cambiar nombre de estas variables y eliminar las no usadas. Ver si hay duplicadas que hagan la misma funcion")
    //@State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var newPhotoURL: URL?
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera // Por defecto, abre la cámara
    
    @State private var imageData: Data?
    @State private var displayButtonsInsteadOfImage = false
    //@State var manufacturerImage : String
    //@State private var selectedImage: UIImage?
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    init(beer: BeerEntity) {
        _beer = State(initialValue: beer)
        _beerName = State(initialValue: beer.name ?? "DefaultName")
        _alcoholContent = State(initialValue: String(beer.alcoholContent))
        _calories = State(initialValue: String(beer.calories))
        _selectedBeerType = State(initialValue: BeerTypes(rawValue: beer.type ?? "Lager") ?? .lager)
        _isFavorite = State(initialValue: beer.favorite)
        _selectedImage = State(initialValue: ImageProcessor.getImageFromData(beer.imageData ?? Data()))
    }
    
    var body: some View {
        
        Button(action: {
            showActionSheet = true
        }) {
            if let loadedImage = selectedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(5)
                
            } else{
                Text("Not image found")
            }
        }
        .padding(30)
        .onAppear {
            if let imageData = beer.imageData,
               let uiImage = ImageProcessor.getImageFromData(imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)
            } else {
                Image(systemName: "square.fill")
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
            }
        }
        .overlay(alignment: .bottomLeading) {
            Button(action: {
                ImagePicker(selectedImage: $selectedImage)
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
                hasImageChanges = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.borderless)
        }
          
        Form {
            Section(header: Text("Beer Details")) {
                HStack {
                    Text("Name:")
                    Spacer()
                    TextField("Beer Name", text: $beerName)
                        .multilineTextAlignment(.trailing) // Alinear a la derecha
                }
                
                AlcoholComponentView(alcoholContent: $alcoholContent, alcoholContentTextColor: $alcoholContentTextColor)
                
                CaloriesComponentView(calories: $calories, caloriesTextColor: $caloriesTextColor)
                           
                
                BeerTypePickerComponentView(selectedBeerType: $selectedBeerType)
                
                FavoriteComponentView(isFavorite: $isFavorite)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitle(beerName)               //Dinamicamente con el TextField de Name
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Update Beer") {
                    if validateInput() {
                        updateBeerDetails()
                    } else {
                        print("Fail")
                    }
                }
                .disabled(!hasChanges()) // Deshabilitar si no hay cambios
                .frame(maxWidth: .infinity)
                .padding(8)
                .foregroundColor(.white)
                .background(validateInput() ? Color.blue.opacity(0.8) : Color.gray) // Cambio de color dependiendo validator
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
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    func hasChanges() -> Bool {
        return beer.name != beerName ||
        beer.alcoholContent != Float(alcoholContent) ||
        beer.calories != Int16(calories) ||
        beer.type != selectedBeerType.rawValue ||
        beer.favorite != isFavorite ||
        hasImageChanges == true
    }
    
    #warning("Ver si se puede poner esto en el Validators.swift")
    func validateInput() -> Bool {
        let isAlcoholContentValid = (0.0...100.0).contains(Float(alcoholContent) ?? -1)
        let areCaloriesValid = (0...500).contains(Int(calories) ?? -1)
        let isBeerNameNotEmpty = !beerName.isEmpty
        
        return isAlcoholContentValid &&
            areCaloriesValid &&
            isBeerNameNotEmpty && hasChanges()
    }

    
    
    func updateBeerDetails() {
        viewModel.updateBeer(forID: beer.id!,
                                    newName: beerName,
                                    newType: selectedBeerType.rawValue,
                                    newAlcoholContent: Float(alcoholContent) ?? -1,
                                    newCalories: Int16(calories) ?? -1,
                                    newFavorite: isFavorite,
                                    newImage: (selectedImage ?? UIImage(named: "BeerLogo")))
        
        presentationMode.wrappedValue.dismiss()
    }
}
