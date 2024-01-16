//
//  AppDelegate.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 13/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import UIKit
import GoogleMaps


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sessionUserID: String = ""
    var sessionUserMail:String = ""
    var sessionID: String = ""
    var userPass:String = ""
    var settingFBLogin:Bool = false
    var data: NSMutableData = NSMutableData()
    var thisCityID:Int = 0
    var thisCityLong:String = ""
    var thisCityLat:String = ""
    var thisCityAbbr:String = ""

    var thisProfileName = ""
    var thisProfileURL = ""
    var thisProfileDesc = ""
    var thisProfileAC = ""
    var isEditor = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDLFU9114EMr-gpOlqRDarClSc_sIVjY4A")
        
        let userDefaults = UserDefaults.standard
        let thisEmail: AnyObject? = userDefaults.object(forKey: "usermail") as AnyObject?
        let thisPassword: AnyObject? = userDefaults.object(forKey: "password") as AnyObject?
        let thisSessionUserID = userDefaults.object(forKey: "userid") as AnyObject?
        if (thisSessionUserID != nil) {
            sessionUserID = (userDefaults.string(forKey: "userid") as String?)!
        } else {
            
        }
        let thisCityIDCheck = userDefaults.object(forKey: "thisCityID") as AnyObject?
        let thisCityAbbrCheck = userDefaults.object(forKey: "abbr") as AnyObject?
        if (thisCityIDCheck != nil) {
            thisCityID = userDefaults.integer(forKey: "thisCityID")
            if (thisCityAbbrCheck != nil) {
                thisCityAbbr = userDefaults.string(forKey: "abbr")!
            } else {
                //thisCityAbbr = "CITY"
            }
        } else {
        
        }
        
        let thisThisCityLong = userDefaults.string(forKey: "thisCityLon") as AnyObject?
        let thiThisCityLat = userDefaults.string(forKey: "thisCityLat") as AnyObject?
        
        if (thisThisCityLong != nil && thiThisCityLat != nil) {
            thisCityLong = thisThisCityLong as! String
            thisCityLat = thiThisCityLat as! String
        }
        
        
        if (thisEmail != nil && thisPassword != nil) {
            let thisUserEmail = thisEmail as! String
            let thisUserPW = thisPassword as! String
            login(thisUserEmail, password: thisUserPW)
        }
        
//        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//        
//        if (FBSDKAccessToken.current() != nil) {
//            
//            let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: ["fields": "id, name, first_name, last_name, email"]);
//            
//            fbRequest?.start(completionHandler: {(connection, result, error) in
//                let fbResult = result as! Dictionary<String, AnyObject>
//                    if error == nil {
//                        let thisToken = FBSDKAccessToken.current().tokenString
//                        //let thisToken = result.valueForKey("token") as! String
//                        let thisEmail = fbResult["email"] as! String
//                        let thisFBID = fbResult["id"] as! String
//                        self.createFBLogin(thisEmail, token: thisToken!, fb_id: thisFBID)
//                        let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//                        thisAppDelegate.settingFBLogin = true
//                    } else {
//                        print("Error Getting Info \(error)");
//                    }
//                })
//            }
        
        // new
        return true
    }
    
    func httpGet(_ request: URLRequest!, callback: @escaping (Data, String?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                callback(Data(), error!.localizedDescription)
            } else {
                callback(data!, nil)
            }
        })
        task.resume()
    }
    
    func createFBLogin(_ email:String, token:String, fb_id:String) {
        let thisUrl = globalData.globalUrl + "loginUserFB"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "fb_id="+fb_id+"&"
        postString = postString + "token="+token+"&"
        postString = postString + "email="+email
        let thisMail = email
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        
        httpGet(request as? URLRequest){
            (data, error) -> Void in
            
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                let jsonOptional: Any!
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch _ as NSError {
                    //jsonErrorOptional = error
                    jsonOptional = nil
                }
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    
                    if let response:AnyObject = json["response"] as AnyObject? {
                        
                        let thisError = response["error"] as! String
                        //let thisID = response["id"] as! Int
                        let thisSessionID = response["session_id"] as! String
                        let thisStatus = response["status"] as! String
                        let thisUserID = response["user_id"] as! String
                        
                        self.thisProfileName = response["full_name"] as! String
                        self.thisProfileURL = response["profile_img"] as! String
                        self.thisProfileDesc = response["description"] as! String
                        self.thisProfileAC = response["active_cities"] as! String
                        self.isEditor = response["share_public"] as! String
                        
                        
                        if (thisStatus == "FAIL") {
                            DispatchQueue.main.async {
                                //self.displayOKMessageError(thisError)
                                let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            }
                            return
                        }
                        if (thisStatus == "OK") {
                            DispatchQueue.main.async {
                                
                            let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            thisAppDelegate.sessionUserID = thisUserID
                            thisAppDelegate.sessionID = thisSessionID
                            //thisAppDelegate.userPass = password
                            thisAppDelegate.sessionUserMail = email
                            
                            
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(thisUserID as String, forKey: "userid")
                            userDefaults.set(thisMail as String, forKey: "usermail")
                            //userDefaults.setObject(self.passwordField.text! as String, forKey: "password")
                            
                            thisAppDelegate.thisProfileName = self.thisProfileName
                            thisAppDelegate.thisProfileURL = self.thisProfileURL
                            thisAppDelegate.thisProfileDesc = self.thisProfileDesc
                            thisAppDelegate.thisProfileAC = self.thisProfileAC
                            thisAppDelegate.isEditor = self.isEditor

                                
                            thisAppDelegate.settingFBLogin = false
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        // new
        return true
//        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let userDefaults = UserDefaults.standard
        let thisEmail: AnyObject? = userDefaults.object(forKey: "usermail") as AnyObject?
        let thisPassword: AnyObject? = userDefaults.object(forKey: "password") as AnyObject?
        
        
        if (thisEmail != nil) {
            let thisUserEmail = thisEmail as! String
            let thisUserPW = thisPassword as! String
            login(thisUserEmail, password: thisUserPW)
        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func login(_ email: String, password: String) {
        
        
        let thisUrl = globalData.globalUrl + "login"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "username="+email+"&"
        postString = postString + "password="+password
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                let jsonOptional: Any!
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch _ as NSError {
                    //jsonErrorOptional = error
                    jsonOptional = nil
                }
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    
                    if let response:AnyObject = json["response"] as AnyObject? {
                        
                        let thisError = response["error"] as! String
                        //let thisID = response["id"] as! Int
                        let thisSessionID = response["session_id"] as! String
                        let thisStatus = response["status"] as! String
                        let thisUserID = response["user_id"] as! String
                        
                        self.thisProfileName = response["full_name"] as! String
                        self.thisProfileURL = response["profile_img"] as! String
                        self.thisProfileDesc = response["description"] as! String
                        self.thisProfileAC = response["active_cities"] as! String
                        self.isEditor = response["share_public"] as! String
                        
                        if (thisStatus == "FAIL") {
                            DispatchQueue.main.async {
                                
                            }
                            return
                        }
                        if (thisStatus == "OK") {
                            let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            thisAppDelegate.sessionUserID = thisUserID
                            thisAppDelegate.sessionID = thisSessionID
                            thisAppDelegate.userPass = password
                            thisAppDelegate.sessionUserMail = email
                            
                            thisAppDelegate.thisProfileName = self.thisProfileName
                            thisAppDelegate.thisProfileURL = self.thisProfileURL
                            thisAppDelegate.thisProfileDesc = self.thisProfileDesc
                            thisAppDelegate.thisProfileAC = self.thisProfileAC
                            thisAppDelegate.isEditor = self.isEditor
                            
                        }
                    }
                }
            }
        }
        
    }

}

