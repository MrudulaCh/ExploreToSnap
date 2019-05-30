//
//  StoreDataModel.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import Foundation
class StoreDataModel {
    
    var id: String?
    var sName: String?
    var genre: String?
    var description:String?
    var photo:String?
    var lati:Double?
    var longi:Double?
    var website:String?
    var phoneNumber:String?
    var email:String?
    var Address:String?
    var category:String?
    var date:String?
    
    init( name: String?,description:String?,photo:String?,lati:Double?,longi:Double?,website:String?,phoneNumber:String?,email:String?,Address:String?,category:String?,date:String?){
        self.sName = name
        self.description = description
        self.photo = photo
        self.lati = lati
        self.longi = longi
        self.website = website
        self.phoneNumber = phoneNumber
        self.email = email
        self.Address = Address
        self.category = category
        self.date = date
    }
}
