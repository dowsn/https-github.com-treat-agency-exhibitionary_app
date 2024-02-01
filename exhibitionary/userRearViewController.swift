//
//  userRearViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 27/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation


class userRearViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    
    
    var thisScreenBounds = UIScreen.main.bounds
    let thisContentScrollView:UIScrollView = UIScrollView()
    var thisLoggedInContentScrollView:UIScrollView = UIScrollView()
    var autoLogin:Bool = true
    let emailField = UITextField()
    let passwordField = UITextField()
    let rememberMeSwitch = UISwitch()
    let localizeMeSwitch = UISwitch()
    var localizeMe:Bool = true
    var thisSessionID:String = ""
    var thisUserID:String = ""
    let userDefaults = UserDefaults.standard
    var keyboardSize:CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let rectShape1 = CAShapeLayer()
    var thisDarkener = UIView()
    
    var thisImage:UIImage = UIImage()
    var profileImage = UIImageView()
    var profileImageChanged = false
    var actionLabel = UITextField()
    var descLabel = UITextView()
    var saveButton = UILabel()
    
    var thisProfileName = ""
    var thisProfileURL = ""
    var thisProfileDesc = ""
    var thisProfileAC = ""
    var isEditor = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpHeader()-.+,m pn
        
        thisDarkener.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
        thisDarkener.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
        thisIndicator.frame = CGRect(x: self.thisScreenBounds.width/2-10, y: self.thisScreenBounds.height/2-10, width: 20, height: 20)
        thisIndicator.startAnimating()
        thisDarkener.addSubview(thisIndicator)
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isOpaque = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Apercu-Bold", size: 20)!], for: UIControl.State())
        navigationItem.backBarButtonItem = backButton
        
        
        let revealController = self.revealViewController()
        let revealButtonItemWithImage = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        revealButtonItemWithImage.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Apercu-Bold", size: 20)!], for: UIControl.State())
        
        self.navigationItem.leftBarButtonItem = revealButtonItemWithImage
        
        
        self.view.backgroundColor = UIColor.black
        
        // new
//        self.automaticallyAdjustsScrollViewInsets = false
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
        thisContentScrollView.isScrollEnabled = true
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        
        if (thisUserID == "") {
            
        
        let thisEmail: AnyObject? = userDefaults.object(forKey: "usermail") as AnyObject?
        let thisPassword: AnyObject? = userDefaults.object(forKey: "password") as AnyObject?
        
        let welcomeTextLabel = UILabel(frame: CGRect(x: 20, y: 40, width: thisScreenBounds.width-40, height: 100))
        welcomeTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        welcomeTextLabel.numberOfLines = 10
        welcomeTextLabel.font = UIFont(name: "Apercu-Bold", size: 18)
        welcomeTextLabel.textColor = UIColor.white
        welcomeTextLabel.textAlignment = NSTextAlignment.center
        welcomeTextLabel.text = "Log in to save your picks";
        
        thisContentScrollView.addSubview(welcomeTextLabel)
        
        
        rectShape1.bounds = CGRect(x: 0, y: 0, width: thisScreenBounds.width-40, height: 110)
        rectShape1.position = CGPoint(x: thisScreenBounds.width/2, y: welcomeTextLabel.frame.maxY+60)
        rectShape1.cornerRadius = 4
        rectShape1.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
        
        self.thisContentScrollView.layer.addSublayer(rectShape1)
        
        
        let rectDevider = CAShapeLayer()
        rectDevider.bounds = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 2)
        rectDevider.position = CGPoint(x: thisScreenBounds.width/2, y: rectShape1.frame.minY+55)
        rectDevider.backgroundColor = UIColor.black.cgColor
        
        self.thisContentScrollView.layer.insertSublayer(rectDevider, above: rectShape1)
        //self.view.layer.insertSublayer(rectDevider, above: rectShape1)
        //addSublayer(rectDevider)
        
        /*
        let signInTextLabel = UILabel(frame: CGRect(x: 0, y: registerButton.frame.maxY+10, width: thisScreenBounds.width, height: 20))
        signInTextLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        signInTextLabel.numberOfLines = 1
        signInTextLabel.font = UIFont(name: "Apercu-Regular", size: 12)
        signInTextLabel.textColor = UIColor.whiteColor()
        signInTextLabel.textAlignment = NSTextAlignment.Center
        
        signInTextLabel.text = "For registered users:"
        
        thisContentScrollView.addSubview(welcomeTextLabel)
        thisContentScrollView.addSubview(signInTextLabel)
        */
        
        emailField.frame = CGRect(x: 30, y: welcomeTextLabel.frame.maxY+15, width: thisScreenBounds.width-60, height: 40)
        /*
        emailField.layer.borderColor = UIColor.whiteColor().CGColor
        emailField.layer.borderWidth = 0.5
        emailField.borderStyle = UITextBorderStyle.Line
        */
        emailField.backgroundColor = UIColor.clear
        emailField.delegate = self
        emailField.font = UIFont(name: "Apercu-Regular", size: 16)
        emailField.textColor = UIColor.white
        emailField.text = "What's your email?"
        emailField.autocapitalizationType = UITextAutocapitalizationType.none
        emailField.autocorrectionType = UITextAutocorrectionType.no
        
        thisContentScrollView.addSubview(emailField)
        
        passwordField.frame = CGRect(x: 30, y: emailField.frame.maxY+10, width: thisScreenBounds.width-200, height: 40)
        passwordField.delegate = self
        /*
        passwordField.borderStyle = UITextBorderStyle.Line
        passwordField.layer.borderColor = UIColor.whiteColor().CGColor
        passwordField.layer.borderWidth = 0.5
        */
        passwordField.font = UIFont(name: "Apercu-Regular", size: 16)
        passwordField.textColor = UIColor.white
        
        passwordField.text = "What's your password?"
        
        passwordField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordField.autocorrectionType = UITextAutocorrectionType.no
        passwordField.tag = 1;
        
        thisContentScrollView.addSubview(passwordField)
        
        let resetButton = UILabel(frame: CGRect(x: passwordField.frame.maxX+10, y: passwordField.frame.minY, width: 130, height: 40))
        
        resetButton.backgroundColor = UIColor.clear
        resetButton.font = UIFont(name: "Apercu-Regular", size: 17)
        resetButton.textColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 0.6)
        resetButton.textAlignment = NSTextAlignment.center
        
        resetButton.text = "FORGOT"
        
        resetButton.isUserInteractionEnabled = true
        let resetTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.resetPWTapped))
        resetButton.addGestureRecognizer(resetTap)
        
        thisContentScrollView.addSubview(resetButton)
        
        
        let submitButton = UILabel(frame: CGRect(x: 20, y: passwordField.frame.maxY+30, width: thisScreenBounds.width-40, height: 40))
        submitButton.font = UIFont(name: "Apercu-Bold", size: 18)
        submitButton.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 4
        submitButton.layer.backgroundColor = UIColor.white.cgColor
        submitButton.text = "LOG IN"
        submitButton.isUserInteractionEnabled = true
        
        let submitButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.submitButtonTapped))
        submitButton.addGestureRecognizer(submitButtonTap)
        thisContentScrollView.addSubview(submitButton)
            
            
            
//        let fbLoginButton:FBSDKLoginButton = FBSDKLoginButton()
//        fbLoginButton.readPermissions = ["public_profile", "email"]
//        fbLoginButton.frame = CGRect(x: 20, y: submitButton.frame.maxY+25, width: thisScreenBounds.width-40, height: 30)
//        fbLoginButton.delegate = self
        
//        thisContentScrollView.addSubview(fbLoginButton)
            
        //thisScreenBounds.width/2-100
//        rememberMeSwitch.frame = CGRect(x: 30, y: fbLoginButton.frame.maxY+25, width: 200, height: 30)
        rememberMeSwitch.tintColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        rememberMeSwitch.onTintColor = UIColor.white
        rememberMeSwitch.thumbTintColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        
        //thisContentScrollView.addSubview(rememberMeSwitch)
        
        //thisScreenBounds.width/2-35
        let rememberMeLabel = UILabel(frame: CGRect(x: 100, y: rememberMeSwitch.frame.minY, width: 100, height: 30))
        rememberMeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        rememberMeLabel.numberOfLines = 1
        rememberMeLabel.textAlignment = NSTextAlignment.left
        rememberMeLabel.text = "Remember me!"
        rememberMeLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        rememberMeLabel.textColor = UIColor.white
        
        //thisContentScrollView.addSubview(rememberMeLabel)
            
        /*
        let resetButton = UILabel(frame: CGRect(x: 20, y: rememberMeSwitch.frame.maxY+15, width: thisScreenBounds.width-40, height: 20))
        resetButton.font = UIFont(name: "Apercu-Bold", size: 14)
        resetButton.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        resetButton.textAlignment = NSTextAlignment.Center
        resetButton.layer.cornerRadius = 4
        resetButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        resetButton.text = "FORGOT PASSWORT"
        resetButton.userInteractionEnabled = true
            
        resetButton.userInteractionEnabled = true
        let resetTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.resetPWTapped))
        resetButton.addGestureRecognizer(resetTap)
            
        thisContentScrollView.addSubview(resetButton)
        */
        let registerButton = UILabel(frame: CGRect(x: thisScreenBounds.width/2-100, y: 496, width: 200, height: 40))
            
//
         registerButton.backgroundColor = UIColor.clear
            //UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
         registerButton.font = UIFont(name: "Apercu-Bold", size: 16)
         registerButton.textAlignment = NSTextAlignment.center
            registerButton.textColor = .white

         registerButton.numberOfLines = 2
        let thisText = NSMutableAttributedString(string: "Not registered yet?\nSign up now")
            thisText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range:  NSMakeRange(19, 12))
        registerButton.attributedText = thisText
        
         registerButton.isUserInteractionEnabled = true
         let registerButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.registerButtonTapped))
         registerButton.addGestureRecognizer(registerButtonTap)
         
        thisContentScrollView.addSubview(registerButton)
            
        let aboutButton = UILabel(frame: CGRect(x: thisScreenBounds.width/2-100, y: registerButton.frame.maxY+50, width: 200, height: 20))
            
        aboutButton.backgroundColor = UIColor.clear
        aboutButton.font = UIFont(name: "Apercu-Bold", size: 14)
        aboutButton.textColor = UIColor.white
        aboutButton.textAlignment = NSTextAlignment.center
        aboutButton.numberOfLines = 2
        let thisFinalString = "hello@exhibitionary.com"
            
            //\n
            
        let thisAboutText = NSMutableAttributedString(string: thisFinalString)
        thisAboutText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range:  NSMakeRange(0, 19))
        //thisAboutText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range:  NSMakeRange(27, 22))
        
        aboutButton.attributedText = thisAboutText
        aboutButton.isUserInteractionEnabled = true
            
        let abotButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.aboutButtonTapped))
        aboutButton.addGestureRecognizer(abotButtonTap)
            
        thisContentScrollView.addSubview(aboutButton)
        
            let webButton = UILabel(frame: CGRect(x: thisScreenBounds.width/2-100, y: aboutButton.frame.maxY-5, width: 200, height: 20))
            
            webButton.backgroundColor = UIColor.clear
            webButton.font = UIFont(name: "Apercu-Bold", size: 14)
            webButton.textColor = UIColor.white
            webButton.textAlignment = NSTextAlignment.center
            webButton.numberOfLines = 2
            
            webButton.text = "www.exhibitionary.com"
            
            webButton.isUserInteractionEnabled = true;
            
            let webButtontap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.webButtonTapped))
            webButton.addGestureRecognizer(webButtontap)
            
            thisContentScrollView.addSubview(webButton)
            
        //let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.dismissKeyboard))
        //self.view.addGestureRecognizer(tap)
        
        thisContentScrollView.contentSize = CGSize(width: thisScreenBounds.width, height: aboutButton.frame.maxY+100)
            
        self.view.addSubview(thisContentScrollView)
            
            
        
        if (thisEmail == nil) {
            //rememberMeSwitch.setOn(false, animated: false)
            autoLogin = false;
            
        } else {
            //rememberMeSwitch.setOn(true, animated: true)
            emailField.text = thisEmail as? String
            passwordField.text = thisPassword as? String
            passwordField.isSecureTextEntry = true;
            autoLogin = true;
            //loginUserWithEmail()
        }
        
            
        } else {
            loginDone()
        }
        
        
        
    }
    
    @objc func webButtonTapped() {
        let thisURLString = "mailto://hello@exhibitionary.com"
        let checkURL = URL(string: thisURLString)
        UIApplication.shared.openURL(checkURL!)
    }
    
    @objc func aboutButtonTapped() {
        let thisURLString = "http://www.exhibitionary.com/"
        let checkURL = URL(string: thisURLString)
        UIApplication.shared.openURL(checkURL!)
    }
    
    @objc func resetPWTapped() {
        self.performSegue(withIdentifier: "resetPwSegue", sender: self)
    }

    
    @objc func registerButtonTapped() {
        self.performSegue(withIdentifier: "showRegister", sender: self)
    }
    
    @objc func submitButtonTapped() {
        if (emailField.text == "") {
            displayOKMessageError("You need to provide an email adress!")
            return
        }
        if (passwordField.text == "") {
            displayOKMessageError("You need to provide a password!")
            return
        }
        
        let thisUrl = globalData.globalUrl + "login"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "username="+emailField.text!+"&"
        postString = postString + "password="+passwordField.text!
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            //print(String(data: data, encoding: String.Encoding.utf8))
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
                                self.thisDarkener.removeFromSuperview()
                                self.displayOKMessageError(thisError)
                            }
                            return
                        }
                        if (thisStatus == "OK") {
                            let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            thisAppDelegate.sessionUserID = thisUserID
                            thisAppDelegate.sessionID = thisSessionID
                            thisAppDelegate.userPass = self.passwordField.text!
                            thisAppDelegate.sessionUserMail = self.emailField.text!
                            
                            thisAppDelegate.thisProfileName = self.thisProfileName
                            thisAppDelegate.thisProfileURL = self.thisProfileURL
                            thisAppDelegate.thisProfileDesc = self.thisProfileDesc
                            thisAppDelegate.thisProfileAC = self.thisProfileAC
                            thisAppDelegate.isEditor = self.isEditor
                            
                            self.thisSessionID = thisSessionID
                            self.thisUserID = thisUserID
                            
                            //if (self.rememberMeSwitch.on) {
                                self.userDefaults.set(thisUserID as String, forKey: "userid")
                                self.userDefaults.set(self.emailField.text! as String, forKey: "usermail")
                                self.userDefaults.set(self.passwordField.text! as String, forKey: "password")
                            
                            /*} else {
                                self.userDefaults.setObject(nil, forKey: "userid")
                                self.userDefaults.setObject(nil, forKey: "usermail")
                                self.userDefaults.setObject(nil, forKey: "password")
                            }
                            */
                            
                            DispatchQueue.main.async {
                                self.loginDone()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func loginDone() {
        thisDarkener.removeFromSuperview()
        
        self.view.backgroundColor = UIColor.white
        
        thisLoggedInContentScrollView.subviews.forEach({ $0.removeFromSuperview() })
        /*
        let revealController = self.revealViewController()
        revealController?.revealToggle(animated: true)
        revealController?.navigationItem.backBarButtonItem = nil
        */
        
        thisContentScrollView.removeFromSuperview()
        rectShape1.removeFromSuperlayer()
        
        self.thisProfileName = returnAppDelegate().thisProfileName
        self.thisProfileURL = returnAppDelegate().thisProfileURL
        self.thisProfileDesc = returnAppDelegate().thisProfileDesc
        self.thisProfileAC = returnAppDelegate().thisProfileAC
        self.isEditor = returnAppDelegate().isEditor
        
        print(thisProfileURL)
        
        thisLoggedInContentScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height))
        
        
        profileImage = UIImageView(frame: CGRect(x: 50, y: 20, width: 65, height: 65))
        
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        
        if (thisProfileURL == "") {
            profileImage.image = UIImage(named: "MyPicks")
        } else {
            profileImage.sd_setImage(with: URL(string: thisProfileURL))
        }
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.imageChangeTap))
        profileImage.addGestureRecognizer(profileImageTap)
        
        thisLoggedInContentScrollView.addSubview(profileImage)
        //self.view.addSubview(profileImage)
        //
        
        
        let tapToChange = UILabel(frame: CGRect(x: 50, y: 85, width: 65, height: 20))
        tapToChange.textColor = UIColor.black
        tapToChange.font = UIFont(name: "Apercu-Regular", size: 8)
        tapToChange.textAlignment = NSTextAlignment.center
        tapToChange.backgroundColor = UIColor.clear
        tapToChange.isUserInteractionEnabled = false
        
        tapToChange.text = "Change Photo"
        
        thisLoggedInContentScrollView.addSubview(tapToChange)
        
        actionLabel = UITextField(frame: CGRect(x: 50, y: profileImage.frame.maxY+30, width: thisScreenBounds.width-140, height: 20))
        actionLabel.textColor = UIColor.black
        actionLabel.font = UIFont(name: "Apercu-Bold", size: 17)
        actionLabel.textAlignment = NSTextAlignment.left
        actionLabel.backgroundColor = UIColor.clear
        actionLabel.isUserInteractionEnabled = true
        actionLabel.autocapitalizationType = .words
        actionLabel.autocorrectionType = .no
        actionLabel.returnKeyType = .done
        actionLabel.placeholder = "Your name"
        actionLabel.text = thisProfileName
        actionLabel.delegate = self
        
        thisLoggedInContentScrollView.addSubview(actionLabel)
        
        let adressLabel = UILabel(frame: CGRect(x: 50, y: actionLabel.frame.maxY, width: thisScreenBounds.width-100, height: 60))
        adressLabel.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        adressLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        adressLabel.textAlignment = NSTextAlignment.left
        adressLabel.backgroundColor = UIColor.clear
        adressLabel.isUserInteractionEnabled = false
        if(thisProfileAC == "") {
            thisProfileAC = "None yet."
        }
        adressLabel.text = "Cities with My Picks:\n" + thisProfileAC
        adressLabel.lineBreakMode = .byWordWrapping
        adressLabel.numberOfLines = 3
        
        thisLoggedInContentScrollView.addSubview(adressLabel)
        /*
        let upOstrophe = UIImageView(frame: CGRect(x: 55, y: adressLabel.frame.maxY+40, width: 15, height: 15))
        upOstrophe.contentMode = UIViewContentMode.scaleAspectFill
        upOstrophe.clipsToBounds = false
        upOstrophe.isUserInteractionEnabled = false
        upOstrophe.image = UIImage(named: "UpOstrophe")
        thisLoggedInContentScrollView.addSubview(upOstrophe)
        */
    
        //descLabel = UITextView(frame: CGRect(x: 50, y: upOstrophe.frame.maxY+15, width: thisScreenBounds.width-100, height: 80))
        descLabel = UITextView(frame:CGRect(x: 45, y: adressLabel.frame.maxY+20, width: thisScreenBounds.width-100, height: 80))
        descLabel.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        descLabel.font = UIFont(name: "Apercu-Regular", size: 20)
        descLabel.textAlignment = NSTextAlignment.left
        descLabel.backgroundColor = UIColor.clear
        descLabel.isUserInteractionEnabled = true
        descLabel.autocorrectionType = .no
        descLabel.autocapitalizationType = .sentences
        //descLabel.numberOfLines = 4
        descLabel.text = thisProfileDesc
        if (thisProfileDesc == "") {
            descLabel.text = "Your short bio"
        }
        descLabel.returnKeyType = .done
        descLabel.delegate = self
        //descLabel.lineBreakMode = .byWordWrapping
        
        thisLoggedInContentScrollView.addSubview(descLabel)
        /*
        let downOstrophe = UIImageView(frame: CGRect(x: 55, y: descLabel.frame.maxY+15, width: 15, height: 15))
        downOstrophe.contentMode = UIViewContentMode.scaleAspectFill
        downOstrophe.clipsToBounds = false
        downOstrophe.isUserInteractionEnabled = false
        downOstrophe.image = UIImage(named: "Downstrophe")
        thisLoggedInContentScrollView.addSubview(downOstrophe)
        */
        //rememberMeSwitch.frame = CGRect(x: 50, y: downOstrophe.frame.maxY+25, width: 200, height: 30)
        rememberMeSwitch.frame = CGRect(x: 50, y: descLabel.frame.maxY+20, width: 15, height: 15)
        rememberMeSwitch.tintColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        rememberMeSwitch.onTintColor = UIColor.green
        rememberMeSwitch.thumbTintColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        if (isEditor == "1") {rememberMeSwitch.setOn(true, animated: true)}
        
        let rememberMeLabel = UILabel(frame: CGRect(x: 120, y: rememberMeSwitch.frame.minY, width: 200, height: 30))
        rememberMeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        rememberMeLabel.numberOfLines = 1
        rememberMeLabel.textAlignment = NSTextAlignment.left
        rememberMeLabel.text = "Publish My Picks"
        rememberMeLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        rememberMeLabel.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        
        thisLoggedInContentScrollView.addSubview(rememberMeSwitch)
        thisLoggedInContentScrollView.addSubview(rememberMeLabel)
        
        
        let thisButtonheight = CGFloat(40)
        saveButton = UILabel(frame: CGRect(x: 50, y: thisScreenBounds.height-50-(thisButtonheight*4), width: thisScreenBounds.width-100, height: thisButtonheight))
        saveButton.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        saveButton.font = UIFont(name: "Apercu-Bold", size: 16)
        saveButton.textAlignment = NSTextAlignment.left
        saveButton.backgroundColor = UIColor.clear
        saveButton.isUserInteractionEnabled = true
        saveButton.text = "Save"
        
        let rectDevider = CAShapeLayer()
        var thisX = (thisScreenBounds.width/2)-25
        rectDevider.bounds = CGRect(x: 0, y: 38, width: thisScreenBounds.width-50, height: 1)
        rectDevider.position = CGPoint(x: thisX, y: 39)
        rectDevider.backgroundColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250).cgColor
        
        saveButton.layer.addSublayer(rectDevider)
        
        let thisSaveTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.saveTap))
        saveButton.addGestureRecognizer(thisSaveTap)
        
        thisLoggedInContentScrollView.addSubview(saveButton)
        
        let logoOutButton = UILabel(frame: CGRect(x: 50, y: saveButton.frame.maxY, width: thisScreenBounds.width-100, height: thisButtonheight))
        logoOutButton.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        logoOutButton.font = UIFont(name: "Apercu-Regular", size: 14)
        logoOutButton.textAlignment = NSTextAlignment.left
        logoOutButton.backgroundColor = UIColor.clear
        logoOutButton.isUserInteractionEnabled = true
        logoOutButton.text = "Logout"
        
        let rectLogoutDevider = CAShapeLayer()
        rectLogoutDevider.bounds = CGRect(x: 0, y: 38, width: thisScreenBounds.width-50, height: 1)
        rectLogoutDevider.position = CGPoint(x: thisX, y: 39)
        rectLogoutDevider.backgroundColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250).cgColor
        
        logoOutButton.layer.addSublayer(rectLogoutDevider)
        
        let thisLogoutTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.logOut))
        logoOutButton.addGestureRecognizer(thisLogoutTap)
        
        thisLoggedInContentScrollView.addSubview(logoOutButton)
        
        let aboutButton = UILabel(frame: CGRect(x: 50, y: logoOutButton.frame.maxY, width: thisScreenBounds.width-100, height: 40))
        aboutButton.backgroundColor = UIColor.clear
        aboutButton.font = UIFont(name: "Apercu-Regular", size: 14)
        aboutButton.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        aboutButton.textAlignment = NSTextAlignment.left
        aboutButton.numberOfLines = 1
        let thisFinalString = "Privacy / Help"
        aboutButton.text = thisFinalString
        /*
        let thisAboutText = NSMutableAttributedString(string: thisFinalString)
        thisAboutText.addAttribute(NSDocumentTypeDocumentAttribute, value: NSHTMLTextDocumentType, range: NSMakeRange(0, thisAboutText.length))
        
        aboutButton.attributedText = thisAboutText*/
        aboutButton.isUserInteractionEnabled = true
        
        let abotButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userRearViewController.aboutButtonTapped))
        aboutButton.addGestureRecognizer(abotButtonTap)
        
        thisLoggedInContentScrollView.addSubview(aboutButton)
        
        self.view.addSubview(thisLoggedInContentScrollView)
        
        
       // revealController?.frontViewController!.removeMenuButton()
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (descLabel.text == "Your short bio") {
            descLabel.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if (descLabel.text == "") {
            descLabel.text = "Your short bio"
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            descLabel.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func saveTap() {
        saveButton.textColor = .black
        if (profileImageChanged) {
            saveImage()
        } else {
            saveData()
        }
    }
    
    @objc func imageChangeTap() {
        //profileImage.removeFromSuperview()
        
        let picker:UIImagePickerController = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage:UIImage = info[UIImagePickerController.InfoKey.editedImage.rawValue] as! UIImage
        thisImage = generateImage(380, desiredHeight: 380, sourceImage: chosenImage)
        
        profileImage.image = thisImage
        picker.dismiss(animated: true, completion: nil)
        profileImageChanged = true
        
    }
    
    @objc func logOut() {
        self.saveButton.textColor = .black
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "userid")
        userDefaults.set(nil, forKey: "usermail")
        userDefaults.set(nil, forKey: "password")
        
        let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        thisAppDelegate.sessionUserID = ""
        thisAppDelegate.sessionID = ""
        thisAppDelegate.userPass = ""
        thisAppDelegate.sessionUserMail = ""
        
        thisAppDelegate.thisProfileName = ""
        thisAppDelegate.thisProfileURL = ""
        thisAppDelegate.thisProfileDesc = ""
        thisAppDelegate.thisProfileAC = ""
        //thisAppDelegate.isEditor = false
        
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        thisLoggedInContentScrollView.removeFromSuperview()
        passwordField.isSecureTextEntry = false
        
//        FBSDKLoginManager().logOut()
//        FBSDKAccessToken.setCurrent(nil)
        
        thisContentScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        self.viewDidLoad()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        if (textField.tag == 1) {
            textField.isSecureTextEntry = true;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        /*
        self.registerForKeyboardNotifications()
        
        setTrack("Login", parameter: "")
        passwordField.text = "What's your password?"
        emailField.text = "What's your email?"
        
        passwordField.isSecureTextEntry = false
        
        let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if(thisAppDelegate.settingFBLogin) {
            self.view.addSubview(thisDarkener)
        } else {
            thisDarkener.removeFromSuperview()
            if(thisAppDelegate.sessionUserMail != "") {
                self.loginDone()
            }
        }
        */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterForKeyBoardNotification()
    }
    //KEYBOARD STUFF
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userRearViewController.keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(userRearViewController.keyboardWasHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func deregisterForKeyBoardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    
    @objc func keyboardWasHidden(_ notification : Notification) {
        thisContentScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        thisContentScrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc func keyboardWasShown(_ notification : Notification ) {
        
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
    
    
    func dismissKeyboard () {
        //thisContentScrollView.resignFirstResponder()
        for thisview in thisContentScrollView.subviews {
            if (thisview.isFirstResponder) {
                thisview.resignFirstResponder()
            }
        }
        for thisview in thisLoggedInContentScrollView.subviews {
            if (thisview.isFirstResponder) {
                thisview.resignFirstResponder()
            }
        }
    }
    
    
    
//    open func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        //print("FB RESULT")
//        //print(result)
//        if ((error) != nil) {
//            // Process error
//        }
//        else if result.isCancelled {
//            // Handle cancellations
//            fbCanceled()
//        }
//        else {
//            
//            let thisToken = String(result.token.tokenString)
//            let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: ["fields": "id, name, first_name, last_name, email"]);
//            fbRequest?.start(completionHandler: {(connection, result, error) in
//                
//                let fbResult = result as! Dictionary<String, AnyObject>
//                if (fbResult["email"] == nil) {
//                    let thisMessage = "You need to grant permission to your e-mail adress to be able to use facebook login!"
//                    let failureMessage:UIAlertController = UIAlertController(title: "Error", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
//                    failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
//                        self.fbCanceled()
//                        })
//                    self.present(failureMessage, animated: true, completion: nil)
//                    return
//                }
//                if error == nil {
//                    
//                    DispatchQueue.main.async {
//                        let thisEmail = fbResult["email"] as! String
//                        let thisFBID = fbResult["id"] as! String
//                        self.createFBLogin(thisEmail, token: thisToken, fb_id: thisFBID)
//                        self.view.addSubview(self.thisDarkener)
//                    }
//                    
//                } else {
//                    
//                    //ERROR
//                    let thisMessage = "There was an error with your facebook login. Try again later!"
//                    let failureMessage:UIAlertController = UIAlertController(title: "Error", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
//                    failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
//                        self.fbCanceled()
//                        })
//                    self.present(failureMessage, animated: true, completion: nil)
//                    return
//                    
//                    
//                }
//            })
//            // Navigate to other view
//        }
//    }
    
//    func fbCanceled() {
//        thisDarkener.removeFromSuperview()
////        FBSDKLoginManager().logOut()
//    }
    
    func saveData() {
        //
        let thisSessionID = returnAppDelegate().sessionID
        let thisUrl = globalData.globalUrl + "update_user_profile"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "session_id="+thisSessionID+"&"
        postString = postString + "user_id="+returnAppDelegate().sessionUserID+"&"
        postString = postString + "first_name="+actionLabel.text!+"&"
        //postString = postString + "last_name="+thisUserID+"&"
        var thisSaveText = descLabel.text!
        if (descLabel.text == "Your short bio") {
            thisSaveText = ""
        }
        postString = postString + "description="+thisSaveText+"&"
        if (rememberMeSwitch.isOn) {
            postString = postString + "share_public=1"
        } else {
            postString = postString + "share_public=0"
        }

        print(postString)
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                
                DispatchQueue.main.async {
                    
                    //self.feedSelectionArray.append(item)
                    let thisMessage = "Saved!"
                    let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
                    failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                        
                    })
                    self.present(failureMessage, animated: true, completion: nil)
                    self.saveButton.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
                }
                
                let jsonOptional: Any!
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    
                } catch _ as NSError {
                    //jsonErrorOptional = error
                    jsonOptional = nil
                }
            }
        }
    }
    
    func saveImage() {
        var uploadUrl = ""
        var imageData:Data = Data()
        imageData = thisImage.jpegData(compressionQuality: 1)!
        
        thisSessionID = returnAppDelegate().sessionUserID
        thisUserID = returnAppDelegate().sessionUserID
        
        uploadUrl = globalData.globalUrl + "upload_profile/"
        
        let request = NSMutableURLRequest(url: URL(string: uploadUrl)!)
        request.httpMethod = "POST"
        
        let body:NSMutableData = NSMutableData()
        
        let boundary = "14737809831466499882746641449"
        
        let contentType = NSString(format: "multipart/form-data; boundary=%@", boundary) as String
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        body.append(NSString(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Disposition: form-data; name=\"session_id\"\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: thisSessionID as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "\r\n").data(using: String.Encoding.utf8.rawValue)!)

        body.append(NSString(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Disposition: form-data; name=\"user_id\"\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: thisUserID as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Disposition: attachment; name=\"image\"; filename=\"image.jpg\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSData(data: imageData) as Data)
        body.append(NSString(format: "\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "--%@--\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        
        request.httpBody = body as Data
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
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
                        //print(response)
                        if let sessionJson = response["session"] as? Dictionary<String, AnyObject> {
                            let thisStatus = sessionJson["status"] as! String
                            if (thisStatus == "OK") {
                                if let thisResponse = response["response"] as? Array<AnyObject> {
                                    print(thisResponse)
                                    for item in thisResponse {
                                        let thisURLString = self.nullToNil(item["url"]! as! String)
                                        print("SAVE PROFILE PICS")
                                        print(thisURLString)
                                        let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                        thisAppDelegate.thisProfileURL = thisURLString!
                                        self.saveButton.textColor = .black
                                        DispatchQueue.main.async {
                                            self.saveData()
                                            //self.replaceCoverOrProfileImage(thisURLString!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func createFBLogin(_ email:String, token:String, fb_id:String) {
        let thisUrl = globalData.globalUrl + "loginUserFB" //""
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "fb_id="+fb_id+"&"
        postString = postString + "token="+token+"&"
        postString = postString + "email="+email
        let thisMail = email
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            
            //print(String(data: data, encoding: String.Encoding.utf8))
            
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
                        
                        if (thisStatus == "FAIL") {
                            DispatchQueue.main.async {
                                self.displayOKMessageError(thisError)
//                                self.fbCanceled()
                            }
                            return
                        }
                        if (thisStatus == "OK") {
                            let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            thisAppDelegate.sessionUserID = thisUserID
                            thisAppDelegate.sessionID = thisSessionID
                            thisAppDelegate.userPass = self.passwordField.text!
                            thisAppDelegate.sessionUserMail = self.emailField.text!
                            self.thisSessionID = thisSessionID
                            self.thisUserID = thisUserID
                            
                            thisAppDelegate.thisProfileName = response["full_name"] as! String
                            thisAppDelegate.thisProfileURL = response["profile_img"] as! String
                            thisAppDelegate.thisProfileDesc = response["description"] as! String
                            thisAppDelegate.thisProfileAC = response["active_cities"] as! String
                            thisAppDelegate.isEditor = response["share_public"] as! String
                            
                            self.userDefaults.set(thisUserID as String, forKey: "userid")
                            self.userDefaults.set(thisMail as String, forKey: "usermail")
                            self.userDefaults.set(self.passwordField.text! as String, forKey: "password")
                            
                            
                            
                            DispatchQueue.main.async {
                                self.loginDone()
                            }
                        }
                    }
                }
            }
        }
    }
    
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        self.logOut()
//    }
}
