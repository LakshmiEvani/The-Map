//
//  Alerts.swift
//  TheMap
//
//  Created by Souji on 10/18/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
    }
    
    
}