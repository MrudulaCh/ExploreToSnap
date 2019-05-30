//
//  ImageUploadManager.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import UIKit
import FirebaseStorage
import Firebase
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct Constants {
    
    struct Car {
        static let imagesFolder: String = "storeImages"
    }
    
}

class ImageUploadManager: NSObject {
    
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Float) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imagesReference = storageReference.child(Constants.Car.imagesFolder).child(imageName)
        
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imagesReference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
               storageReference.downloadURL(completion: { (url, error) in
                    
                    
                    if error != nil {
                        print("Failed to download url:", error!)
                        return
                    }
                    else {
                        completionBlock(nil, error?.localizedDescription)
                }
            
                })
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                
                let percentage = (Float(progress.completedUnitCount) / Float(progress.totalUnitCount)) * 100
                progressBlock(percentage)
            })
        } else {
            completionBlock(nil, "Image couldn't be converted to Data.")
        }
    }
    
}
