//
//  BeerViewDetail.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 22/12/23.
//
import UIKit
import SwiftUI

// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct BeerDetailView: View {
    @State private var beer: BeerEntity
    
    @State private var beerName: String
    @State private var alcoholContent: String
    @State private var calories: String
    @State private var selectedBeerType: BeerTypes
    @State private var isFavorite : Bool = false
//#warning("Hay q mirar como saber si ha cambiado de beer.imageData a una nueva imagen del ImagaPicker")
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var hasImageChanges = false
    
    @State private var alcoholContentTextColor: Color = .green
    @State private var caloriesTextColor: Color = .green
    
    
    
    
//#warning("Cambiar nombre de estas variables y eliminar las no usadas. Ver si hay duplicadas que hagan la misma funcion")
    //@State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var newPhotoURL: URL?
    @State private var showImagePicker = false
    //@State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera // Por defecto, abre la cámara
    
    @State private var imageData: Data?
    @State private var displayButtonsInsteadOfImage = false

    @State private var orientation: UIDeviceOrientation
    //@State var manufacturerImage : String
    //@State private var selectedImage: UIImage?
    
    @ObservedObject var viewModel = ManufacturersViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    //@Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    init(beer: BeerEntity) {
        _beer = State(initialValue: beer)
        _beerName = State(initialValue: beer.name ?? "DefaultName")
        _alcoholContent = State(initialValue: String(beer.alcoholContent))
        _calories = State(initialValue: String(beer.calories))
        _selectedBeerType = State(initialValue: BeerTypes(rawValue: beer.type ?? "Lager") ?? .lager)
        _isFavorite = State(initialValue: beer.favorite)
        _selectedImage = State(initialValue: ImageProcessor.getImageFromData(beer.imageData ?? Data()))
        _orientation = State(initialValue: UIDevice.current.orientation)
    }
    
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
                Image(systemName: "square.fill")
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
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
                hasImageChanges = true
                print(hasImageChanges)
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
            Section(header: Text("Beer Details")) {
                NameComponentView(varName: $beerName, field: "Beer")
                
                AlcoholComponentView(alcoholContent: $alcoholContent, alcoholContentTextColor: $alcoholContentTextColor)
                
                CaloriesComponentView(calories: $calories, caloriesTextColor: $caloriesTextColor)
                           
                
                BeerTypePickerComponentView(selectedBeerType: $selectedBeerType)
                
                FavoriteComponentView(isFavorite: $isFavorite, field: "heart")
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
    
    func validateInput() -> Bool {
        return hasChanges() && Validators.validateBeerInput(alcoholContent: alcoholContent,
                                                        calories: calories,
                                                        beerName: beerName)
    }
    /*
    private func imageSize() -> CGFloat {
        return horizontalSizeClass == .compact ? 80 : 150
    }*/
    
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
