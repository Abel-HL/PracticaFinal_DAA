//
//  ImageProcessor.swift
//  BeerApp_CoreData
//
//  Created by Abel H L on 12/12/23.
//

import Foundation
import UIKit
import SwiftUI
import Compression

struct ImageProcessor {
    
    static func compressImage(_ image: UIImage) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            // Error al obtener los datos de la imagen
            return nil
        }
        let imageSize = Double(imageData.count) / 1000.0 // Tamaño en kilobytes
        print("Image size in kB: \(imageSize)")
        return imageData
    }
    
    static func getImageFromData(_ data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else {
            // Error al crear la imagen desde los datos
            return nil
        }
        return image
    }
}




struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                guard let compressedImage = ImageProcessor.getImageFromData(ImageProcessor.compressImage(selectedImage)!)else{
                    //show error or alert
                    return
                }
                parent.selectedImage = compressedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
