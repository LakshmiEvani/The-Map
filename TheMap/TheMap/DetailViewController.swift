//
//  DetailViewController.swift
//  TheMap
//
//  Created by Souji on 8/24/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController,MKMapViewDelegate, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationPromptView: UIView!
    
    @IBOutlet weak var studyingLabel: UILabel!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var mapString: UITextField!
    
    @IBOutlet weak var postingMapView: MKMapView!
    @IBOutlet weak var mediaURL: UITextField!
    
    
    //Properties
    
    var appDelegate: AppDelegate!
    var client =  Client.sharedInstance()
    
    var userLocation = [CLPlacemark]()
    
    // Student Location Details
    
    var studentLat = CLLocationDegrees()
    var studentLon = CLLocationDegrees()
    var studentLocationName = ""
    
    
    //Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Delegates Declaration
        mapString.delegate = self
        mediaURL.delegate = self
        
        mapView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        firstView()
        
    }
    
    
    // Actions
    
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        secondView()
        let geocoder = CLGeocoder()
        if let stringToGeocode = mapString.text {
            guard stringToGeocode != "" else {
                
                let alertTitle = "No location provided"
                let alertMessage = "Please enter your location before proceeding"
                let actionTitle = "OK"
                showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                return
            }
            
            let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityView.center = view.center
            activityView.startAnimating()
            view.addSubview(activityView)
            
            /* Make the UI appear disabled */
            
            let views = [cancelButton, studyingLabel, mapString, locationPromptView, findButton]
            
            
            /* Geocode the provided string */
            geocoder.geocodeAddressString(stringToGeocode) { (placemark, error) in
                
                
                
                guard error == nil else {
                    
                    let alertTitle = "No location found"
                    let alertMessage = "There was an error while fetching your location"
                    let actionTitle = "Try Again"
                    
                    performUIUpdatesOnMain {
                        self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                        
                        activityView.stopAnimating()
                    }
                    
                    return
                }
                
                /* Assign the returned location to the userLocation property */
                self.userLocation = placemark!
                
                
                /* Setup the map with the pin coresponding to placemark */
                self.configureMap()
                
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                // Stop the activity spinner
                activityView.stopAnimating()
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitStudentLocation(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            
            guard mediaURL.text != nil else {
                
                let alertTitle = "No URL"
                let alertMessage = "Please enter a url"
                let actionTitle = "OK"
                showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                return
            }
            
            /*guard  UIApplication.sharedApplication().canOpenURL(NSURL(string: mediaURL.text!)!) else {
            let alertTitle = "Invalid URL"
            let alertMessage = "You must enter a valid URL. Ensure you include http:// or https://"
            let actionTitle = "OK"
            self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            return
            }*/
            
            self.postStudentLocation()
            
            /*   client.getUserdata(mediaURL.text!) { (success, error) in
            
            if success {
            
            
            
            } else {
            
            performUIUpdatesOnMain {
            
            let alertTitle = "Couldn't submit your location"
            let alertMessage = "There was an error while trying to post your location to the server."
            let actionTitle = "Try again"
            
            self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            
            }
            }
            }*/
        } else {
            
            let alertTitle = "No Internet Connection"
            let alertMessage = "Make sure your device is connected to the internet"
            let actionTitle = "OK"
            showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            
        }
    }
    
    
    // Help Fuctions
    
    
    func configureMap(){
        
        let topPlacemarkResult = self.userLocation[0]
        let placemarkToPlace = MKPlacemark(placemark: topPlacemarkResult)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemarkToPlace.coordinate
        
        studentLocationName = placemarkToPlace.name!
        
        studentLat = annotation.coordinate.latitude
        studentLon = annotation.coordinate.longitude
        let pinCoordinate = CLLocationCoordinate2DMake(studentLat, studentLon)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(pinCoordinate, span)
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        }
    }
    
    // Function for posting student location
    
    func postStudentLocation() {
        
        ParseClient.sharedInstance().postStudentLocations(udacityLoggedInUser.userId, firstName: udacityLoggedInUser.firstName, lastName: udacityLoggedInUser.lastName, mediaURL: mediaURL.text!, mapString: mapString.text!, longitude: studentLat, latitude: studentLon) { (success, error) in
            
            
            if success {
                
                performUIUpdatesOnMain {
                
                    let tabviews = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as!UITabBarController
                    self.presentViewController(tabviews, animated: false, completion: nil)
                
               
                }
                
            } else {
                
                
                performUIUpdatesOnMain {
                    
                    let alertTitle = "Couldn't submit your location"
                    let alertMessage = "There was an error while trying to post your location to the server."
                    let actionTitle = "Try again"
                    
                    self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
            
        }
    }
    
    
    
    // Configure UI
    
    
    func firstView() {
        
        locationPromptView?.hidden = false
        mapView?.hidden = true
        findButton?.hidden = false
        studyingLabel?.hidden = false
        submitButton?.hidden = true
        
        //Set cursor position in Map String
        
        let newPosition = mapString.beginningOfDocument
        mapString.selectedTextRange = mapString.textRangeFromPosition(newPosition, toPosition: newPosition)
        
        // Added subview and gesture
        
        let singleTap = UITapGestureRecognizer(target: findButton, action: Selector("secondView"))
        singleTap.numberOfTapsRequired = 1
        
        locationPromptView?.addSubview(mapView)
        
        
    }
    
    
    func secondView(){
        
        locationPromptView?.bringSubviewToFront(mapView)
        
        mapView?.hidden = false
        findButton?.hidden = true
        studyingLabel?.hidden = true
        submitButton?.hidden = false
        mapString?.hidden = true
        mediaURL?.hidden = false
        
        //Set cursor position in media Url
        
        let newPosition = mediaURL.beginningOfDocument
        mediaURL.selectedTextRange = mediaURL.textRangeFromPosition(newPosition, toPosition: newPosition)
        
    }
    
    
    // Textfield delegate functions
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    // Error help function
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}