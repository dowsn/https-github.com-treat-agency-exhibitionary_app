//
//  venueDetailViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 19/04/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//



import Foundation
import GoogleMaps
import MessageUI

struct venueDetails {
    var email:String = ""
    var hours:String = ""
    var lat:String = ""
    var long:String = ""
    var name:String = ""
    var phone:String = ""
    var postcode:String = ""
    var quarter:String = ""
    var stop:String = ""
    var street:String = ""
    var subway:String = ""
    var text:String = ""
    var web:String = ""
    var images:Array<AnyObject>
    var city:String = ""
    var isInChina:String = ""
    var chineseURL:String = ""
}


class venueDetailViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate {

    var thisContentScrollView:UIScrollView = UIScrollView()
    var thisContentView:UIView = UIView()
    let thisScreenBounds = UIScreen.main.bounds
    var detailResponseElement = [venueDetails]()
    var thisEndDate:Date = Date()
    
    var thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    var thisDetailToBeViewed:String = ""
    
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    var thisIsInChina = false
    var thisChineseUrl = ""
    
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setTrack("Venue Detail", parameter: thisDetailToBeViewed)
    }
    
    
    func getData() {
        //let thisUrl = globalData.dbUrl + "venues.json?ids="+thisDetailToBeViewed
        let thisUrl = globalData.dbUrl + "getVenueById?id="+thisDetailToBeViewed
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "GET"
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            
            if error != nil {
                
            } else {
                
                let jsonOptional: Any!
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch _ as NSError {
                    //jsonErrorOptional = error
                    jsonOptional = nil
                }
                if let json = jsonOptional as? Array<AnyObject> {
                
                for item in json {
                    print(item)
                    let theseImages:Array<AnyObject> = [AnyObject]()
                    //item["images"] as! Array<AnyObject>self.nullToNil(item["text"])!
                    
                    let thisDetailElement:venueDetails = venueDetails(email: self.nullToNil(item["email"])!, hours: self.nullToNil(item["hours"])!, lat: self.nullToNil(item["lat"])!, long: self.nullToNil(item["long"])!, name: self.nullToNil(item["name"])!, phone: self.nullToNil(item["phone"])!, postcode: self.nullToNil(item["postcode"])!, quarter: self.nullToNil(item["quarter"])!, stop: self.nullToNil(item["stop"])!, street: self.nullToNil(item["street"])!, subway: self.nullToNil(item["subway"])!, text: "", web: self.nullToNil(item["web"])!, images: theseImages, city: self.nullToNil(item["city"])!, isInChina: self.nullToNil(item["isInChina"])!, chineseURL: self.nullToNil(item["chineseNavigationURL"])!)
                    
                    self.detailResponseElement.append(thisDetailElement)
                }
                
                DispatchQueue.main.async {
                    self.dataDone()
                }
                }
            }
        }
    }
    
    func dataDone() {
        
        if(detailResponseElement[0].isInChina == "1") {
            thisIsInChina = true
        }
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height-100)
        thisContentScrollView.isScrollEnabled = true
        thisContentScrollView.clipsToBounds = false
        
        thisContentView = UIView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 1000))
        
        var thisStartY = CGFloat(5)
        
        if (detailResponseElement[0].lat != "-" && detailResponseElement[0].lat != "") {
        
        let lat:Double = Double(detailResponseElement[0].lat)!
        let long:Double = Double(detailResponseElement[0].long)!
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.width-20), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        thisContentView.addSubview(mapView)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let position = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "LocateButtonsBlack")
        
//        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.opacity = 0.8
        marker.map = mapView
            
        thisContentView.addSubview(mapView)
            
        thisStartY = mapView.frame.maxY+20
            
        }
        
        var thisY = thisStartY
        
        
        if (thisIsInChina) {
            thisChineseUrl = detailResponseElement[0].chineseURL
            
            let chineseLabel = UIButton(frame: CGRect(x: 10, y: thisY, width: thisScreenBounds.width-20, height: 20))
            chineseLabel.titleLabel?.font = UIFont(name: "Apercu-Bold", size: 16)
            chineseLabel.titleLabel?.textAlignment = NSTextAlignment.left
            chineseLabel.backgroundColor = UIColor.white
            chineseLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            chineseLabel.setTitle("Navigate to this venue using amap.com (Chinese)", for: UIControl.State())
            chineseLabel.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            chineseLabel.setTitleColor(UIColor.black, for: UIControl.State())
            
            thisContentView.addSubview(chineseLabel)
            
            let thisChineseTap = UITapGestureRecognizer(target: self, action: #selector(venueDetailViewController.openChineseURL))
            thisChineseTap.delegate = self
            chineseLabel.addGestureRecognizer(thisChineseTap)
            
            
            thisY = chineseLabel.frame.maxY + 20
        } else {
            
            let shareLabel = UIButton(frame: CGRect(x: 10, y: thisY, width: thisScreenBounds.width-20, height: 20))
            shareLabel.titleLabel?.font = UIFont(name: "Apercu-Bold", size: 16)
            shareLabel.titleLabel?.textAlignment = NSTextAlignment.left
            shareLabel.backgroundColor = UIColor.white
            shareLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            shareLabel.setTitle("Navigate to venue", for: UIControl.State())
            shareLabel.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            shareLabel.setTitleColor(UIColor.black, for: UIControl.State())
            
            let thisShareTap = UITapGestureRecognizer(target: self, action: #selector(venueDetailViewController.openMap))
            thisShareTap.delegate = self
            shareLabel.addGestureRecognizer(thisShareTap)
            
            thisContentView.addSubview(shareLabel)
            
            thisY = shareLabel.frame.maxY + 20
            
        }

        
        let venueName = UILabel(frame: CGRect(x: 10, y: thisY, width: thisScreenBounds.width-20, height: 20))
        venueName.font = UIFont(name: "Apercu-Bold", size: 16)
        venueName.textColor = UIColor.black
        venueName.textAlignment = NSTextAlignment.left
        venueName.backgroundColor = UIColor.clear
        venueName.text = detailResponseElement[0].name
        venueName.isUserInteractionEnabled = true
        
        thisContentView.addSubview(venueName)
        
        let venueAdressLabel = UILabel(frame: CGRect(x: 10, y: venueName.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        venueAdressLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        venueAdressLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        venueAdressLabel.textAlignment = NSTextAlignment.left
        venueAdressLabel.backgroundColor = UIColor.clear
        venueAdressLabel.text = detailResponseElement[0].quarter + ", " + detailResponseElement[0].street
        
        thisContentView.addSubview(venueAdressLabel)
        /*
        let hoursLabelLabel = UILabel(frame: CGRect(x: 10, y: thisY, width: thisScreenBounds.width-20, height: 20))
        hoursLabelLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        hoursLabelLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        hoursLabelLabel.textAlignment = NSTextAlignment.left
        hoursLabelLabel.backgroundColor = UIColor.clear
        hoursLabelLabel.text = "Hours"
        
        thisContentView.addSubview(hoursLabelLabel)
        */
        
        let hoursLabel = UILabel(frame: CGRect(x: 10, y: venueAdressLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        hoursLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        hoursLabel.textColor = UIColor.black
        hoursLabel.textAlignment = NSTextAlignment.left
        hoursLabel.backgroundColor = UIColor.clear
        hoursLabel.text = detailResponseElement[0].hours
        
        thisContentView.addSubview(hoursLabel)
        
        let webLabelLabel = UILabel(frame: CGRect(x: 10, y: hoursLabel.frame.maxY+10, width: thisScreenBounds.width-20, height: 20))
        webLabelLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        webLabelLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        webLabelLabel.textAlignment = NSTextAlignment.left
        webLabelLabel.backgroundColor = UIColor.clear
        webLabelLabel.text = "Web"
        
        thisContentView.addSubview(webLabelLabel)
        
        
        let webLabel = UIButton(frame: CGRect(x: 10, y: webLabelLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        webLabel.titleLabel?.font = UIFont(name: "Apercu-Bold", size: 16)
        webLabel.titleLabel?.textAlignment = NSTextAlignment.left
        webLabel.backgroundColor = UIColor.white
        webLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        webLabel.setTitle(detailResponseElement[0].web, for: UIControl.State())
        webLabel.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        webLabel.setTitleColor(UIColor.black, for: UIControl.State())
        
        let thisWebTap = UITapGestureRecognizer(target: self, action: #selector(venueDetailViewController.openURL))
        thisWebTap.delegate = self
        webLabel.addGestureRecognizer(thisWebTap)
        
        thisContentView.addSubview(webLabel)
        
        let callLabelLabel = UILabel(frame: CGRect(x: 10, y: webLabel.frame.maxY+10, width: thisScreenBounds.width-20, height: 20))
        callLabelLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        callLabelLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        callLabelLabel.textAlignment = NSTextAlignment.left
        callLabelLabel.backgroundColor = UIColor.clear
        callLabelLabel.text = "Call"
        
        thisContentView.addSubview(callLabelLabel)
        
        let callLabel = UIButton(frame: CGRect(x: 10, y: callLabelLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        callLabel.titleLabel?.font = UIFont(name: "Apercu-Bold", size: 16)
        callLabel.titleLabel?.textAlignment = NSTextAlignment.left
        callLabel.backgroundColor = UIColor.white
        callLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        callLabel.setTitle(detailResponseElement[0].phone, for: UIControl.State())
        callLabel.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        callLabel.setTitleColor(UIColor.black, for: UIControl.State())
        
        let thisCallTap = UITapGestureRecognizer(target: self, action: #selector(venueDetailViewController.call))
        thisCallTap.delegate = self
        callLabel.addGestureRecognizer(thisCallTap)
        
        thisContentView.addSubview(callLabel)
        
        let mailLabel = UILabel(frame: CGRect(x: 10, y: callLabel.frame.maxY+10, width: thisScreenBounds.width-20, height: 20))
        mailLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        mailLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        mailLabel.textAlignment = NSTextAlignment.left
        mailLabel.backgroundColor = UIColor.clear
        mailLabel.text = "Send an email"
        
        /*
        let mailLabel = UIButton(frame: CGRect(x: 10, y: callLabel.frame.maxY+10, width: thisScreenBounds.width-20, height: 20))
        mailLabel.titleLabel?.font = UIFont(name: "Apercu-Bold", size: 16)
        mailLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        mailLabel.backgroundColor = UIColor.whiteColor()
        mailLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mailLabel.setTitle("Send an email", forState: UIControlState.Normal)
        mailLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        mailLabel.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
 
        
        let thisMailTap = UITapGestureRecognizer(target: self, action: #selector(venueDetailViewController.sendMail))
        thisMailTap.delegate = self
        mailLabel.addGestureRecognizer(thisMailTap)
        */
        
        thisContentView.addSubview(mailLabel)
        
        let mailMailLabel = UIButton(frame: CGRect(x: 10, y: mailLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        mailMailLabel.titleLabel?.font = UIFont(name: "Apercu-Bold", size: 16)
        mailMailLabel.titleLabel?.textAlignment = NSTextAlignment.left
        mailMailLabel.backgroundColor = UIColor.white
        mailMailLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mailMailLabel.setTitle(detailResponseElement[0].email, for: UIControl.State())
        mailMailLabel.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        mailMailLabel.setTitleColor(UIColor.black, for: UIControl.State())
        
        let thisMailMailTap = UITapGestureRecognizer(target: self, action: #selector(venueDetailViewController.sendMail))
        thisMailMailTap.delegate = self
        mailMailLabel.addGestureRecognizer(thisMailMailTap)
        
        thisContentView.addSubview(mailMailLabel)
        
        thisY = mailMailLabel.frame.maxY+10
        
        
        //thisY = shareLabel.frame.maxY
        
        
        thisContentView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisY)
        
        thisContentScrollView.addSubview(thisContentView)
        
        thisContentScrollView.contentSize = CGSize(width: thisScreenBounds.width, height: thisContentView.frame.maxY+100)
        
        self.view.addSubview(thisContentScrollView)
        
    }
    
    @objc func sendMail() {
        let thisURLString = "mailto:" + detailResponseElement[0].email + "/"
        if let checkURL = URL(string: thisURLString) {
            UIApplication.shared.openURL(checkURL)
        }
    }
    
    @objc func openURL() {
        let thisURLString = "http://" + detailResponseElement[0].web + "/"
        
        let checkURL = URL(string: thisURLString)
        
        
        UIApplication.shared.openURL(checkURL!)
    }
    
    @objc func openChineseURL() {
        let thisURLString = thisChineseUrl
        
        let checkURL = URL(string: thisURLString)
        
        
        UIApplication.shared.openURL(checkURL!)
    }
    
    @objc func call() {
        //let stringArray = detailResponseElement[0].phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        
        let stringArray = detailResponseElement[0].phone
        let okayChars:Set<Character> = Set("+1234567890")
        
        
        let newString = String(stringArray.filter {okayChars.contains($0)})
        
        
        //let newString = "+12129951774"
        //let newString = detailResponseElement[0].phone
        
        let thisString = "tel://" + newString
        print(thisString)
        if let checkURL = URL(string: thisString) {
            UIApplication.shared.openURL(checkURL)
        }
    }
    @objc func openMap() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:"comgooglemaps://?saddr=&daddr=\(detailResponseElement[0].lat),\(detailResponseElement[0].long)&directionsmode=driving")!)
            
        } else {
            NSLog("Can't use comgooglemaps://");
        }
    }
    
    func mailShare() {
        
        
    }
        
        /*
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
         */
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        //mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("Exhibitionary Venue Recommendation.")
        mailComposerVC.setMessageBody("Check out "+detailResponseElement[0].name+" with me! <br><br>Don't know Exhibitionary yet? Please download it from the <a href=''>App Store</a>!", isHTML: true)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        //let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        //sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
