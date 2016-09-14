//
//  LogInViewController.swift
//  TheMap
//
//  Created by Souji on 7/6/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate{
    
    // Outlets
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    
    // Properties
    
    var appDelegate: AppDelegate!
    var client =  Client.sharedInstance()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        email.delegate = self
        passWord.delegate = self
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
    }
    
    // UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func logInButtonAction(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            if (email.text!.isEmpty || passWord.text!.isEmpty) {
                
                let alertTitle = "No username or Password"
                let alertMessage = "Please enter a valid username or password"
                let actionTitle = "OK"
                showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                
            } else {
                
                client.udacityLogIn(email.text!, password: passWord.text!) { (result, error) in
                    
                    performUIUpdatesOnMain{
                        
                        if let userKey = result {
                            
                            self.completeLogin()
                            
                            
                        }
                    }
                }
            }
        } else {
            
            let alertTitle = "No Internet Connection"
            let alertMessage = "Make sure your device is connected to the internet"
            let actionTitle = "OK"
            self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            
        }
    }
    
    // Action Functions
    
    @IBAction func SignUPAction(sender: AnyObject) {
        
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    @IBAction func logInWithFaceBookAction(sender: AnyObject) {
        
        client.faceBookLogin { (success, error)  in
            
            performUIUpdatesOnMain{
                
                
                
            }
        }
        
    }
    
    // Login
    
    
    func completeLogin() {
        
        performSegueWithIdentifier("TabBarController", sender: nil)
        
    }
    
    
    // Error help function
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}

