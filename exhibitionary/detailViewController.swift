//
//  detailViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 18/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit
import NYTPhotoViewer
import SDWebImage

struct DetailData {
    var headerImageUrl:String
    var headerText:String
    var infoText:String
    var longText:String
    var thisParseEndDate:String = ""
    var venueID:Int
    var venueName:String = ""
    var venueAdress:String = ""
    var images:Array<AnyObject>
    var venueHours:String = ""
    var thisOpensDate:String = ""
    var isFav:Bool = false
}

struct detailImage {
    var imageUrl:String
    var imageCaption:String
}

class detailViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIGestureRecognizerDelegate, NYTPhotosViewControllerDelegate {
    var thisContentScrollView:UIScrollView = UIScrollView()
    var thisContentView:UIView = UIView()
    let thisScreenBounds = UIScreen.main.bounds
    var detailResponseElement = [DetailData]()
    var thisEndDate:Date = Date()
    var plusLabel:UILabel = UILabel()
    var submitButton = UILabel()
    
    var thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    var thisDetailToBeViewed:String = ""
    
    var collectionView:UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewFlowLayout())
    
    var thisVenueDetail:String = ""
    var thisImageDetailUrl:String = ""
    
    var infoTextButton:UILabel = UILabel()
    
    var thisGallerySwipe:imagesScrollOverviewController = imagesScrollOverviewController()!
    var thisIsFav:Int = 0
    
    var photos = [NYTPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpHeader()
        getData()
        setTrack("Exhibition Detail", parameter: thisDetailToBeViewed)
    }
    func closeFromFeed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func closeMe() {
        self.removeFromParent()
    }
    
    func getData() {
        //let thisUrl = globalData.dbUrl + "venues.json?ids=4846"
        let thisUrl = globalData.dbUrl + "getExhibitionsById?id="+thisDetailToBeViewed
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        let thisAppDelegate = returnAppDelegate()
        if (thisAppDelegate.sessionUserID != "") {
            let postString = "user_id="+thisAppDelegate.sessionUserID
            let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
            request.httpBody = requestBodyData
        }
        
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
                    
                    let theseImages:Array<AnyObject> = item["images"] as! Array<AnyObject>
                    
                    var thisIsFav:Bool = false
                    if (item["isFav"]! as! Bool == true) {
                        thisIsFav = true
                    }

                    let thisDetailElement:DetailData = DetailData(headerImageUrl: "", headerText: item["title"] as! String, infoText: item["start"] as! String, longText: item["text"] as! String, thisParseEndDate: self.nullToNil(item["end"])!, venueID: item["venue_id"] as! Int, venueName: self.nullToNil(item["venue_name"])!, venueAdress: self.nullToNil(item["venue_street"])!, images: theseImages, venueHours: self.nullToNil(item["venue_hours"])!, thisOpensDate: self.nullToNil(item["opening_start"])!, isFav: thisIsFav)
                    
                    self.detailResponseElement.append(thisDetailElement)
                    
                }
                DispatchQueue.main.async {
                    self.dataDone()
                }
                }
            }
        }
        
    }
    
    func restTime(_ targetDate:String) -> String {
        let df:DateFormatter = DateFormatter()
        df.locale = Locale(identifier: "us")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        df.timeZone = TimeZone(identifier: "UTC")
        let thisEndDateFromString:Date = df.date(from: targetDate)!
        thisEndDate = thisEndDateFromString
        let userCalendar = Calendar.current
        
        let endDate = thisEndDate
        
        let hourMinuteComponents:NSCalendar.Unit = [NSCalendar.Unit.day]
        let timeDifference = (userCalendar as NSCalendar).components(hourMinuteComponents, from: Date(), to: endDate, options: [])
        
        let thisReturnText = String(describing: timeDifference.day)
        return thisReturnText
    }
    
    @objc func addToFavs() {
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        let thisSessionID = thisAppDelegate.sessionID
        
        if (thisUserID != "") {
                var thisUrl = ""
            if (thisIsFav == 1) {
                thisUrl = globalData.globalUrl + "delete_favourite"
                
            } else {
                thisUrl = globalData.globalUrl + "add_favourite"
                
            }
            
            let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
            request.httpMethod = "POST"
            var postString = "session_id="+thisSessionID+"&"
            postString = postString + "user_id="+thisUserID+"&"
            postString = postString + "eyeout_id="+thisDetailToBeViewed
            let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
            request.httpBody = requestBodyData
            submitButton.text = "SAVING..."
            //print(thisUrl)
            
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                let jsonOptional: Any!
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    if let json = jsonOptional as? Dictionary<String, AnyObject> {
                        if let response:AnyObject = json["response"] as AnyObject? {
                            //print(response)
                        }
                    }
                    
                    self.submitButton.text = "SAVED"
                    DispatchQueue.main.async {
                        if (self.thisIsFav == 1) {
                            self.isNotAFav()
                            self.thisIsFav = 0
                        } else {
                            self.isAFav()
                            self.thisIsFav = 1
                        }
                    }
                    
                } catch _ as NSError {
                    //jsonErrorOptional = error
                    jsonOptional = nil
                }

                
            }
        }
            
        } else {
            let thisMessage = "Where did my picks go? No problem, just log in."
            let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                self.notLoggedIn()
                })
            self.present(failureMessage, animated: true, completion: nil)
            return
        }
        
    }
    
    func notLoggedIn() {
        let revealController = self.revealViewController()
        revealController?.revealToggle(animated: true)
    }
    
    
    func isNotAFav() {
        self.thisIsFav = 0
        let currentY = submitButton.frame.minY
        
        submitButton.removeFromSuperview()
        plusLabel.removeFromSuperview()
        
        submitButton = UILabel(frame: CGRect(x: 20, y: currentY, width: thisScreenBounds.width-40, height: 60))
        
        submitButton.font = UIFont(name: "Apercu-Bold", size: 17)
        submitButton.textColor = UIColor.white
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 5
        submitButton.layer.backgroundColor = UIColor(white:0.000, alpha:0.020).cgColor
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.borderWidth = 1
        submitButton.text = "ADD TO MY PICKS"
        submitButton.isUserInteractionEnabled = true
        
        plusLabel = UILabel(frame: CGRect(x: submitButton.frame.width-20, y: submitButton.frame.minY+20, width: 20, height: 20))
        plusLabel.layer.cornerRadius = 10
        plusLabel.layer.backgroundColor = UIColor.white.cgColor
        plusLabel.text = "+"
        plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.font = UIFont(name: "Apercu-Bold", size: 17)
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.isUserInteractionEnabled = true
        
        
        let submitButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.addToFavs))
        let submitButtonPlusTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.addToFavs))
        submitButton.addGestureRecognizer(submitButtonTap)
        plusLabel.addGestureRecognizer(submitButtonPlusTap)
        
        thisContentView.addSubview(submitButton)
        thisContentView.addSubview(plusLabel)
    }
    func isAFav() {
        self.thisIsFav = 1
        let currentY = submitButton.frame.minY
        
        submitButton.removeFromSuperview()
        plusLabel.removeFromSuperview()
        
        submitButton = UILabel(frame: CGRect(x: 20, y: currentY, width: thisScreenBounds.width-40, height: 60))
        
        submitButton.font = UIFont(name: "Apercu-Bold", size: 17)
        submitButton.textColor = UIColor.white
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 5
        submitButton.layer.backgroundColor = UIColor(white:0.000, alpha:0.020).cgColor
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.borderWidth = 1
        submitButton.text = "REMOVE FROM MY PICKS"
        submitButton.isUserInteractionEnabled = true
        
        plusLabel = UILabel(frame: CGRect(x: submitButton.frame.width-20, y: submitButton.frame.minY+20, width: 20, height: 20))
        plusLabel.layer.cornerRadius = 10
        plusLabel.layer.backgroundColor = UIColor.black.cgColor
        plusLabel.text = "-"
        plusLabel.textColor = UIColor.white
        //UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.font = UIFont(name: "Apercu-Bold", size: 17)
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.isUserInteractionEnabled = true
        
        
        let submitButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.addToFavs))
        let submitButtonPlusTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.addToFavs))
        
        submitButton.addGestureRecognizer(submitButtonTap)
        plusLabel.addGestureRecognizer(submitButtonPlusTap)
        
        thisContentView.addSubview(submitButton)
        thisContentView.addSubview(plusLabel)
    }
    
    func opensToday (_ openingDate:String) -> Bool {
        var isOpeningToday = false
        
        if (openingDate != "-") {
            
            var thisEndDate:Date = Date()
            let df:DateFormatter = DateFormatter()
            df.locale = Locale(identifier: "us")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let thisEndDateFromString:Date = df.date(from: openingDate)!
            thisEndDate = thisEndDateFromString
            
            let userCalendar = Calendar.current
            var components:DateComponents = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
            
            let today:Date = userCalendar.date(from: components)!
            
            components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: thisEndDate)
            
            let otherDate:Date = userCalendar.date(from: components)!
            
            if(today == otherDate) {
                isOpeningToday = true
            }
        }
        return isOpeningToday
    }
    
    func opensFuture (_ openingDate:String) -> Bool {
        var isOpeningToday = false
        
        if (openingDate != "-") {
            
            var thisEndDate:Date = Date()
            let df:DateFormatter = DateFormatter()
            df.locale = Locale(identifier: "us")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let thisEndDateFromString:Date = df.date(from: openingDate)!
            thisEndDate = thisEndDateFromString
            
            let userCalendar = Calendar.current
            var components:DateComponents = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
            
            let today:Date = userCalendar.date(from: components)!
            
            components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: thisEndDate)
            
            let otherDate:Date = userCalendar.date(from: components)!
            
            if otherDate.compare(today) == ComparisonResult.orderedDescending {
                isOpeningToday = true
            }
            
        }
        return isOpeningToday
        
    }
    
    func dataDone() {
        
        thisVenueDetail = String(detailResponseElement[0].venueID)
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        
        
        
        thisContentView.isUserInteractionEnabled = true
        thisContentScrollView.isUserInteractionEnabled = true
        /*
        if (thisUserID != "") {
            let thisAddFavButton = UIBarButtonItem(title: "Add to picks", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(detailViewController.addToFavs))
            self.navigationItem.rightBarButtonItem = thisAddFavButton
            }
        */
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height-100)
        thisContentScrollView.isScrollEnabled = true
        thisContentScrollView.clipsToBounds = false
        
        thisContentView = UIView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 1000))
        
        let headerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.width-20))
        headerImage.contentMode = UIView.ContentMode.scaleAspectFill
        headerImage.clipsToBounds = true
        headerImage.sd_setImage(with: URL(string: detailResponseElement[0].headerImageUrl))
        headerImage.backgroundColor = UIColor.gray
        
        
        if (detailResponseElement[0].images.count > 0) {
            let thisImageUrl = detailResponseElement[0].images[0]["url"] as! String
            headerImage.sd_setImageWithPreviousCachedImage(with: URL(string: thisImageUrl) , placeholderImage: UIImage(), options: [], progress: nil, completed: nil)
        }
        
        
        let imageDarkener:UIView = UIView()
        imageDarkener.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.width-20)
        imageDarkener.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        
        submitButton = UILabel(frame: CGRect(x: 20, y: headerImage.frame.maxY-90, width: thisScreenBounds.width-40, height: 60))
        
        submitButton.font = UIFont(name: "Apercu-Bold", size: 17)
        submitButton.textColor = UIColor.white
        submitButton.textAlignment = NSTextAlignment.center
        submitButton.layer.cornerRadius = 5
        submitButton.layer.backgroundColor = UIColor(white:0.000, alpha:0.020).cgColor
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.borderWidth = 1
        submitButton.text = "ADD TO MY PICKS"
        submitButton.isUserInteractionEnabled = true
        
        plusLabel = UILabel(frame: CGRect(x: submitButton.frame.width-20, y: submitButton.frame.minY+20, width: 20, height: 20))
        plusLabel.layer.cornerRadius = 10
        plusLabel.layer.backgroundColor = UIColor.white.cgColor
        plusLabel.text = "+"
        plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.font = UIFont(name: "Apercu-Bold", size: 17)
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.isUserInteractionEnabled = true
 
        
        let submitButtonTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.addToFavs))
        let submitButtonPlusTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.addToFavs))
        submitButton.addGestureRecognizer(submitButtonTap)
        plusLabel.addGestureRecognizer(submitButtonPlusTap)
        
        //imageDarkener.addGestureRecognizer(thisVenuaTap)
        
        thisContentView.addSubview(headerImage)
        thisContentView.addSubview(imageDarkener)
        thisContentView.addSubview(submitButton)
        thisContentView.addSubview(plusLabel)
        
        let headLineText = UITextView(frame: CGRect(x: 10, y: 85, width: thisScreenBounds.width-20, height: 120))
        headLineText.font = UIFont(name: "Apercu-Bold", size: 24)
        headLineText.textColor = UIColor.white
        headLineText.backgroundColor = UIColor.clear
        headLineText.textAlignment = NSTextAlignment.center
        headLineText.isEditable = false
        
        let thisFont = UIFont(name: "Apercu-Bold", size: 24)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        headLineText.attributedText = NSAttributedString(string: detailResponseElement[0].headerText, attributes: [NSAttributedString.Key.font: thisFont!, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyle])
     
        thisContentView.addSubview(headLineText)
        
        let thisNormalFont = UIFont(name: "Apercu-Regular", size: 16)
        let thisNormalParagraphStyle = NSMutableParagraphStyle()
        thisNormalParagraphStyle.alignment = NSTextAlignment.left
        
        /*
        infoTextButton.frame = CGRect(x: 10, y: headerImage.frame.maxY+10, width: thisScreenBounds.width, height: 40)
        //infoTextButton.backgroundColor = UIColor.yellowColor()
        //infoText.editable = false
        infoTextButton.textColor = UIColor.blackColor()
        //infoText.scrollEnabled = false
        
        
        let thisInfoText = "VENUE INFO " + String(detailResponseElement[0].venueID)
        infoTextButton.attributedText = NSAttributedString(string: thisInfoText, attributes: [NSFontAttributeName: thisNormalFont!, NSBackgroundColorAttributeName: UIColor.clearColor(), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: thisNormalParagraphStyle])
        
        infoTextButton.userInteractionEnabled = true
        
        //infoTextButton.addGestureRecognizer(thisVenuaTap)
        
        
        
       
        
        //infoText.frame =
        //DYNAMIC HEIGHT?
        
        thisContentScrollView.addSubview(infoTextButton)
        */
        
        var thisFirstY = headerImage.frame.maxY+10
        
        if (opensToday(detailResponseElement[0].thisOpensDate)) {
            
            var thisEndDate:Date = Date(timeIntervalSince1970: 0)
            let df:DateFormatter = DateFormatter()
            df.locale = Locale(identifier: "us")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let thisEndDateFromString:Date = df.date(from: detailResponseElement[0].thisOpensDate)!
            thisEndDate = thisEndDateFromString
            
            
            let dateFormatterHour = DateFormatter()
            dateFormatterHour.timeZone = TimeZone(identifier: "UTC")
            dateFormatterHour.dateFormat = "HH:mm"
            let thisHourDateString:String = dateFormatterHour.string(from: thisEndDate)
            
            
            let opensLabel = UILabel(frame: CGRect(x: 10, y: thisFirstY, width: thisScreenBounds.width-20, height: 20))
            
            opensLabel.font = UIFont(name: "Apercu-Bold", size: 16)
            opensLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 255)
            opensLabel.textAlignment = NSTextAlignment.left
            opensLabel.backgroundColor = UIColor.clear
            opensLabel.text = "Opens today! Starting: " + thisHourDateString
            
            thisContentView.addSubview(opensLabel)
            
            thisFirstY = opensLabel.frame.maxY+10
        
        }
        
        let throughLabel = UILabel(frame: CGRect(x: 10, y: thisFirstY, width: thisScreenBounds.width-20, height: 20))
        let dateLabel = UILabel(frame: CGRect(x: 10, y: throughLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        var dateString = "N/A"
        
        if(opensFuture(detailResponseElement[0].thisOpensDate)) {
            
            
            throughLabel.font = UIFont(name: "Apercu-Bold", size: 16)
            throughLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
            throughLabel.textAlignment = NSTextAlignment.left
            throughLabel.backgroundColor = UIColor.clear
            throughLabel.text = "Opens"
            
            if (detailResponseElement[0].thisOpensDate != "-") {
                let df:DateFormatter = DateFormatter()
                df.locale = Locale(identifier: "us")
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                //df.dateFormat = "yyyy-MM-dd"
                let thisEndDateFromString:Date = df.date(from: detailResponseElement[0].thisOpensDate)!
                
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.long
                formatter.timeStyle = .none
                
                dateString = formatter.string(from: thisEndDateFromString)
            }
            
        } else {
            throughLabel.font = UIFont(name: "Apercu-Bold", size: 16)
            throughLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
            throughLabel.textAlignment = NSTextAlignment.left
            throughLabel.backgroundColor = UIColor.clear
            throughLabel.text = "Through"
            
            if (detailResponseElement[0].thisParseEndDate != "-") {
                let df:DateFormatter = DateFormatter()
                df.locale = Locale(identifier: "us")
                //df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                df.dateFormat = "yyyy-MM-dd"
                let thisEndDateFromString:Date = df.date(from: detailResponseElement[0].thisParseEndDate)!
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "us")
                formatter.dateStyle = DateFormatter.Style.long
                formatter.timeStyle = .none
                
                dateString = formatter.string(from: thisEndDateFromString)
            }
        
        }
        /*
        
            
         
            
            var dateString = "N/A"
            
            if (detailResponseElement[0].thisParseEndDate != "-") {
                let df:NSDateFormatter = NSDateFormatter()
                df.locale = NSLocale(localeIdentifier: "us")
                //df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                df.dateFormat = "yyyy-MM-dd"
                let thisEndDateFromString:NSDate = df.dateFromString(detailResponseElement[0].thisOpensDate)!
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                formatter.timeStyle = .NoStyle
                
                dateString = formatter.stringFromDate(thisEndDateFromString)
                
            }
            
            
            
            dateLabel.font = UIFont(name: "Apercu-Bold", size: 16)
            dateLabel.textColor = UIColor.blackColor()
            dateLabel.textAlignment = NSTextAlignment.Left
            dateLabel.backgroundColor = UIColor.clearColor()
            dateLabel.text = dateString
            
            thisContentView.addSubview(dateLabel)
        
        } else {
            
            throughLabel.font = UIFont(name: "Apercu-Bold", size: 16)
            throughLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
            throughLabel.textAlignment = NSTextAlignment.Left
            throughLabel.backgroundColor = UIColor.clearColor()
            throughLabel.text = "Through"
            
            thisContentView.addSubview(throughLabel)
            
            var dateString = "N/A"
            
            if (detailResponseElement[0].thisParseEndDate != "-") {
                let df:NSDateFormatter = NSDateFormatter()
                df.locale = NSLocale(localeIdentifier: "us")
                //df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                df.dateFormat = "yyyy-MM-dd"
                let thisEndDateFromString:NSDate = df.dateFromString(detailResponseElement[0].thisParseEndDate)!
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                formatter.timeStyle = .NoStyle
                
                dateString = formatter.stringFromDate(thisEndDateFromString)
                
            }
            
            
            
            dateLabel.font = UIFont(name: "Apercu-Bold", size: 16)
            dateLabel.textColor = UIColor.blackColor()
            dateLabel.textAlignment = NSTextAlignment.Left
            dateLabel.backgroundColor = UIColor.clearColor()
            dateLabel.text = dateString
            
            thisContentView.addSubview(dateLabel)
        
        }*/
        
        
        
        thisContentView.addSubview(throughLabel)
        
        dateLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        dateLabel.textColor = UIColor.black
        dateLabel.textAlignment = NSTextAlignment.left
        dateLabel.backgroundColor = UIColor.clear
        dateLabel.text = dateString
        
        thisContentView.addSubview(dateLabel)
        
        
        /*
        let daysLeftText = UILabel()
        daysLeftText.font = UIFont(name: "Apercu-Regular", size: 14)
        daysLeftText.tintColor = UIColor.blackColor()
        daysLeftText.textAlignment = NSTextAlignment.Left
        
        var thisLongTextY = infoTextButton.frame.maxY+10
        
        if (detailResponseElement[0].thisParseEndDate != "-") {
            let thisEndDateText:String = restTime(detailResponseElement[0].thisParseEndDate)
            daysLeftText.text = "Days left: " + thisEndDateText
            daysLeftText.frame = CGRect(x: 10, y: infoTextButton.frame.maxY+10, width: thisScreenBounds.width, height: 20)
            thisLongTextY = daysLeftText.frame.maxY+10
            thisContentView.addSubview(daysLeftText)
        }
        */
        
        
        
        let venueLabel = UILabel(frame: CGRect(x: 10, y: dateLabel.frame.maxY+10, width: thisScreenBounds.width-20, height: 20))
        venueLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        venueLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        venueLabel.textAlignment = NSTextAlignment.left
        venueLabel.backgroundColor = UIColor.clear
        venueLabel.text = "Venue"
        
        thisContentView.addSubview(venueLabel)
        
        let venueName = UILabel(frame: CGRect(x: 10, y: venueLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        venueName.font = UIFont(name: "Apercu-Bold", size: 16)
        venueName.textColor = UIColor.black
        venueName.textAlignment = NSTextAlignment.left
        venueName.backgroundColor = UIColor.clear
        venueName.text = detailResponseElement[0].venueName
        venueName.isUserInteractionEnabled = true
        
        thisContentView.addSubview(venueName)
        
        let thisVenuaTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.openVenue))
        venueName.addGestureRecognizer(thisVenuaTap)
        
        let venueAdressLabel = UILabel(frame: CGRect(x: 10, y: venueName.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        venueAdressLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        venueAdressLabel.textColor = UIColor.black
        //UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        venueAdressLabel.textAlignment = NSTextAlignment.left
        venueAdressLabel.backgroundColor = UIColor.clear
        venueAdressLabel.text = detailResponseElement[0].venueAdress
        venueAdressLabel.isUserInteractionEnabled = true
        
        thisContentView.addSubview(venueAdressLabel)
        
        let thisVenauAdressTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.openVenue))
        venueAdressLabel.addGestureRecognizer(thisVenauAdressTap)
        
        let thisArrowImage = UIImage(named: "RightArrow")
        let venueDetailArrow = UIImageView(image: thisArrowImage)
        let thisY = CGFloat(venueAdressLabel.frame.maxY - venueAdressLabel.frame.height - 10)
        venueDetailArrow.frame = CGRect(x: thisScreenBounds.width-30, y: thisY, width: 20, height: 20)
        venueDetailArrow.contentMode = .scaleAspectFill
        
        thisContentView.addSubview(venueDetailArrow)
        
        let thisVenueArrowTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailViewController.openVenue))
        venueDetailArrow.addGestureRecognizer(thisVenueArrowTap)
        
        let hoursLabelLabel = UILabel(frame: CGRect(x: 10, y: venueAdressLabel.frame.maxY+10, width: thisScreenBounds.width-20, height: 20))
        hoursLabelLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        hoursLabelLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        hoursLabelLabel.textAlignment = NSTextAlignment.left
        hoursLabelLabel.backgroundColor = UIColor.clear
        hoursLabelLabel.text = "Hours"
        
        thisContentView.addSubview(hoursLabelLabel)
        
        let hoursLabel = UILabel(frame: CGRect(x: 10, y: hoursLabelLabel.frame.maxY, width: thisScreenBounds.width-20, height: 20))
        hoursLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        hoursLabel.textColor = UIColor.black
        hoursLabel.textAlignment = NSTextAlignment.left
        hoursLabel.backgroundColor = UIColor.clear
        hoursLabel.text = detailResponseElement[0].venueHours
        
        thisContentView.addSubview(hoursLabel)
        
        /*
        thisContentView.addSubview(venueAdressLabel)
        thisGallerySwipe = imagesScrollOverviewController()
        thisGallerySwipe.images = detailResponseElement[0].images
        thisGallerySwipe.receivedImagesAndSetsPages(detailResponseElement[0].images)
        
        thisGallerySwipe.view.frame = CGRect(x: 0, y: venueAdressLabel.frame.maxY+10, width: thisScreenBounds.width, height: thisScreenBounds.width/3)
        thisGallerySwipe.delegate = thisGallerySwipe
        thisGallerySwipe.dataSource = thisGallerySwipe
        
        thisContentView.addSubview(thisGallerySwipe.view)
        */
        
        let thisGallerSwpieHolder = UIScrollView(frame: CGRect(x: 0, y: hoursLabel.frame.maxY+10, width: thisScreenBounds.width, height: thisScreenBounds.width/3))
        
        let thisGalleryInnerholder:classicalImageScrollerView = classicalImageScrollerView()
        
        thisGalleryInnerholder.thisParentView = self
        thisGalleryInnerholder.images = detailResponseElement[0].images
        let thisMaxX:CGFloat = (CGFloat(detailResponseElement[0].images.count) * (thisScreenBounds.width/3+10))
        
        thisGalleryInnerholder.view.frame = CGRect(x: 0, y: 0, width: thisMaxX, height: thisScreenBounds.width/3)
        
        thisGallerSwpieHolder.contentSize = CGSize(width: thisMaxX, height: thisScreenBounds.width/3)
        thisGalleryInnerholder.view.isUserInteractionEnabled = true
        
        thisGallerSwpieHolder.addSubview(thisGalleryInnerholder.view)
        
        thisGallerSwpieHolder.isUserInteractionEnabled = true
        
        thisContentView.addSubview(thisGallerSwpieHolder)
        
        let pressTitel = UILabel(frame: CGRect(x: 10, y: thisGallerSwpieHolder.frame.maxY+13, width: thisScreenBounds.width-20, height: 20))
        pressTitel.font = UIFont(name: "Apercu-Bold", size: 18)
        pressTitel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 255)
        pressTitel.textAlignment = NSTextAlignment.left
        pressTitel.backgroundColor = UIColor.clear
        pressTitel.text = "Press Release"
        
        thisContentView.addSubview(pressTitel)
        
        let longText = UITextView()
        longText.backgroundColor = UIColor.white
        longText.isEditable = false
        longText.isScrollEnabled = false
        longText.textColor = UIColor.black
        longText.font = thisNormalFont!
        longText.dataDetectorTypes = .link
        
        var attributeHtmlString:NSMutableAttributedString = NSMutableAttributedString(string: "Error")
        
        do {
            let thisHtmlString:NSString = self.detailResponseElement[0].longText as NSString
        
            attributeHtmlString = try NSMutableAttributedString(data: thisHtmlString.data(using: String.Encoding.unicode.rawValue)!, options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
            attributeHtmlString.beginEditing()
            
            attributeHtmlString.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, attributeHtmlString.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (value, range, stop) -> Void in
                if let oldFont = value as? UIFont {
                    //print(oldFont.fontName)
                    if(oldFont.fontName == "TimesNewRomanPS-BoldMT") {
                        attributeHtmlString.removeAttribute(NSAttributedString.Key.font, range: range)
                        attributeHtmlString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Apercu-Bold", size: 16)!, range: range)
                    }
                    else {
                        attributeHtmlString.removeAttribute(NSAttributedString.Key.font, range: range)
                        attributeHtmlString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Apercu-Regular", size: 16)!, range: range)
                    }
                }
            }
            attributeHtmlString.endEditing()
           
            
        } catch _ {
        
        }
        
        longText.attributedText = attributeHtmlString
        
            
        //NSAttributedString(string: String(htmlEncodedString: self.detailResponseElement[0].longText), attributes: [NSFontAttributeName: thisNormalFont!, NSBackgroundColorAttributeName: UIColor.clearColor(), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: thisNormalParagraphStyle])
       
        longText.contentInset = UIEdgeInsets(top: 0,left: -4,bottom: 0,right: 0)
        longText.layoutIfNeeded()
        
        let thisMaxHeightSize = longText.sizeThatFits(CGSize(width: thisScreenBounds.width, height: CGFloat.greatestFiniteMagnitude))
        
        longText.frame = CGRect(x: 10, y: pressTitel.frame.maxY+2, width: thisScreenBounds.width-10, height: thisMaxHeightSize.height*1.1)
        
        thisContentView.addSubview(longText)
        
        /*
         print(detailResponseElement[0].images.count)
         if (detailResponseElement[0].images.count > 1) {
            //insertAlbumView(longText.frame.maxY)
            
        } else {
 
        }
         */
        
        thisContentView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: longText.frame.maxY)
        thisContentScrollView.addSubview(thisContentView)
        thisContentScrollView.contentSize = CGSize(width: thisScreenBounds.width, height: thisContentView.frame.maxY+10)
        
        self.view.addSubview(thisContentScrollView)
        
        if (thisUserID != "") {
            if (detailResponseElement[0].isFav) {
                self.isAFav()
            }
        }
 
    }
    
    @objc func imageTap(_ sender:UITapGestureRecognizer) {
        let thisInt = Int(sender.view!.tag)
        openImage(thisInt)
    }
   
    
    func handleRightSwipes() {
        
    }
    
    func handleLeftSwipes() {
        
    }
    
    func insertAlbumView(_ desigerdHeight:CGFloat) {
       /*
        let picturesLabel = UILabel()
        picturesLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        picturesLabel.tintColor = UIColor.blackColor()
        picturesLabel.textAlignment = NSTextAlignment.Left
        picturesLabel.frame = CGRectMake(10, desigerdHeight, thisScreenBounds.width-10, 30)
        picturesLabel.text = "Photos"
        
        thisContentView.addSubview(picturesLabel)

        let thisHeight = thisScreenBounds.width/4
        var collectionViewHeight:Int = Int(ceil(Double(detailResponseElement[0].images.count)/2))*Int(thisHeight)
        if (collectionViewHeight < Int(thisHeight)) {
            collectionViewHeight = Int(thisHeight)
        }
        
        
        collectionView.frame = CGRectMake(0, picturesLabel.frame.maxY+5, thisScreenBounds.width, CGFloat(collectionViewHeight))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(FotosOverViewCell.self, forCellWithReuseIdentifier: "FotosOverViewCell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.scrollEnabled = false
        collectionView.userInteractionEnabled = true
        
        thisContentView.addSubview(collectionView)
        thisContentScrollView.addSubview(thisContentView)
        
        thisContentScrollView.contentSize = CGSize(width: thisScreenBounds.width, height: thisContentView.frame.maxY+200)
        
        self.view.addSubview(thisContentScrollView)
 */
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0//self.detailResponseElement[0].images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FotosOverViewCell", for: indexPath) as! FotosOverViewCell
        
        /*
        let thisElement = detailResponseElement[0].images[indexPath.row]
        //let thisAlbumName = thisElement.albumName as String!
        cell.thisFotoUrl = thisElement["url"] as! String
        let thisImageUrl:String = thisElement["url"] as! String
        if (!thisImageUrl.isEmpty) {
            cell.image.sd_setImageWithPreviousCachedImageWithURL(NSURL(string: thisImageUrl), placeholderImage: UIImage(), options: [], progress: nil, completed: {image, error, imagecachetype, url in
                
            })
        }*/
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((thisScreenBounds.width/4)), height: thisScreenBounds.width/4)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /*
        let thisElement = detailResponseElement[0].images[indexPath.row]
        thisImageDetailUrl = thisElement["url"] as! String
        openImage()
         */
    }
    
    @objc func openVenue() {
        performSegue(withIdentifier: "showVenue", sender: self)
    }
    
    func openImage(_ id:Int) {
        
        //let thisTargetUrl = detailResponseElement[0].images[0]["url"] as! String
        //print(thisTargetUrl)
        
        let thisArray = detailResponseElement[0].images
        self.photos = [NYTPhoto]()
        
        for item in thisArray {
            let thisURLString = item["url"] as! String
            
            
            let thisDownloader:SDWebImageManager = SDWebImageManager()
            thisDownloader.downloadImage(with: URL(string: thisURLString), options: SDWebImageOptions.continueInBackground, progress: {receivedSize, expectedSize in
 
                }, completed: {image, error, cacheType, finished, imageURL in
                    let thisAttributedTitle:NSAttributedString = NSAttributedString(string: "")
                    let thisNYPhoto:exhibitionPhoto = exhibitionPhoto(image: image, imageData: nil, attributedCaptionTitle: thisAttributedTitle)
                    self.photos.append(thisNYPhoto)
                    
            })
        }
        
        let photosViewController = NYTPhotosViewController(photos: photos)
        present(photosViewController, animated: true, completion: nil)
        photosViewController.rightBarButtonItem = nil
        photosViewController.display(photos[id], animated: true)
        //performSegueWithIdentifier("showImageDetail", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showVenue") {
            let nextViewController = (segue.destination) as! venueDetailViewController
            nextViewController.thisDetailToBeViewed = self.thisVenueDetail
        }
        if(segue.identifier == "showImageDetail") {
            let nextViewController = (segue.destination) as! imageDetailViewer
            nextViewController.thisTargetUrl = thisImageDetailUrl
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

