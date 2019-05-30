//
//  PlaceAnnotation.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let phoneNumber:String?
    let website:String?
    let photo:AnyObject?
    let des:String?
    var email:String?
    var Address:String?
    var category:String?
  
    init(location: CLLocationCoordinate2D, title: String,phoneNumber:String,website:String,photo:AnyObject,des:String,email:String,Address:String,category:String) {
    self.coordinate = location
    self.title = title
    self.phoneNumber = phoneNumber
    self.website = website
    self.photo = photo
    self.des = des
    self.email = email
    self.Address = Address
    self.category = category
    
    super.init()
  }
}
