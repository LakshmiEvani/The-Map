//
//  StudentInfo.swift
//  TheMap
//
//  Created by Souji on 7/13/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation

class StudentInformation {
    
    
    var studentLocation = [StudentLocation]()
  
    static func sharedInstance() -> StudentInformation {
        
        struct Singleton {
            
            static var sharedInstance = StudentInformation()
        }
        return Singleton.sharedInstance
        
    }
    
    }

