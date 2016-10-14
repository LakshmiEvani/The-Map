//
//  Constants.swift
//  TheMap
//
//  Created by Souji on 7/6/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Constants

extension Client {
    
    
    struct Constants {
        
        // MARK: Udacity baseURL
        
        static let baseURLSecureString = "https://www.udacity.com/api/"
    }
    
    //MARK: -- Methods
    struct Methods{
        static let Session = "session"
        static let Users = "users/"
    }
    
    //MARK: -- JSON Body Keys
    struct JSONBodyKeys {
        static let Username = "username"
        static let Password = "password"
        static let Udacity = "udacity"
    }
    
    //MARK: -- JSON Response Keys
    struct JSONResponseKeys {
        
        //MARK: -- Account
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        
        //MARK: -- Session
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
        
        //MARK: -- User Data
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
        
    }
    
  }