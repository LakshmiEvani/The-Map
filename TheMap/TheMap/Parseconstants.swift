//
//  Parseconstants.swift
//  TheMap
//
//  Created by Souji on 8/1/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
extension Parseclient {
    
    //Mark -- Constants
    struct Constants {
        static let ParseApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseBaseSecureURL: String = "https://api.parse.com/1/classes/"
    }
    
    //Mark -- Methods
    struct Methods {
        static let StudentLocation = "StudentLocation"
    }
    
    //Mark -- Parameter Keys
    struct ParameterKeys {
        static let Where = "where"
        static let UniqueKey = "uniqueKey"
    }
    
    //Mark -- JSON Body Keys
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    //Mark -- JSON Response Keys
    struct JSONResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
}