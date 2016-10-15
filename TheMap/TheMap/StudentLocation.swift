//
//  StudentLocation.swift
//  TheMap
//
//  Created by Souji on 7/14/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation {
    
    var objectId: String!
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    var createdAt: NSDate
    var updatedAt: NSDate
    
    
    init(students : [String:AnyObject]) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.firstName = students[Parseclient.JSONResponseKeys.FirstName] as? String
        self.lastName = students[Parseclient.JSONResponseKeys.LastName] as? String
        self.latitude = students[Parseclient.JSONResponseKeys.Latitude] as? Double
        self.longitude = students[Parseclient.JSONResponseKeys.Longitude] as? Double
        self.mapString = students[Parseclient.JSONResponseKeys.MapString] as? String
        self.mediaURL = students[Parseclient.JSONResponseKeys.MediaURL] as? String
        self.objectId = students[Parseclient.JSONResponseKeys.ObjectID] as? String
        self.uniqueKey = students[Parseclient.JSONResponseKeys.UniqueKey] as! String?
        self.createdAt = dateFormatter.dateFromString((students[Parseclient.JSONResponseKeys.CreatedAt] as? String)!)!
        self.updatedAt = dateFormatter.dateFromString((students[Parseclient.JSONResponseKeys.UpdatedAt] as? String)!)!
    }
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    static func locationsFromDictionaries(dictionaries: [[String:AnyObject]]) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()
        
        for studentDictionary in dictionaries {
            studentLocations.append(StudentLocation(students: studentDictionary))
            let sortedArray = studentLocations.sort() {$0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending}
            
            studentLocations = sortedArray
            
        }
        
        return studentLocations
        
    }
    
    
}