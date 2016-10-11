//
//  Client.swift
//  TheMap
//
//  Created by Souji on 7/14/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation
class Client: NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID: String? = nil
    var studentLocations = [StudentLocation]()
    var userID : Int? = nil
    
    /* Initializer */
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    /* Get */
    
    func udacityLogIn(username: String, password: String, CompletionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error
                CompletionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                

                Client.parseJSONWithCompletionHandler(newData) { (result, error) in
                    
                    let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
                    
                    if let result = result {
                        
                        let data = result["user"] as? [String: AnyObject]
                        
                        if let data = data {
                            
                            if let firstName = (data["first_name"] as? String), lastName = (data["last_name"] as? String){
                                
                                let dic:[String: AnyObject] = ["firstName": firstName, "lastName":lastName]
                                
                                CompletionHandler(result: dic, error: error)
                                
                            } else {
                                
                                CompletionHandler(result: nil, error: NSError(domain: "Unable to get user's name", code: 1, userInfo: userInfo))
                                
                            }
                            
                        } else {
                            
                            CompletionHandler(result: nil, error: NSError(domain: "Unable to get user data", code: 1, userInfo: userInfo))
                        }
                        
                    } else {
                        
                        CompletionHandler(result: nil, error: NSError(domain: "Unable to parse data", code: 1, userInfo: userInfo))
                    }

                    
                }
                    
                    
            }
            /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
        }
        
        task.resume()
        
        return task
        
    }
    
    
    func logOutSession(completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                completionHandler(result: newData, error: nil)
                
            }
            //  print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task
        
    }
    
    
    func getUserdata(uniqueKey: String, completionHandler:(success: Bool, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/3903878747")!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error...
                
                completionHandler(success: false, error: error)
                
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
             
                
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData(newData,options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    
                    ParseClient.sharedInstance().updateStudentLocation(uniqueKey, jsonBody: result as! [String : AnyObject]) { (success, error) in
                        
                        
                    if let results = result["results"] as? [[String: AnyObject]] {
                        
                        
                        self.studentLocations = StudentLocation.locationsFromDictionaries(results)
                        StudentInformation.sharedInstance().studentLocation = self.studentLocations
                        completionHandler(success: true, error: nil)
                    
                        
                    } else {
                        
                        completionHandler(success: false, error: error)
                    }
                }
                    
                }
                
                catch { completionHandler(success: false, error: NSError(domain: "getStudentLocations", code: 0, userInfo:  [NSLocalizedDescriptionKey: "No records found"])) }
                
                
            }
            // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task
    }
    
    func faceBookLogin(completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"DADFMS4SN9e8BAD6vMs6yWuEcrJlMZChFB0ZB0PCLZBY8FPFYxIPy1WOr402QurYWm7hj1ZCoeoXhAk2tekZBIddkYLAtwQ7PuTPGSERwH1DfZC5XSef3TQy1pyuAPBp5JJ364uFuGw6EDaxPZBIZBLg192U8vL7mZAzYUSJsZA8NxcqQgZCKdK4ZBA2l2ZA6Y1ZBWHifSM0slybL9xJm3ZBbTXSBZCMItjnZBH25irLhIvbxj01QmlKKP3iOnl8Ey;\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                completionHandler(result: newData, error: nil)
                
            }
            
            // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task
    }
    
    
    func taskForGetMethod(method: String, completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build and configure GET request */
        
        let loginURL = Constants.baseURLSecureString
        let url = NSURL(string: loginURL)
        let request = NSMutableURLRequest(URL: url!)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            
            /* GUARD: Was there an error */
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your Request returned an invalid respons! Status code: \(response.statusCode)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* Parse and use data */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            Client.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        //start the request
        task.resume()
        return task
        
    }
    
    /* Post */
    func taskForPostMethod(method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build and configure Post request */
        let urlString = Constants.baseURLSecureString + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForPostMethod'", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            /* Parse and use data */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            Client.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    /* Delete */
    func taskForDeleteMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = Constants.baseURLSecureString + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]!{
            if cookie.name == "XSRF-Token"{ xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                completionHandler(result: nil, error: NSError(domain: "taskForDeletetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForDeleteMethod'", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                return
            }
            /* Parse and use data */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            Client.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
        
        
    }
    
    
    //func loginWithFacebook
    
    
    /* Given raw JSON, return a useable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void){
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            
                   } catch {
            
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Share Instance */
    class func sharedInstance() -> Client{
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
    
    
}





















