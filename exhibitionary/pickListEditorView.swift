//
//  pickListEditorView.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 28/04/2017.
//  Copyright © 2017 Such Company LLC. All rights reserved.
//

import Foundation
import AMPopTip

class pickListEditorView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    //http://fileserver.istvanszilagyi.com/exhibitionary/api/getExhibitions?city_id=2&limit=100&offet=0&search=berlin&cad=1
    
    let thisScreenBounds = UIScreen.main.bounds
    var responseElements = [feedListElementData]()
    
    var tableView:UITableView = UITableView()
    var thisUserID = ""
    var thisSessionID = ""
    var thisSelectedUrl = ""
    var thisSelectedTitle = ""
    var thisSelectedID = ""
    var thisSelectedCity = ""
    
    var feedSelectionArray:Array<String> = Array()
    var thisGrey:Bool = true
    var thisActualCellIndex = 0
//    var popTip = AMPopTip()
    var selectedIDS:Array<Int> = Array()
    
    var thisShareScreen:UIView = UIView()
    var thisShareScreenActive = false
    //var thisParentController:feedViewController = feedViewController()
    var thisLink = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTrack("Pickediting", parameter: "")
        let thisAppDelegate = returnAppDelegate()
        if (thisAppDelegate.sessionUserID == "") {
            noLogin()
        } else {
            getData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getData() {
        responseElements = [feedListElementData]()
        
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "get_user_picklist"
        //let thisUrl = globalData.dbUrl + "getFutureExhibitions?city_id=" + String(returnAppDelegate().thisCityID)
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        if (thisAppDelegate.sessionUserID != "") {
            var postString = "picklist_user_id="+thisAppDelegate.sessionUserID
            postString = postString + "&loggedin_user_id="+thisAppDelegate.sessionUserID
            postString = postString + "&city_id="+String(thisAppDelegate.thisCityID)
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
                if let jsonResponse = jsonOptional as? Dictionary<String, AnyObject> {
                
                if let json = jsonResponse["exhibitions"] as? Array<AnyObject> {
                    
                    self.thisLink = jsonResponse["list_url"] as! String
                    for item in json {
                        //print(item)
                        
                        
                        
                        var thisImageURL = ""
                        let theseImages:Array<AnyObject> = item["images"] as! Array<AnyObject>
                        if (theseImages.count > 0) {
                            thisImageURL = theseImages[0]["url"] as! String
                        }
                        
                        
                        var thisIsFav:Bool = false
                        if (item["isFav"]! as! Bool == true) {
                            thisIsFav = true
                        }
                        
                        var thisIsOnPickList:Bool = false
                        if (item["isInPicklist"]! as! Bool == true) {
                            thisIsOnPickList = true
                        }
                        
                         let thisFeedElement:feedListElementData = feedListElementData(targetID: item["id"]! as! Int, labelText: item["title"] as! String, backgroundImageURL: thisImageURL, featured: false, images: theseImages, thisParseEndDate: self.nullToNil(item["end"])!, thisParseStartDate: self.nullToNil(item["start"])!,venueAdress: self.nullToNil(item["venue_quarter"])!, venueName: self.nullToNil(item["venue_name"])!, sortingName: self.nullToNil(item["venue_name"])!, isFav: thisIsFav, isOnPickList: thisIsOnPickList, thisCategoryID: item["category_id"]! as! Int, thisCategoryString: self.nullToNil(item["category_name"])!)
                        
                        //let thisFeedElement:feedListElementData = feedListElementData(targetID: item["id"]! as! Int, labelText: item["title"] as! String, backgroundImageURL: thisImageURL, featured: false, images: theseImages, thisParseEndDate: self.nullToNil(item["end"])!, thisParseStartDate: self.nullToNil(item["start"])!,venueAdress: self.nullToNil(item["venue_quarter"])!, venueName: self.nullToNil(item["venue_name"])!, sortingName: self.nullToNil(item["venue_name"])!, isFav: thisIsFav, isOnPickList: thisIsOnPickList)
                        
                            self.responseElements.append(thisFeedElement)
                        }
                    
                    DispatchQueue.main.async {
                        
                        if (self.responseElements.count == 0) {
                            self.noData()
                        } else {
                            self.dataDone()
                        }
                    }
                } else {
                    self.noData()
                    }
                }
            }
        }
    }
    
    func noLogin() {
        let thisMessage = "You need to be logged in to publish pick lists!"
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            
        })
        self.present(failureMessage, animated: true, completion: nil)
    }
    func noData() {
        
        let thisMessage = "Looks like you have no picks yet. You can add your picks in Current and Openings!"
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        self.present(failureMessage, animated: true, completion: nil)
    }
    
    func dataDone() {
        createTableView()
    }
    
    func createTableView() {
        //removeIndicatior()
        
        var thisY = 30
        
        /*
        thisY = 30
        let thisTextHint = UILabel(frame: CGRect(x: 30, y: thisY, width: Int(thisScreenBounds.width-60), height: 50))
        thisTextHint.text = "Select the exhibitions you want to list on your picklist for this city below."
        //FONT
        thisTextHint.textColor = UIColor.black
        thisTextHint.font = UIFont(name: "Apercu-Bold", size: 12)
        thisTextHint.numberOfLines = 4
        thisTextHint.textAlignment = .center
        self.view.addSubview(thisTextHint)
        */
        
        thisY = 0
        
        thisShareScreen = UIView(frame: CGRect(x: 0, y: thisY, width: Int(thisScreenBounds.width), height: 40))
        thisShareScreen.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
        
        let shareButton = UIImageView(frame: CGRect(x: thisScreenBounds.width-30, y: 10, width: 20, height: 20))
        shareButton.contentMode = .scaleAspectFit
        shareButton.image = UIImage(named: "ShareButton");
        shareButton.isUserInteractionEnabled = true
        
        let facebookButtonTap = UITapGestureRecognizer(target: self, action: #selector(pickListEditorView.shareTapped))
        shareButton.addGestureRecognizer(facebookButtonTap)
        
        thisShareScreen.addSubview(shareButton)
        
        let shareLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 20))
        shareLabel.text = "SHARE"
        //FONT
        shareLabel.textColor = UIColor.white
        shareLabel.font = UIFont(name: "Apercu-Bold", size: 12)
        shareLabel.numberOfLines = 1
        shareLabel.textAlignment = .left
        thisShareScreen.addSubview(shareLabel)
        
        /*
        let twitterButton = UIImageView(frame: CGRect(x: thisScreenBounds.width/2-15, y: 0, width: 20, height: 20))
        twitterButton.image = UIImage(named: "Twitter")
        twitterButton.isUserInteractionEnabled = true
        
        let twitterButtonTap = UITapGestureRecognizer(target: self, action: #selector(feedViewController.twitterShareButtonTap))
        twitterButton.addGestureRecognizer(twitterButtonTap)
        
        thisShareScreen.addSubview(twitterButton)
        
        let mailButton = UIImageView(frame: CGRect(x: thisScreenBounds.width/2+10, y: 0, width: 20, height: 20))
        mailButton.image = UIImage(named: "Mail")
        twitterButton.isUserInteractionEnabled = true
        
        let mailButtonTap = UITapGestureRecognizer(target: self, action: #selector(feedViewController.mailShareButtonTap))
        mailButton.addGestureRecognizer(mailButtonTap)
        
        thisShareScreen.addSubview(mailButton)
        */
        self.view.addSubview(thisShareScreen)
        
        thisY = 40
        
        tableView = UITableView()
        
        
        let thisEndY = Int(thisScreenBounds.height) - 64 - thisY - 40
        //tableView.alpha = 0
        tableView.frame        =   CGRect(x: 0, y: thisY, width: Int(thisScreenBounds.width), height: thisEndY)
        tableView.delegate     =   self
        tableView.dataSource   =   self
        tableView.register(pickListEditorExhibitionListCell.self, forCellReuseIdentifier: "pickListEditorExhibitionListCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.allowsMultipleSelectionDuringEditing = true
        
        self.view.addSubview(tableView)
        
        //tableView.contentOffset = CGPoint(x: 0.0, y: 44)
        
        /*
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.6)
        tableView.alpha = tableView.alpha * (1) + 1
        UIView.commitAnimations()
        */
        
    }
    
    @objc func shareTapped() {
        let link = URL(string: thisLink)
        let linkToShare = [link]
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseElements.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let thisHeight = CGFloat(100)
        return thisHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]
        
        let cell:pickListEditorExhibitionListCell? = tableView.dequeueReusableCell(withIdentifier: "pickListEditorExhibitionListCell", for: indexPath) as? pickListEditorExhibitionListCell
        
        let thisLabelText = thisElement.labelText
        
        cell!.parentNewsController = self
        cell!.loadImageInto(thisElement.backgroundImageURL)
        cell!.profileImageURL = thisElement.backgroundImageURL
        cell!.thisID = thisElement.targetID
        cell!.actionLabel.text = thisLabelText
        cell!.adressLabel.text = thisElement.venueName + ", " + thisElement.venueAdress
        cell!.myIndex = (indexPath as NSIndexPath).row
        
        
        if (thisElement.isFav) {
            cell!.plusLabel.layer.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
            cell!.plusLabel.textColor = UIColor.white
            cell!.plusLabel.text = "-"
            cell!.isFav = true
        } else {
            cell!.plusLabel.layer.backgroundColor = UIColor.white.cgColor
            cell!.plusLabel.text = "+"
            cell!.plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
            cell!.isFav = false
        }
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.gray
        
        if (thisGrey) {
            thisGrey = false
            cell!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 250)
        } else {
            thisGrey = true
            cell!.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 250)
        }
        return cell!
    }
    
    func setSpecificIDTo(fav: Bool, id: String) {
        var i = 0
        for var item in responseElements {
            if (String(item.targetID) == id) {
                responseElements[i].isFav = fav
            }
            i = i + 1
        }
    }
    
    func removeFavorite(_ item: String, cell: pickListEditorExhibitionListCell) {
        thisSelectedID = item
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        
        let thisSessionID = thisAppDelegate.sessionID
        let thisUrl = globalData.globalUrl + "delete_favourite"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "session_id="+thisSessionID+"&"
        postString = postString + "user_id="+thisUserID+"&"
        postString = postString + "eyeout_id="+thisSelectedID
        
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                let jsonOptional: Any!
                
                DispatchQueue.main.async {
                    cell.removalDone()
                    self.setSpecificIDTo(fav: false, id: self.thisSelectedID)
                    //self.feedSelectionArray.remove(at: self.feedSelectionArray.index(of: item)!)
                }
                
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    
                } catch _ as NSError {
                    //jsonErrorOptional = error
                    jsonOptional = nil
                }
                
                
            }
        }
    }
    func addToFavorites(_ item: String, cell: pickListEditorExhibitionListCell) {
        thisSelectedID = item
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        if (thisUserID == "") {
            let thisMessage = "Where did my picks go? No problem, just log in."
            let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                
            })
            self.present(failureMessage, animated: true, completion: nil)
            return
        }
        
        let thisSessionID = thisAppDelegate.sessionID
        let thisUrl = globalData.globalUrl + "add_favourite"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "session_id="+thisSessionID+"&"
        postString = postString + "user_id="+thisUserID+"&"
        postString = postString + "eyeout_id="+thisSelectedID
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                
                DispatchQueue.main.async {
                    cell.additionDone()
                    self.setSpecificIDTo(fav: true, id: self.thisSelectedID)
                    //self.feedSelectionArray.append(item)
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
}
