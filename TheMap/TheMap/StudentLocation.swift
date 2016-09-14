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
    
    
    static var studentLocation = [StudentLocation]()
    
    init(students : [String:AnyObject]) {
        
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.firstName = students[ParseClient.JSONResponseKeys.FirstName] as? String
        self.lastName = students[ParseClient.JSONResponseKeys.LastName] as? String
        self.latitude = students[ParseClient.JSONResponseKeys.Latitude] as? Double
        self.longitude = students[ParseClient.JSONResponseKeys.Longitude] as? Double
        self.mapString = students[ParseClient.JSONResponseKeys.MapString] as? String
        self.mediaURL = students[ParseClient.JSONResponseKeys.MediaURL] as? String
        self.objectId = students[ParseClient.JSONResponseKeys.ObjectID] as? String
        self.uniqueKey = students[ParseClient.JSONResponseKeys.UniqueKey] as! String?
        self.createdAt = dateFormatter.dateFromString((students[ParseClient.JSONResponseKeys.CreatedAt] as? String)!)!
        self.updatedAt = dateFormatter.dateFromString((students[ParseClient.JSONResponseKeys.UpdatedAt] as? String)!)!
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