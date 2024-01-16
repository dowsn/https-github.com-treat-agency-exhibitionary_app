//
//  topSearchView.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 24/10/2016.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

class topSearchView:UIViewController, UITextFieldDelegate {
    
    let thisScreenBounds = UIScreen.main.bounds
    let thisContentScrollView:UIScrollView = UIScrollView()
    var keyboardSize:CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let subscribeSwitch = UISwitch()
    var searchExpression = ""
    var thisCADFilterOn = false
    
    weak var delegateCall: callSearchFilter?
    
    let nameLabel = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTrack("Search", parameter: "")
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
        
        self.registerForKeyboardNotifications()
        
        let nameLabelLabel = UILabel(frame: CGRect(x: 50, y: 50, width: thisScreenBounds.width-100, height: 44))
        nameLabelLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        nameLabelLabel.textColor = UIColor.white
        nameLabelLabel.textAlignment = NSTextAlignment.left
        nameLabelLabel.numberOfLines = 2
        
        nameLabelLabel.text = "Enter artist name or venue name or exhibition name:"
        
        nameLabel.frame = CGRect(x: 50, y: nameLabelLabel.frame.maxY+5, width: thisScreenBounds.width-100, height: 22)
        nameLabel.layer.addSublayer(createLine(nameLabel.frame.width, desiredY: 20))
        nameLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.text = searchExpression
        nameLabel.delegate = self
        
        thisContentScrollView.addSubview(nameLabelLabel)
        thisContentScrollView.addSubview(nameLabel)
        
        let subscrieLabel = UILabel(frame: CGRect(x: 130, y: nameLabel.frame.maxY+10, width: thisScreenBounds.width-135, height: 44))
        subscrieLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        subscrieLabel.numberOfLines = 2
        subscrieLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        subscrieLabel.textColor = UIColor.white
        subscrieLabel.textAlignment = NSTextAlignment.left
        subscrieLabel.text = "Show Contemporary Art Daily Content only"
        
        thisContentScrollView.addSubview(subscrieLabel)
        
        subscribeSwitch.frame = CGRect(x: 50, y: nameLabel.frame.maxY+15, width: 100, height: 30)
        
        subscribeSwitch.tintColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        subscribeSwitch.onTintColor = UIColor.white
        subscribeSwitch.thumbTintColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        subscribeSwitch.setOn(thisCADFilterOn, animated: false)
        
        thisContentScrollView.addSubview(subscribeSwitch)
        
        let submitButton = UILabel(frame: CGRect(x: 20, y: subscribeSwitch.frame.maxY+50, width: thisScreenBounds.width-40, height: 70))
        submitButton.font = UIFont(name: "Apercu-Bold", size: 18)
        submitButton.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 10
        submitButton.layer.backgroundColor = UIColor.white.cgColor
        submitButton.text = "SUBMIT SEARCH"
        submitButton.isUserInteractionEnabled = true
        
        let submitButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(topSearchView.searchAndClose))
        submitButton.addGestureRecognizer(submitButtonTap)
        
        thisContentScrollView.addSubview(submitButton)
        
        let resetButton = UILabel(frame: CGRect(x: 20, y: submitButton.frame.maxY+50, width: thisScreenBounds.width-40, height: 70))
        resetButton.font = UIFont(name: "Apercu-Bold", size: 18)
        resetButton.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        resetButton.textAlignment = NSTextAlignment.center
        resetButton.layer.cornerRadius = 10
        resetButton.layer.backgroundColor = UIColor.white.cgColor
        resetButton.text = "RESET SEARCH"
        resetButton.isUserInteractionEnabled = true
        
        let resetButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(topSearchView.resetAndGo))
        resetButton.addGestureRecognizer(resetButtonTap)
        
        thisContentScrollView.addSubview(resetButton)
        
        thisContentScrollView.contentSize = CGSize(width: thisScreenBounds.width, height: resetButton.frame.maxY+10)
        
        self.view.addSubview(thisContentScrollView)

    }
    
    @objc func resetAndGo() {
        nameLabel.text = ""
        subscribeSwitch.setOn(false, animated: true)
        searchAndClose()
    }
    @objc func searchAndClose() {
        dismissKeyboard()
        delegateCall?.callSearchFilter(nameLabel.text!, cadFilter: subscribeSwitch.isOn)
        close()
    }
    func close() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.frame = CGRect(x: 0, y: (-self.thisScreenBounds.height), width: self.thisScreenBounds.width, height: self.thisScreenBounds.height)
            }, completion: {
                (value: Bool) in
                self.removeFromParent()
        })
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
    
    func dismissKeyboard () {
        thisContentScrollView.resignFirstResponder()
        
        
        for thisview in thisContentScrollView.subviews {
            if (thisview.isFirstResponder) {
                thisview.resignFirstResponder()
            }
        }
        
    }
    

}
