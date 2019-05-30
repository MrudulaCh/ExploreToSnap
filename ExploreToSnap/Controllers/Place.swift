//
//  Place.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import Foundation
import CoreLocation

class Place: ARAnnotation {
  let reference: String
  let placeName: String
  let des: String
  var phoneNumber: String?
  var website: String?
  var  photo:AnyObject?
    var email:String?
    var Address:String?
    var category:String?
    var newlati:Double
    var newlong:Double
    
  var infoText: String {
    get {
      var info = "Info: \(des)"
      
      if phoneNumber != nil {
        info += "\nPhone: \(phoneNumber!)"
      }
      
      if website != nil {
        info += "\nweb: \(website!)"
      }
      return info
    }
  }
  
    init(location: CLLocation, reference: String, name: String, des: String, website:String,phoneNumber:String,photo:AnyObject,email:String,Address:String,category:String,newlati:Double,newlong:Double) {
    placeName = name
    self.reference = reference
    self.phoneNumber = phoneNumber
    self.website = website
    self.photo = photo
    self.des = des
    self.email = email
    self.Address = Address
    self.category = category
        self.newlati = newlati
        self.newlong = newlong
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let loc: CLLocation = CLLocation(latitude:newlati, longitude: newlong)

        
        super.init(identifier: category, title: placeName, location: loc)!
            self.location = location
    
  }
  
  override var description: String {
    return placeName
  }
}
