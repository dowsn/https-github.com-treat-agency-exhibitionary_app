//
//  registerViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 28/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class registerViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var myNavigationController = UINavigationController()
    var thisScreenBounds = UIScreen.main.bounds
    let thisContentScrollView:UIScrollView = UIScrollView()
    let thisContentHolder:UIView = UIView()
    
    let nameLabel = UITextField()
    let lastNameLabel = UITextField()
    let emailLabel = UITextField()
    let passwordLabel = UITextField()
    let passwordCheckLabel = UITextField()
    let subscribeSwitch = UISwitch()
    let roleLabel = UILabel()
    var keyboardSize:CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var rolePickerSelectorView:UIView = UIView();
    var rolePicker:UIPickerView = UIPickerView()
    var roleArray:[String] = ["Art Collector", "Dealer/Gallerist", "Art Advisor", "Museum Professional", "Curator", "Non-Profit Art Professional", "Artist", "Other"]
    var thisSelectedRole = ""
    
    
    // Called just before UITextField is edited
       func textFieldDidBeginEditing(_ textField: UITextField) {
           print("textFieldDidBeginEditing: \((textField.text) ?? "Empty")")
       }
       
       // Called immediately after UITextField is edited
//    private func textFieldDidEndEditing(_ textField: UITextField) {
//           print("textFieldDidEndEditing: \((textField.text) ?? "Empty")")
//       }
//       
//       // Called when the line feed button is pressed
//    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//           print("textFieldShouldReturn \((textField.text) ?? "Empty")")
//           
//           // Process of closing the Keyboard when the line feed button is pressed.
//           textField.resignFirstResponder()
//           
//           return true
//       }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Apercu-Bold", size: 12)!]
        //self.navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Apercu-Regular", size: 12)!], forState: UIControlState.Normal)
        
        //let newWidth = thisScreenBounds.width - thisScreenBounds.width/3
        //thisScreenBounds = CGRectMake(thisScreenBounds.minX, thisScreenBounds.maxY, newWidth, thisScreenBounds.height)
        self.view.isExclusiveTouch = false
        self.automaticallyAdjustsScrollViewInsets = false
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
        thisContentScrollView.isScrollEnabled = true
        
        thisContentHolder.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
        
        let welcomeTextLabel = UILabel(frame: CGRect(x: 50, y: 50, width: thisScreenBounds.width-40, height: 22))
        welcomeTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        welcomeTextLabel.numberOfLines = 4
        welcomeTextLabel.font = UIFont(name: "Apercu-Regular", size: 18)
        welcomeTextLabel.textColor = UIColor.white
        welcomeTextLabel.textAlignment = NSTextAlignment.left
        welcomeTextLabel.text = "Register to save your own picks!";
        
        thisContentHolder.addSubview(welcomeTextLabel)
        
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = CGRect(x: 0, y: 0, width: thisScreenBounds.width-40, height: 420)
        rectShape1.position = CGPoint(x: thisScreenBounds.width/2, y: welcomeTextLabel.frame.maxY+170)
        rectShape1.cornerRadius = 4
        rectShape1.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
        
        self.thisContentScrollView.layer.addSublayer(rectShape1)
        
        nameLabel.frame = CGRect(x: 50, y: welcomeTextLabel.frame.maxY+25, width: thisScreenBounds.width-100, height: 22)
        nameLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.delegate = self
        
        
        let nameLabelAttirbutedPalceHolderText = NSAttributedString(string: "Your First Name", attributes: [NSAttributedString.Key.font: UIFont(name: "Apercu-Regular", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        nameLabel.attributedPlaceholder = nameLabelAttirbutedPalceHolderText
        
        let width = CGFloat(1)
        
        let border = CALayer()
        border.frame = CGRect(x: -50, y: nameLabel.frame.size.height + 10 - width, width:  thisScreenBounds.width, height: 1)
        border.borderWidth = width
        nameLabel.layer.addSublayer(border)
        
        thisContentHolder.addSubview(nameLabel)
        
        lastNameLabel.frame = CGRect(x: 50, y: nameLabel.frame.maxY+25, width: thisScreenBounds.width-100, height: 22)
        
        lastNameLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        lastNameLabel.textColor = UIColor.white
        lastNameLabel.textAlignment = NSTextAlignment.left
        lastNameLabel.text = ""
        lastNameLabel.delegate = self
        
//        let lastNameLabelAttirbutedPalceHolderText = NSAttributedString(string: "Your Last Name", attributes: [NSAttributedString.Key.font: UIFont(name: "Apercu-Regular", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white])
//        lastNameLabel.attributedPlaceholder = lastNameLabelAttirbutedPalceHolderText
        
        let lastNameBorder = CALayer()
        lastNameBorder.frame = CGRect(x: -50, y: lastNameLabel.frame.size.height + 10 - width, width:  thisScreenBounds.width, height: 1)
        lastNameBorder.borderWidth = width
        lastNameLabel.layer.addSublayer(lastNameBorder)
        
        thisContentHolder.addSubview(lastNameLabel)
        
        emailLabel.frame = CGRect(x: 50, y: lastNameLabel.frame.maxY+25, width: thisScreenBounds.width-100, height: 22)
        emailLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        emailLabel.textColor = UIColor.white
        emailLabel.textAlignment = NSTextAlignment.left
        emailLabel.autocapitalizationType = UITextAutocapitalizationType.none
        emailLabel.delegate = self
        
        let emailLabelAttirbutedPalceHolderText = NSAttributedString(string: "Your Email", attributes: [NSAttributedString.Key.font: UIFont(name: "Apercu-Regular", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        emailLabel.attributedPlaceholder = emailLabelAttirbutedPalceHolderText
        
        let emailBorder = CALayer()
        emailBorder.frame = CGRect(x: -50, y: emailLabel.frame.size.height + 10 - width, width:  thisScreenBounds.width, height: 1)
        emailBorder.borderWidth = width
        emailLabel.layer.addSublayer(emailBorder)
        
        thisContentHolder.addSubview(emailLabel)
        
        passwordLabel.frame = CGRect(x: 50, y: emailLabel.frame.maxY+25, width: thisScreenBounds.width-100, height: 22)
        
        passwordLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        passwordLabel.textColor = UIColor.white
        passwordLabel.textAlignment = NSTextAlignment.left
        passwordLabel.autocapitalizationType = UITextAutocapitalizationType.none
        passwordLabel.autocorrectionType = UITextAutocorrectionType.no
        passwordLabel.isSecureTextEntry = true
        passwordLabel.delegate = self
        
        let passwordLabelAttirbutedPalceHolderText = NSAttributedString(string: "Your Password", attributes: [NSAttributedString.Key.font: UIFont(name: "Apercu-Regular", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white])
         passwordLabel.attributedPlaceholder = passwordLabelAttirbutedPalceHolderText
         
         let passwordBorder = CALayer()
         passwordBorder.frame = CGRect(x: -50, y: passwordLabel.frame.size.height + 10  - width, width:  thisScreenBounds.width, height: 1)
         passwordBorder.borderWidth = width
         passwordLabel.layer.addSublayer(passwordBorder)
        
        thisContentHolder.addSubview(passwordLabel)
        
        passwordCheckLabel.frame = CGRect(x: 50, y: passwordLabel.frame.maxY+25, width: thisScreenBounds.width-100, height: 22)
        
        passwordCheckLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        passwordCheckLabel.textColor = UIColor.white
        passwordCheckLabel.textAlignment = NSTextAlignment.left
        passwordCheckLabel.autocapitalizationType = UITextAutocapitalizationType.none
        passwordCheckLabel.autocorrectionType = UITextAutocorrectionType.no
        passwordCheckLabel.isSecureTextEntry = true
        passwordCheckLabel.delegate = self
        
        let passwordRepeatLabelAttirbutedPalceHolderText = NSAttributedString(string: "Repeat Password", attributes: [NSAttributedString.Key.font: UIFont(name: "Apercu-Regular", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white])
         passwordCheckLabel.attributedPlaceholder = passwordRepeatLabelAttirbutedPalceHolderText
         
         let passwordRepeatBorder = CALayer()
         passwordRepeatBorder.frame = CGRect(x: -50, y: passwordCheckLabel.frame.size.height + 10 - width, width:  thisScreenBounds.width, height: 1)
         passwordRepeatBorder.borderWidth = width
         passwordCheckLabel.layer.addSublayer(passwordRepeatBorder)
        
        thisContentHolder.addSubview(passwordCheckLabel)
        
        let roleLabelLabel = UILabel(frame: CGRect(x: 50, y: passwordCheckLabel.frame.maxY+20 , width: thisScreenBounds.width-100, height: 22))
        roleLabelLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        roleLabelLabel.textColor = UIColor.white
        roleLabelLabel.textAlignment = NSTextAlignment.left
        roleLabelLabel.text = "I am.."
        
        //var thisRoleLabelTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registerViewController.roleTapped))
        //roleLabelLabel.addGestureRecognizer(thisRoleLabelTap)
        
        roleLabel.frame = CGRect(x: 50, y: roleLabelLabel.frame.maxY+5, width: thisScreenBounds.width-100, height: 22)
        roleLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        roleLabel.textColor = UIColor.white
        roleLabel.textAlignment = NSTextAlignment.left
        roleLabel.text = "Please select"
        roleLabel.isUserInteractionEnabled = true
        
        let roleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registerViewController.roleTapped))
        roleLabel.addGestureRecognizer(roleTap)
        
        let roleBorder = CALayer()
        roleBorder.frame = CGRect(x: -50, y: roleLabel.frame.size.height + 10 - width, width:  thisScreenBounds.width, height: 1)
        roleBorder.borderWidth = width
        roleLabel.layer.addSublayer(roleBorder)
        
        thisContentHolder.addSubview(roleLabelLabel)
        thisContentHolder.addSubview(roleLabel)
        
        rolePickerSelectorView.frame = CGRect(x: 0, y: thisScreenBounds.height-244, width: thisScreenBounds.width, height: 344)
        rolePickerSelectorView.backgroundColor = UIColor.white
        rolePickerSelectorView.alpha = 0
        rolePickerSelectorView.isHidden = true
        rolePickerSelectorView.clipsToBounds = true
        /*
        let thisRoleDoneButton:UIBarButtonItem = UIBarButtonItem(title: "DONE", style: UIBarButtonItemStyle.done, target: self, action: #selector(registerViewController.rolePickerDone))
        thisRoleDoneButton.tintColor = UIColor.black
        print("ONDE")
        let thisRoleToolBar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 44))
        thisRoleToolBar.isTranslucent = true
        thisRoleToolBar.tintColor = UIColor.white
        thisRoleToolBar.isUserInteractionEnabled = true
        thisRoleToolBar.items = [thisRoleDoneButton]
        thisRoleToolBar.sizeToFit()
        */
        let thisDoneButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        thisDoneButton.setTitle("DONE", for: .normal)
        thisDoneButton.setTitleColor(.black, for: .normal)
        var thisDoneButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registerViewController.rolePickerDone))
        thisDoneButton.addGestureRecognizer(thisDoneButtonTap)
        
        rolePickerSelectorView.addSubview(thisDoneButton)
        
        rolePicker.frame = CGRect(x: 0, y: 44, width: thisScreenBounds.width, height: 200)
        rolePicker.backgroundColor = UIColor.white
        rolePicker.dataSource = self
        rolePicker.delegate = self
        rolePicker.showsSelectionIndicator = true
        
        rolePickerSelectorView.addSubview(rolePicker)
        //rolePickerSelectorView.addSubview(thisRoleToolBar)
        
        self.view.addSubview(rolePickerSelectorView)
        
        
        let subscrieLabel = UILabel(frame: CGRect(x: 130, y: roleLabel.frame.maxY+27, width: thisScreenBounds.width, height: 22))
        subscrieLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        subscrieLabel.numberOfLines = 1
        subscrieLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        subscrieLabel.textColor = UIColor.white
        subscrieLabel.textAlignment = NSTextAlignment.left
        subscrieLabel.text = "Subscribe to our newsletter"
        
        thisContentHolder.addSubview(subscrieLabel)
        
        subscribeSwitch.frame = CGRect(x: 50, y: roleLabel.frame.maxY+25, width: 100, height: 30)
        
        subscribeSwitch.tintColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        subscribeSwitch.onTintColor = UIColor.green
        subscribeSwitch.thumbTintColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        
        subscribeSwitch.setOn(true, animated: false)
        
        thisContentHolder.addSubview(subscribeSwitch)
        
        
        let submitButton = UILabel(frame: CGRect(x: 20, y: subscribeSwitch.frame.maxY+50, width: thisScreenBounds.width-40, height: 70))
        submitButton.font = UIFont(name: "Apercu-Bold", size: 18)
        submitButton.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 4
        submitButton.layer.backgroundColor = UIColor.white.cgColor
        submitButton.text = "REGISTER"
        submitButton.isUserInteractionEnabled = true
        
        
        let registerButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registerViewController.registerButtonTapped))
        submitButton.addGestureRecognizer(registerButtonTap)
        
        thisContentHolder.addSubview(submitButton)
        
        thisContentHolder.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: submitButton.frame.maxY+50)
        
        thisContentScrollView.addSubview(thisContentHolder)
        
        
       thisContentScrollView.contentSize = CGSize(width: thisScreenBounds.width, height: thisContentHolder.frame.maxY + 50)
        
        
        self.view.addSubview(thisContentScrollView)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(registerViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
    }
    
    @objc func roleTapped() {
            dismissKeyboard()
            thisContentScrollView.isScrollEnabled = false
        self.view.bringSubviewToFront(rolePickerSelectorView)
            rolePickerSelectorView.isHidden = false
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.6)
            rolePickerSelectorView.alpha = rolePickerSelectorView.alpha * (-1) + 1
            UIView.commitAnimations()
            thisSelectedRole = roleArray[0]
            roleLabel.text = roleArray[0]
    }
    
    @objc func rolePickerDone() {
        print("DONE")
        thisContentScrollView.isScrollEnabled = true
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.6)
        UIView.setAnimationDidStop(#selector(registerViewController.hideRolePickerSelectorViewAfterAnimation))
        rolePickerSelectorView.alpha = rolePickerSelectorView.alpha * (-1) + 1
        UIView.commitAnimations()
    }
    
    @objc func hideRolePickerSelectorViewAfterAnimation() {
        rolePickerSelectorView.isHidden = true
    }
    
    @objc func registerButtonTapped() {
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
        var thisWantsNewsletter = ""
        
        if (nameLabel.text == "") {
            displayOKMessageError("You need to proivde your name!")
            return
        }
        

        if (emailLabel.text == "") {
            displayOKMessageError("You need to provide an email adress!")
            return
        } else {
            let thisText = isValidEmail(emailLabel.text!)
            if (thisText == false) {
                displayOKMessageError("You need to provide a valid email adress!")
                return
            }
            
        }
        
        if (passwordLabel.text == "") {
            displayOKMessageError("You need to provide a password")
            return
        }
        
        if (passwordLabel.text != passwordCheckLabel.text) {
            displayOKMessageError("Password and repeat password must be the same.")
            return
        }
        
        if(thisSelectedRole == "") {
            displayOKMessageError("Please select a role!")
            return
        }
        
        if(subscribeSwitch.isOn) {
            thisWantsNewsletter = "1"
        } else {
            thisWantsNewsletter = "0"
        }
        
        let thisUrl = globalData.globalUrl + "register"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "firstname="+nameLabel.text!+"&"
        postString = postString + "lastname="+lastNameLabel.text!+"&"
        postString = postString + "email="+emailLabel.text!+"&"
        postString = postString + "password="+passwordLabel.text!+"&"
        postString = postString + "fbID=0&role="
        postString = postString + thisSelectedRole
        postString = postString + "&newsletter="+thisWantsNewsletter
        
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                //print(String(data: data, encoding: String.Encoding.utf8))
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
                            let thisID = sessionJson[0]["id"] as! Int
                            let thisStatus = sessionJson[0]["status"] as! String
                            if (thisStatus == "FAIL") {
                                DispatchQueue.main.async {
                                    self.displayOKMessageError("An error occured, please try again")
                                }
                                return
                            }
                            
                            if (thisStatus == "EMAIL") {
                                DispatchQueue.main.async {
                                    self.displayOKMessageError("This mail is already registered.")
                                }
                                return
                            }
                            
                            if (thisStatus == "OK") {
                                DispatchQueue.main.async {
                                    self.registrationDone()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func registrationDone () {
        let thisMessage = "Good choice! Thanks for signing up."
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roleArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: roleArray[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roleLabel.text = roleArray[row]
        thisSelectedRole = roleArray[row]
    }
    
    
    
    
    //KEYBOARD STUFF
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTrack("Register", parameter: "")
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterForKeyBoardNotification()
    }
    
        
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userRearViewController.keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(userRearViewController.keyboardWasHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func deregisterForKeyBoardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    
    func keyboardWasHidden(_ notification : Notification) {
        thisContentScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        thisContentScrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func keyboardWasShown(_ notification : Notification ) {
        
        keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        thisContentScrollView.contentInset = contentInsets
        thisContentScrollView.scrollIndicatorInsets = contentInsets
        
        UIView.commitAnimations()
        
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
     func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard () {
        //thisContentScrollView.resignFirstResponder()
        for thisview in thisContentHolder.subviews {
            if (thisview.isFirstResponder) {
                thisview.resignFirstResponder()
            }
        }
    }
}
