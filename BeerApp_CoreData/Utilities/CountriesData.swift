//
//  CountriesData.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 17/1/24.
//

import Foundation

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let countryCode: String
    let flagEmoji: String
    let flagImageUrl: String
}

class CountryService : ObservableObject{
    
    static let shared = CountryService()
    
    @Published var countries: [Country] = []
    
    private init() {}  // Para garantizar que se utiliza una única instancia
    
    // Enum para definir algunos países predeterminados
    enum DefaultCountries {
        static let countries: [Country] = [
            Country(name: "United States", countryCode: "US", flagEmoji: "🇺🇸", flagImageUrl: "https://flagcdn.com/w320/us.png"),
            Country(name: "United Kingdom", countryCode: "GB", flagEmoji: "🇬🇧", flagImageUrl: "https://flagcdn.com/w320/gb.png"),
            // Agrega más países predeterminados según sea necesario
        ]
    }
    
    #warning("Eliminar de la url los flags y png y añadir el campo currencies")
    func getCountriesData() {
        guard let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,flags,cca2,flag,population") else {
            // Si la URL es inválida, utiliza los países predeterminados
            countries = DefaultCountries.countries
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let jsonArray = json as? [[String: Any]] {
                        //print(jsonArray.first!)
                        var updatedCountries = [Country]()
                        
                        for jsonObject in jsonArray {
                            if let name = jsonObject["name"] as? [String: Any],
                               let common = name["common"] as? String,
                               let cca2 = jsonObject["cca2"] as? String,
                               let flag = jsonObject["flag"] as? String,
                               let flags = jsonObject["flags"] as? [String: Any],
                               let flagURL = flags["png"] as? String,
                               let population = jsonObject["population"] as? Int {
                                
                                // Añadir la condición para filtrar por población
                                if population >= 20000000 {
                                    var flagEmoji: String = flag  // Por defecto, utiliza la cadena del JSON
                                    // Intenta convertir la cadena del emoji si está presente
                                    if let unicodeString = flag.applyingTransform(StringTransform("Hex-Any"), reverse: false) {
                                        flagEmoji = unicodeString
                                    }
                                    
                                    let country = Country(name: common, countryCode: cca2, flagEmoji: flagEmoji, flagImageUrl: flagURL)
                                    updatedCountries.append(country)
                                }
                            }
                        }
                        
                        // Actualizar la propiedad countries directamente
                        DispatchQueue.main.async {
                            self.countries = updatedCountries.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
                        }
                    } else {
                        print("No se pudieron obtener los valores del JSON.")
                        // También puedes manejar el caso de error actualizando countries si es necesario
                        DispatchQueue.main.async {
                            self.countries = DefaultCountries.countries
                        }
                    }
                } catch {
                    // Manejar errores de decodificación
                    print("Error al decodificar el JSON: \(error)")
                    DispatchQueue.main.async {
                        self.countries = DefaultCountries.countries
                    }
                }
            } else {
                // Si hay un error al realizar la solicitud, utiliza los países predeterminados
                DispatchQueue.main.async {
                    self.countries = DefaultCountries.countries
                }
            }
        }.resume()
    }
}

/*
CountryService.shared.getCountriesData { countries in
    // Utilizar el array de países (por ejemplo, mostrar en un Picker)
    print(countries)
}
*/






/*
 import Foundation

 struct CountryData: Identifiable {
     var id: String {
         return isoCode
     }

     var isoCode: String
     var name: String
     var flag: String
 }

 class CountriesData {
     var countries: [CountryData] = []

     init() {
         for code in NSLocale.isoCountryCodes {
             let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
             let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
             let flag = String.emojiFlag(for: code) ?? ""

             let countryData = CountryData(isoCode: code, name: name, flag: flag)
             countries.append(countryData)
         }
     }
 }
 
 extension String {

     static func emojiFlag(for countryCode: String) -> String! {
         func isLowercaseASCIIScalar(_ scalar: Unicode.Scalar) -> Bool {
             return scalar.value >= 0x61 && scalar.value <= 0x7A
         }

         func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
             precondition(isLowercaseASCIIScalar(scalar))

             // 0x1F1E6 marks the start of the Regional Indicator Symbol range and corresponds to 'A'
             // 0x61 marks the start of the lowercase ASCII alphabet: 'a'
             return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))!
         }

         let lowercasedCode = countryCode.lowercased()
         guard lowercasedCode.count == 2 else { return nil }
         guard lowercasedCode.unicodeScalars.reduce(true, { accum, scalar in accum && isLowercaseASCIIScalar(scalar) }) else { return nil }

         let indicatorSymbols = lowercasedCode.unicodeScalars.map({ regionalIndicatorSymbol(for: $0) })
         return String(indicatorSymbols.map({ Character($0) }))
     }
 }
 
 // Uso de la clase CountriesData
 let countriesData = CountriesData()
 print(countriesData.countries)
 */
