//
//  ImagePicker.swift
//  EmojiArt
//
//  Created by 张艺哲 on 2021/1/18.
//

import SwiftUI
import UIKit

typealias PickImageHandle = (UIImage?) -> Void

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType : UIImagePickerController.SourceType
    var handlePickImage : PickImageHandle
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickImage: handlePickImage)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var handlePickImage : PickImageHandle
        
        init(handlePickImage: @escaping PickImageHandle) {
            self.handlePickImage = handlePickImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            handlePickImage(info[.originalImage] as? UIImage)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickImage(nil)
        }
        
    }
}
