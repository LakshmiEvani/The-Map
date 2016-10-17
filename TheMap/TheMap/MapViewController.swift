//
//  MapViewController.swift
//  TheMap
//
//  Created by Souji on 7/19/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Outlets
    
    @IBOutlet var mapView: MKMapView!
    
    // Properties
    var appDelegate: AppDelegate!
    var parseClient =  Parseclient.sharedInstance()
    var client = Client.sharedInstance()
    
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        parseClient.getStudentLocations { (results, error) in
            
            print("Student location results: ", results)
            if error == nil {
                
                var annotations = [MKPointAnnotation]()
                
                for dictionary in results!{
                    
                    
                    
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    
                    if dictionary.longitude != nil && dictionary.longitude != nil {
                        
                        
                        /* Get the lat and lon values to create a coordinate */
                        let lat = CLLocationDegrees(dictionary.latitude)
                        let lon = CLLocationDegrees(dictionary.longitude)
                        let first = dictionary.firstName
                        let last = dictionary.lastName
                        let mediaurl = dictionary.mediaURL
                        
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        let annotation =  MKPointAnnotation()
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaurl
                        
                        // Finally we place the annotation in an array of annotations.
                        annotations.append(annotation)
                    }
                    
                    performUIUpdatesOnMain {
                        // When the array is complete, we add the annotations to the map.
                        self.mapView.addAnnotations(annotations)
                    }
                }
                
            } else {
                
                print("Map downloaded failed")
                
                let alertTitle = "Map Download error"
                let alertMessage = "Map could not download"
                let actionTitle = "OK"
                self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                
            }
            
        }
    }
    
    // Actions
    
    @IBAction func logOut(sender: AnyObject) {
        
        client.logOutSession { (success, error)  in
            
            performUIUpdatesOnMain{
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            mapView.reloadInputViews()
            
        } else {
            
            let alertTitle = "No Internet Connection"
            let alertMessage = "Make sure your device is connected to the internet"
            let actionTitle = "OK"
            showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            
        }
    }
    
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    // Error help function
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}



    