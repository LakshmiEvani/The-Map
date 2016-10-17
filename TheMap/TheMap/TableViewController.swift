//
//  TableViewController.swift
//  TheMap
//
//  Created by Souji on 8/19/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    //Outlets
    
    @IBOutlet var studentTableView: UITableView!
    
    // Properties
    
    var appDelegate: AppDelegate!
    
    var client =  Client.sharedInstance()
    
    var parseClient = Parseclient.sharedInstance()
    
    // Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        studentTableView?.dataSource = self
        studentTableView?.delegate = self
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        parseClient.getStudentLocations { (results, error) in
            
            performUIUpdatesOnMain {
                
                for result in results! {
                    
                    self.studentLocationUpdate()
                    
                }
                
            }
            
        }
    }
    
    // Action Functions
    
    @IBAction func logOut(sender: AnyObject) {
        
        client.logOutSession { (success, error)  in
            
            performUIUpdatesOnMain{
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        
        studentTableView!.reloadData()
        
    }
    
    func studentLocationUpdate() {
        
        studentTableView!.reloadData()
    }
    
    
    
    //Function for defining the contents for each row
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("No of records in the array",StudentInformation.sharedInstance().studentLocation.count )
        return StudentInformation.sharedInstance().studentLocation.count
      
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        studentTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "studentCell")
        let cell = studentTableView.dequeueReusableCellWithIdentifier("StudentLocationTableViewCell") as! StudentLocationTableViewCell
        let location = StudentInformation.sharedInstance().studentLocation[indexPath.row]
        cell.configureWithStudentLocation(location)
        cell.textLabel?.text = location.firstName + "" + location.lastName
        cell.detailTextLabel!.text = location.mediaURL
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let app = UIApplication.sharedApplication()
        
        let location = StudentInformation.sharedInstance().studentLocation[indexPath.row]
        let url = location.mediaURL
        
        app.openURL(NSURL(string: url)!)
        
    }
    
}