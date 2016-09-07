//
//  StudentInfo.swift
//  TheMap
//
//  Created by Souji on 7/13/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation

class StudentInformation {
    
    
    private static var sharedInstance = StudentInformation()
    
    static func sharedClient() -> StudentInformation {
        return sharedInstance
    }
    
    var firstName: String!
    var lastName: String!
    var currentUserId : String!
    var mediaURL: String!
    
}

