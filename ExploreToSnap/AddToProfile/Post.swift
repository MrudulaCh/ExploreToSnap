//
//  Post.swift
//  FirebasePhotos
//
//  Created by Mrudula on 5/28/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import CoreLocation

class Post {
    private var image: UIImage!
    var caption: String!
    var downloadURL: String?
    var latitude:Double = Double()
    var longitude:Double = Double()
    
    init(image: UIImage, caption: String,latitude: Double, longitude: Double) {
        self.image = image
        self.caption = caption
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(snapshot: DataSnapshot) {
        let json = JSON(snapshot.value)
        self.caption = json["description"].stringValue
        self.downloadURL = json["photo"].string
    }
    
    
    func save() {
        
        let newPostRef = Database.database().reference().child("photographyplaces").childByAutoId()
        let newPostKey = newPostRef.key
        
        // 1. save image
        if let imageData = UIImageJPEGRepresentation(self.image, 0.6) {
            let imageStorageRef = Storage.storage().reference().child("images")
            let newImageRef = imageStorageRef.child(newPostKey)
            
            let metaData = StorageMetadata()
           metaData.contentType = "image/jpg"
            
            
            newImageRef.putData(imageData, metadata: metaData) { metaData, error in
                if error == nil, metaData != nil {
                    
                    newImageRef.downloadURL { url, error in
                       self.downloadURL = url?.absoluteString
                        let postDictionary: [String:AnyObject] = [
                            "lati" : self.latitude as AnyObject,
                            "longi" : self.longitude as AnyObject,
                            "category" : "San Francisco" as AnyObject,
                            "photo" : self.downloadURL as AnyObject,
                            "description" : self.caption as AnyObject
                        ]
                        newPostRef.setValue(postDictionary)
                    }
                } else {
                    
                }
            }
            
        
        }
    }
}











