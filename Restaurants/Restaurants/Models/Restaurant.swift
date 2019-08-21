//
//  Restaurant.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import Foundation
import MapKit

class Restaurant: NSObject, NSCoding {
    var name = ""
    var rating = 0
    var comments = ""
    var photoFileName = ""
    var latitude = 0.0
    var longitude = 0.0
    var adresName: String = ""
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        rating = aDecoder.decodeInteger(forKey: "Raiting")
        comments = aDecoder.decodeObject(forKey: "Comments") as! String
        photoFileName = aDecoder.decodeObject(forKey: "PhotoFileName") as! String
        latitude = aDecoder.decodeDouble(forKey: "Latitude" ) //as! CLLocationDegrees
        longitude = aDecoder.decodeDouble(forKey: "Longitude") //as! CLLocationDegrees
    
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(rating, forKey: "Raiting")
        aCoder.encode(comments, forKey: "Comments")
        aCoder.encode(photoFileName, forKey: "PhotoFileName")
        aCoder.encode(latitude, forKey: "Latitude")
        aCoder.encode(longitude, forKey: "Longitude")
    }
    
}
