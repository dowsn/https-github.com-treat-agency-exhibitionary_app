//
//  resetPasswordView.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 05/04/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class resetPasswordView: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {
    
    var myNavigationController = UINavigationController()
    var thisScreenBounds = UIScreen.main.bounds
    let thisContentScrollView:UIScrollView = UIScrollView()
    
    let nameLabel = UITextField()
    let lastNameLabel = UITextField()
    let emailLabel = UITextField()
    let passwordLabel = UITextField()
    let passwordCheckLabel = UITextField()
    let subscribeSwitch = UISwitch()
    var keyboardSize:CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var thisDarkener = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thisDarkener.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
        thisDarkener.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
        thisIndicator.frame = CGRect(x: self.thisScreenBounds.width/2-10, y: self.thisScreenBounds.height/2-10, width: 20, height: 20)
        thisIndicator.startAnimating()
        thisDarkener.addSubview(thisIndicator)
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        self.view.backgroundColor = UIColor.black
        
        self.automaticallyAdjustsScrollViewInsets = false
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height-64)
        thisContentScrollView.isScrollEnabled = true
        
        let welcomeTextLabel = UILabel(frame: CGRect(x: 20, y: 40, width: thisScreenBounds.width-40, height: 100))
        welcomeTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        welcomeTextLabel.numberOfLines = 10
        welcomeTextLabel.font = UIFont(name: "Apercu-Regular", size: 18)
        welcomeTextLabel.textColor = UIColor.white
        welcomeTextLabel.textAlignment = NSTextAlignment.center
        welcomeTextLabel.text = "Please provide your email adress to reset your password.";
        
        thisContentScrollView.addSubview(welcomeTextLabel)
        
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = CGRect(x: 0, y: 0, width: thisScreenBounds.width-40, height: 75)
        rectShape1.position = CGPoint(x: thisScreenBounds.width/2, y: welcomeTextLabel.frame.maxY+50)
        rectShape1.cornerRadius = 10
        rectShape1.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
        
        thisContentScrollView.layer.addSublayer(rectShape1)
        
        
        emailLabel.frame = CGRect(x: 50, y: welcomeTextLabel.frame.maxY+50, width: thisScreenBounds.width-100, height: 22)
        
        //emailLabel.layer.addSublayer(createLine(emailLabel.frame.width, desiredY: 20))
        emailLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        emailLabel.textColor = UIColor.white
        emailLabel.textAlignment = NSTextAlignment.left
        emailLabel.autocapitalizationType = UITextAutocapitalizationType.none
        emailLabel.delegate = self
        
        thisContentScrollView.addSubview(emailLabel)
        
        
        let submitButton = UILabel(frame: CGRect(x: 20, y: emailLabel.frame.maxY+50, width: thisScreenBounds.width-40, height: 70))
        submitButton.font = UIFont(name: "Apercu-Bold", size: 18)
        submitButton.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 10
        submitButton.layer.backgroundColor = UIColor.white.cgColor
        submitButton.text = "RESET"
        submitButton.isUserInteractionEnabled = true
        
        let registerButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registerViewController.registerButtonTapped))
        submitButton.addGestureRecognizer(registerButtonTap)
        
        thisContentScrollView.addSubview(submitButton)
        
        
        self.view.addSubview(thisContentScrollView)
    }
    
    func registerButtonTapped() {
        registerPerson()
    }
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func registerPerson() {
        dismissKeyboard()
        
        if (emailLabel.text == "") {
            displayOKMessageError("Forgot something? Please enter an email address?")
            return
        } else {
            let thisText = isValidEmail(emailLabel.text!)
            if (thisText == false) {
                displayOKMessageError("Forgot something? Please enter an email address?")
                return
            }
            
        }
        
        let thisUrl = globalData.globalUrl + "reset_password"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        let postString = "email="+emailLabel.text!
        
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        self.view.addSubview(thisDarkener)
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            print(String(data: data, encoding: String.Encoding.utf8))
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
                        if let sessionJson = response["status"] as? Array<AnyObject>{
                            //let thisID = sessionJson[0]["id"] as! Int
                            let thisStatus = sessionJson[0]["status"] as! String
                            if (thisStatus == "FAIL") {
                                DispatchQueue.main.async {
                                    self.displayOKMessageError("An error occured, please try again")
                                    self.thisDarkener.removeFromSuperview()
                                }
                                return
                            }
                            
                            if (thisStatus == "EMAIL") {
                                DispatchQueue.main.async {
                                    self.displayOKMessageError("This address is not registered.")
                                    self.thisDarkener.removeFromSuperview()
                                }
                                return
                            }
                            
                            if (thisStatus == "OK") {
                                DispatchQueue.main.async {
                                    self.registrationDone()
                                    self.thisDarkener.removeFromSuperview()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func registrationDone () {
        let thisMessage = "Ok, we’re on it! An email to reset your password is coming your way."
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            self.closeRegistration()
            })
        self.present(failureMessage, animated: true, completion: nil)
        
    }
    
    func closeRegistration () {
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //KEYBOARD STUFF
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTrack("Forgot", parameter: "")
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterForKeyBoardNotification()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userRearViewController.keyboardWasShown(_:)), name:  UIResponder.keyboardDidShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(userRearViewController.keyboardWasHidden(_:)), name:  UIResponder.keyboardDidShowNotification, object: nil);
        
        

    }
    
    func deregisterForKeyBoardNotification() {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardDidShowNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    
    func keyboardWasHidden(_ notification : Notification) {
        thisContentScrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        thisContentScrollView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    func keyboardWasShown(_ notification : Notification ) {
        
        let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        thisContentScrollView.contentInset = contentInsets
        thisContentScrollView.scrollIndicatorInsets = contentInsets
        
        UIView.commitAnimations()
        
    }
    
    func dismissKeyboard () {
        //thisContentScrollView.resignFirstResponder()
        for thisview in thisContentScrollView.subviews {
            if (thisview.isFirstResponder) {
                thisview.resignFirstResponder()
            }
        }
    }
    
}
