//
//  ButtonSaveTextComponentView.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 27/1/24.
//

import SwiftUI

struct ButtonSaveTextComponentView: View {
    
    let label: String
    let isButtonDisabled: Bool
    
    var body: some View {
        
        Text(label)
            //.foregroundColor(isButtonDisabled ? Color.white.opacity(0.5) : Color.white)
            //.frame(maxWidth: .infinity)
            //.padding()
            //.background(isButtonDisabled ? Color.gray : Color.blue)
            //.cornerRadius(10)
    }
}
