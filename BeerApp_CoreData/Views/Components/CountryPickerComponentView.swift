//
//  CountryPickerComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 26/1/24.
//

import SwiftUI

struct CountryPickerComponentView: View {
    
    @ObservedObject var countryService = CountryService.shared
    @Binding var manufacturerCountry: String
    @Binding var isImported: Bool
    
    var body: some View {
        Picker("Country of Origin", selection: $manufacturerCountry) {
            ForEach(countryService.countries, id: \.self) { (country: Country) in
                Text("\(country.flagEmoji) \(country.name)")
                    .tag(country.countryCode)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: manufacturerCountry) { _ in
            checkImported()
        }
        .onAppear(){
            checkImported()
        }
    }
    
    private func checkImported() {
        print(manufacturerCountry)
        isImported = manufacturerCountry.lowercased() != "es"   //configuration.nationalCountryCode
    }
}
