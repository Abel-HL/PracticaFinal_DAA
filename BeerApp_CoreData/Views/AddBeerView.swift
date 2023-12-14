//
//  AddBeerView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 13/12/23.
//

import SwiftUI

/*
 struct AddBeerView: View {
 
 @State private var beerName = ""
 @State private var beerCountry : CountryInfo
 @State private var isImported: Bool = false
 @State private var selectedImage: UIImage?
 @State private var isImagePickerPresented = false
 @State private var statusMessage : String
 
 @Binding var selectedList: String
 
 @ObservedObject var viewModel: ManufacturersViewModel
 
 
 @Environment(\.presentationMode) var presentationMode
 
 var sortedCountries: [CountryInfo] {
 return CountryInfo.allCases.sorted { $0.name < $1.name }
 }
 
 init(viewModel: ManufacturersViewModel/*, selectedList: Binding<String>*/) {
 // Asignar el viewModel recibido en la inicialización
 self.viewModel = viewModel
 //self._selectedList = selectedList
 
 // Asignar el país por defecto y el mensaje de campos por completar en la inicialización
 _beerCountry = State(initialValue: CountryInfo.Spain) // Cambiar "Spain" por el account.configuration.country
 _statusMessage = State(initialValue: "Introduce un nombre y selecciona una imagen")
 }
 
 var body: some View {
 Form {
 Section(header: Text("Nuevo Fabricante")) {
 TextField("Nombre del Fabricante", text: $beerName)
 .onChange(of: beerName) { _ in
 checkNewBeerFields()
 }
 //TextField("País de Origen", text: $beerCountry)
 
 Picker("País de Origen", selection: $beerCountry) {
 ForEach(sortedCountries, id: \.self) { country in
 Text("\(country.flag) \(country.name)").tag(country)
 }
 }
 .pickerStyle(.menu) // Puedes cambiar el estilo del picker si prefieres
 .onChange(of: beerCountry) { _ in
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
 addBeer()
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
 /*.toolbar {
  ToolbarItem(placement: .navigationBarLeading) {
  NavigationLink(destination: BeersView()) {
  HStack {
  Image(systemName: "chevron.backward")
  Text("Lista de Fabricantes")
  }
  }
  }
  }*/
 .sheet(isPresented: $isImagePickerPresented) {
 ImagePicker(selectedImage: $selectedImage)
 }
 }
 
 
 
 func addBeer(){
 
 selectedList = beerCountry.code == "ES" ? "Nacionales" : "Importadas"
 /*
  viewModel.addBeer(name: beerName,
  type: "Lager",
  alcoholContent: 5.0,
  calories: 150,
  favorite: true,
  image: (selectedImage ?? UIImage(systemName: "xmark.circle.fill"))!)
  */
 
 
 presentationMode.wrappedValue.dismiss()
 }
 
 
 
 private func checkImported() {
 isImported = beerCountry.name.lowercased() != "spain"
 }
 
 
 
 func checkNewBeerFields(){
 DispatchQueue.main.async {
 statusMessage = beerName.isEmpty && selectedImage == nil ? "Introduce un nombre y selecciona una imagen" :
 beerName.isEmpty ? "Introduce un nombre" :
 selectedImage == nil ? "Selecciona una imagen" : ""
 }
 }
 
 
 
 func checkButtonAvailable() -> Bool{
 return beerName.isEmpty || selectedImage == nil
 }
 }
 
 
 
 
 /*
  struct AddBeerView: View {
  @State private var beerName: String = ""
  @State private var alcoholContent: Float = 0.0
  @State private var calories: UInt16 = 0
  @State private var beerType: String = "Pilsner"
  
  @State private var avatarItem: PhotosPickerItem?
  @State private var avatarImage: Image?
  @State private var showImagePicker = false
  @State private var selectedImage: Image?
  @State private var beerImageURL: URL?
  // Otros campos que podrían ser necesarios para una cerveza
  
  @EnvironmentObject var beerListViewModel: BeerListViewModel
  @EnvironmentObject var beerDetailViewModel: BeerDetailViewModel
  @Environment(\.presentationMode) var presentationMode
  
  func saveImageToDocumentsDirectory(image: UIImage, fileName: String) -> URL? {
  guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
  return nil
  }
  
  let fileURL = documentsDirectory.appendingPathComponent(fileName)
  
  do {
  if let data = image.jpegData(compressionQuality: 1.0) {
  try data.write(to: fileURL)
  return fileURL
  }
  } catch {
  print("Error saving image: \(error)")
  }
  
  return nil
  }
  
  var body: some View {
  Form {
  Section(header: Text("Detalles de la Nueva Cerveza")) {
  HStack {
  Text("Nombre:")
  Spacer()
  TextField("Nombre", text: $beerName)
  .multilineTextAlignment(.trailing)
  }
  
  HStack {
  Text("Graduación alcohólica:")
  Spacer()
  TextField("0-100", text: Binding(
  get: { String(alcoholContent) },
  set: { alcoholContent = Float($0) ?? 0.0 }
  ))
  .keyboardType(.decimalPad)
  .frame(maxWidth: 80)
  .multilineTextAlignment(.trailing)
  Text("%")
  }
  
  HStack {
  Text("Aporte calórico:")
  Spacer()
  TextField("Aporte calórico", text: Binding(
  get: { String(calories) },
  set: { calories = UInt16($0) ?? 0 }
  ))
  .keyboardType(.numberPad)
  .multilineTextAlignment(.trailing)
  Text("kcal")
  }
  
  HStack {
  Picker(selection: $beerType, label: Text("Tipo de Cerveza")) {
  Text("Pilsen").tag("Pilsen")
  Text("Lager").tag("Lager")
  Text("Prueba").tag("Prueba")
  }
  .pickerStyle(MenuPickerStyle())
  }
  
  HStack {
  VStack {
  
  PhotosPicker("Seleccionar imagen", selection: $avatarItem, matching: .images)
  if let avatarImage {
  avatarImage
  .resizable()
  .scaledToFit()
  .frame(width: 300, height: 300)
  }
  }
  .onChange(of: avatarItem) { _ in
  Task {
  if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
  if let uiImage = UIImage(data: data) {
  avatarImage = Image(uiImage: uiImage)
  
  // Guardar la imagen seleccionada en el directorio de documentos
  beerImageURL = saveImageToDocumentsDirectory(image: uiImage, fileName: "\(beerName).jpg")
  
  return
  }
  }
  print("Failed")
  }
  }
  }
  }
  
  Section {
  Button(action: {
  if validateInput() {
  saveNewBeer()
  } else {
  // Manejar la validación fallida
  print("Fallo")
  }
  }) {
  Text("Guardar Cerveza")
  .foregroundColor(.white)
  .frame(maxWidth: .infinity)
  .padding()
  .background(Color.blue)
  .cornerRadius(8)
  }
  }
  }
  .navigationBarBackButtonHidden(true)
  .navigationBarTitle("Añadir Cerveza")
  .navigationBarTitleDisplayMode(.large)
  .toolbar {
  ToolbarItem(placement: .navigationBarLeading) {
  NavigationLink(destination: BeerDetailView(beerDetailViewModel: beerDetailViewModel)) {
  HStack {
  Image(systemName: "chevron.backward")
  //Text("\(beerDetailViewModel.selectedBeer.name)")
  }
  }
  }
  }
  
  
  }
  
  
  func validateInput() -> Bool {
  if alcoholContent >= 0.0, alcoholContent <= 100.0 {
  return true
  }
  return false
  }
  func saveNewBeer() {
  guard let beerImageURL = beerImageURL else {
  print("No se ha seleccionado una imagen")
  return
  }
  /*
   //#warning("Change photo attribute")
   let newBeer = Beer(name: beerName, type: beerType, alcoholContent: alcoholContent, calories: calories, bundlePhoto: beerImageURL.absoluteString)
   
   if beerDetailViewModel.addNewBeer(newBeer: newBeer) {
   beerListViewModel.updateCollection(with: beerDetailViewModel.selectedBeer)
   }
   */
  // Cerrar la vista después de guardar
  presentationMode.wrappedValue.dismiss()
  }
  
  }
  
  
  #Preview {
  AddBeerView()
  }
  
  */
 */
