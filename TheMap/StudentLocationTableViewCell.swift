//
//  StudentLocationTableViewCell.swift
//  TheMap
//
//  Created by Souji on 9/6/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
import UIKit

// MARK: - StudentLocationTableViewCell: UITableViewCell

class StudentLocationTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    // Configure UI
    
    func configureWithStudentLocation(studentLocation: StudentInformation) {
        pinImageView.image = UIImage(named: "Pin")
        nameLabel.text = studentLocation.firstName
        urlLabel.text = studentLocation.lastName
    }
}
