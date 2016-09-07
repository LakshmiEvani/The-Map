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
        
        if (email.text!.isEmpty || passWord.text!.isEmpty) {
            
            loginLabel.text = "Username or Password field are empty"
        } else {
            
            client.udacityLogIn(email.text!, password: passWord.text!, CompletionHandler: { (result, error) in
                
                performUIUpdatesOnMain{
                    
                    if let userKey = result {
                        
                        self.completeLogin()
                        
                    }
                }
            })
            
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
        
        //let controller = storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UINavigationController
        // presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    
}

