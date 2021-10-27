//
//  LocationModel.swift
//  FourSquareExample
//
//  Created by Jesus Jaime Cano Terrazas on 21/08/21.
//

import Foundation

class LocationModel: Codable {
    
//    var address = ""
    var latitude: Double
    var longitude: Double
//    var crossStreet: String
    var distance: Int
//    var zip: Int
    var cc: String
//    var city: String
//    var state: String
    var country: String
    
    enum CodingKeys: String, CodingKey {
//        case address
        case latitude = "lat"
        case longitude = "lng"
//        case crossStreet
        case distance
//        case zip = "postalCode"
        case cc
//        case city
//        case state
        case country
    }
}
