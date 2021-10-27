//
//  VenueModel.swift
//  FourSquareExample
//
//  Created by Jesus Jaime Cano Terrazas on 21/08/21.
//

import Foundation

class VenueModel: Codable{
    var id: String
    var name: String
    var location: LocationModel
    var categories: [Category]
}
