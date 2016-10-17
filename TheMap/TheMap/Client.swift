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
    var userID : String? = nil
    
    
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
                
                
                Client.parseJSONWithCompletionHandler(newData) { (result,error) in
                    
                    guard error == nil else {
                        
                        let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                        CompletionHandler(result: nil, error: NSError(domain: "Invalid credentials", code: 1, userInfo: userInfo ))
                        return
                    }
                    
                    if let parsedResult = result as? NSDictionary {
                        print("parsed Results:",parsedResult)
                        
                        if let parsedError = parsedResult["error"] as? String {
                            performUIUpdatesOnMain {
                                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(parsedError)"]
                                CompletionHandler(result: nil, error: NSError(domain: "Invalid credentials", code: 1, userInfo: userInfo ))
                            }
                        } else {
                            
                            print("parsed Results:",parsedResult)
                            
                            let accountInfo = parsedResult["account"] as? NSDictionary
                            let userInfo = accountInfo!["key"] as? String
                            let jsonSession = parsedResult["session"] as? NSDictionary
                            let sessionID = jsonSession!["id"] as? String
                            
                            self.sessionID = sessionID
                            self.userID = userInfo
                            
                            print("The session_id is: ", sessionID)
                            print("The userId is: ",userInfo)
                            self.getUserdata(self.userID!) { (success, error) in
                                
                                CompletionHandler(result: self.userID, error: nil)
                                
                            }
                        }
                        
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
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/5404309077")!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error...
                
                completionHandler(success: false, error: error)
                
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
                
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData(newData,options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    
                    // login succeeded, parse the data
                    let userData = result["user"] as! NSDictionary
                    let firstName = userData["first_name"] as! String
                    let lastName = userData["last_name"] as! String
                    UdacityLoggedInUser.firstName = firstName
                    UdacityLoggedInUser.lastName = lastName
                    
                    completionHandler(success: true, error: nil)
                    
                    
                } catch { completionHandler(success: false, error: NSError(domain: "getStudentLocations", code: 0, userInfo:  [NSLocalizedDescriptionKey: "No records found"])) }
                
                
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





















