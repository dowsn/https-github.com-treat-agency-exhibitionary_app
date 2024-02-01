//
//  feedViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 15/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit
//import FBSDKShareKit

struct feedListElementData {
    var targetID:Int
    var labelText:String
    var backgroundImageURL:String
    var featured:Bool = false
    var images:Array<AnyObject>
    var thisParseEndDate:String = ""
    var thisParseStartDate:String = ""
    var venueAdress:String = ""
    var venueName:String = ""
    var sortingName:String = ""
    var isFav:Bool = false
    var isOnPickList:Bool = false
    var thisCategoryID:Int
    var thisCategoryString:String = ""
    
    //var venueCity:String = ""
    //var venueHours:String = ""
}

struct pickListElement {
    var listID:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var imageUrl:String = ""
    var followed:Bool = false
    var description:String = ""
    var activeCities:String = ""
}

protocol callDetailViewOfItemProtocol: AnyObject {
    func callDetailViewOfItem(_ sender: cellInternallPageViewController, item: String, indexPath: IndexPath)
}

protocol callPickListDetail:AnyObject {
    func callPickList(_ sender: pickListScrollView, targetID: String)
    func firstSetPickList(_ sender:pickListScrollView, targetID: String, listCount:Int)
    func noPickerData()
}

protocol callFilter:AnyObject {
    func filterViewBy(_ sender: categoryListScrollView, targetCategory: Int)
}

protocol callSearchFilter: AnyObject {
    func callSearchFilter(_ expression: String, cadFilter: Bool)
}

class feedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, callDetailViewOfItemProtocol, callPickListDetail {
    
    let thisScreenBounds = UIScreen.main.bounds
    var thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var responseElements = [feedListElementData]()
    var pickListResponseElements = [pickListElement]()
    var tableView:UITableView = UITableView()
    var thisUserID = ""
    var thisSessionID = ""
    var thisSelectedUrl = ""
    var thisSelectedTitle = ""
    var thisSelectedID = ""
    var feedSelectionArray:Array<String> = Array()
    var thisEndDate:Date = Date()
    var thisActualCellIndex = 0
    var thisOldCity = 0
    var thisLastPickID = ""
    var thisListCount = 0
    
    var pickListCloseButton = UIImageView()
    var pickListEditorCloseButton = UIImageView()
    var addlistButton = UILabel()
    var thisTextHint = UILabel()
    //var thisPickEditorView = pickListEditorView()
    var thisGrey:Bool = true
    
    var collectionView:UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewFlowLayout())
    
    var pickSelectorIsActive = false
    var isInPickEditMode = false
    var pickListEditorResponseElements = [feedListElementData]()
    
    var thisTopSearchView = topSearchView()
    var searchIsSet = false
    var searchExpression = ""
    var thisCADFilterOn = false
    
    var thisPickSelectorView:pickListScrollView = pickListScrollView()
    
    var thisShareScreen:UIView = UIView()
    var thisShareLink:String = ""
    
    var profileImage = UIImageView()
    var actionLabel = UILabel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }

    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
        let appearance = UITabBarItem.appearance()
        let thisFont = UIFont(name: "Apercu-Regular", size: 12)
        appearance.setTitleTextAttributes([NSAttributedString.Key.font: thisFont!], for: UIControl.State())
        
    }
    

    func callSearchFilter(_ expression: String, cadFilter:Bool) {
        searchIsSet = false
        searchExpression = expression
        thisCADFilterOn = cadFilter
        if (expression == "" && thisCADFilterOn == false) {
            tableView.removeFromSuperview()
            resetSearch()
        } else {
            removeTableAndSearch()
            }
    }
    
    func removeTableAndSearch() {
        tableView.removeFromSuperview()
        addIndicitaor()
        getDetailData()
        
    }
    func addIndicitaor() {
        thisIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        thisIndicator.center = CGPoint(x: thisScreenBounds.width/2, y: 140)
        thisIndicator.startAnimating()
        self.view.addSubview(thisIndicator)
    }
    
    func removeIndicatior() {
        thisIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pickListCloseButton.removeFromSuperview()
        thisTextHint.removeFromSuperview()
        addlistButton.removeFromSuperview()
        collectionView.removeFromSuperview()
        profileImage.removeFromSuperview()
        actionLabel.removeFromSuperview()
        tableView.removeFromSuperview()
        pickListEditorCloseButton.removeFromSuperview()
        thisTextHint.removeFromSuperview()
        
        isInPickEditMode = false
        
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableView.removeFromSuperview()
        
        //addIndicitaor()
        setTrack("Feed", parameter: "")
        
        setUpHeader("Picks")
        setUpMenuButton()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        //let thisAppDelegate = returnAppDelegate()
        self.feedSelectionArray = Array()
        
        if (thisLastPickID == "0") {
            thisLastPickID = ""
        }
        
        if (returnAppDelegate().thisCityID == 0) {
            let thisMessage = "Looks like you did not set a city yet! Go on, choose your city!"
            let failureMessage:UIAlertController = UIAlertController(title: "Welcome!", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                    self.forceToChosseCity()
                })
            self.present(failureMessage, animated: true, completion: nil)
        }
        if (returnAppDelegate().thisCityID != thisOldCity) {
            thisActualCellIndex = 0
            thisOldCity = returnAppDelegate().thisCityID
            thisLastPickID = ""
        }
        
        if (thisLastPickID == "") {
//            getData()
            getPickListAndFirstElement()
        } else {
            getPickListDetail(targetID: thisLastPickID)
        }
        
    }
    /*
    func restart() {
        print("RESTART WITH")
        print(thisLastPickID)
        if (thisLastPickID == "") {
            getPickListAndFirstElement()
        } else {
            getPickListDetail(targetID: thisLastPickID)
        }
    }
    */
    /*
    func hideAndLoadPicks() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.tableView.alpha = 0
            //self.thisPickSelectorView.view.alpha = 0
        }, completion: {
            (value: Bool) in
                self.getPickList()
                //self.displayPickListCreator()
        })
    }
    /
    func hidePicklist() {
        pickSelectorIsActive = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.collectionView.alpha = 0
            self.pickListCloseButton.alpha = 0
            self.thisTextHint.alpha = 0
            self.addlistButton.alpha = 0
        }, completion: {
            (value: Bool) in
            
            self.pickListCloseButton.removeFromSuperview()
            self.thisTextHint.removeFromSuperview()
            self.addlistButton.removeFromSuperview()
            
            if (self.isInPickEditMode) {
                self.getPickListEditorData()
            }
        })
    }
    
    func closePickList() {
        hidePicklist()
        restart()
    }
    /
    func closePickListEditor() {
        
        isInPickEditMode = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.tableView.alpha = 0
            self.pickListEditorCloseButton.alpha = 0
            self.thisTextHint.alpha = 0
            self.thisShareScreen.alpha = 0
        }, completion: {
            (value: Bool) in
            self.tableView.removeFromSuperview()
            self.pickListEditorCloseButton.removeFromSuperview()
            self.thisTextHint.removeFromSuperview()
            self.thisShareScreen.removeFromSuperview()
            self.showPicksAround()
        })
        
    }
    */
    /*
    func displayPickLists() {
        pickListCloseButton = UIImageView(frame: CGRect(x: thisScreenBounds.width-25, y: 5, width: 20, height: 20))
        pickListCloseButton.image = UIImage(named: "CloseButton")
        pickListCloseButton.isUserInteractionEnabled = true
        let pickListCloseTap = UITapGestureRecognizer(target: self, action: #selector(feedViewController.closePickList))
        pickListCloseButton.addGestureRecognizer(pickListCloseTap)
        
        self.view.addSubview(pickListCloseButton)
        
        createCollectionView()
    }
    
    func displayPickListCreator() {
        isInPickEditMode = true
        hidePicklist()
    }
    */
    func doneLoadingAdd() {
        print("Done loading")
        
    }
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("DID SELECT")
        var thisItem = pickListResponseElements[(indexPath as NSIndexPath).row]
        print(thisItem.listID)
        
        let thisCell = collectionView.cellForItem(at: indexPath) as! pickListElementCell
        
        if (thisItem.followed) {
            //UNFOLLOW
            
     
            
            thisCell.changeToPlus()
        } else {
            //FOLLOW
            
     
            
            thisCell.changeToMinus()
        }
        
        thisItem.followed = !thisItem.followed
        pickListResponseElements[(indexPath as NSIndexPath).row].followed =  thisItem.followed
        
    }
    */
    func getPickListAndFirstElement () {
        thisPickSelectorView.view.removeFromSuperview()
        thisPickSelectorView = pickListScrollView()
        
        //thisPickSelectorView.view.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 100 )
        
        thisPickSelectorView.view.frame = CGRect(x: 70, y: 0, width: thisScreenBounds.width-70, height: 100 )
        thisPickSelectorView.delegateCall = self
        thisPickSelectorView.view.alpha = 1
        
        
    }
    
    
    
    
    func acitvateSearch(targetDelegate:callSearchFilter) {
        if (searchIsSet) {
            thisTopSearchView.close()
            searchIsSet = false
        } else {
            let thisScreenBounds = UIScreen.main.bounds
        
            thisTopSearchView = topSearchView()
            thisTopSearchView.delegateCall = targetDelegate
            thisTopSearchView.view.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
            thisTopSearchView.view.backgroundColor = UIColor.black
            thisTopSearchView.searchExpression = searchExpression
            thisTopSearchView.thisCADFilterOn = thisCADFilterOn
            thisTopSearchView.view.isUserInteractionEnabled = true
            searchIsSet = true
        
            thisTopSearchView.view.frame = CGRect(x: 0, y: (-thisScreenBounds.height), width: thisScreenBounds.width, height: thisScreenBounds.height)
            self.view.addSubview(thisTopSearchView.view)
        
        
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
                self.thisTopSearchView.view.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height)
                }, completion: {
                    (value: Bool) in
                
            })
        }
    }
    
    func forceToChosseCity() {
        self.revealViewController().rightViewRevealWidth = UIScreen.main.bounds.width
        self.revealViewController().rightViewRevealDisplacement = CGFloat(0)
        self.revealViewController().rightViewRevealOverdraw = CGFloat(0)
        self.revealViewController().rightRevealToggle(self)
    }
    
    func callDetailViewOfItem(_ sender: cellInternallPageViewController, item: String, indexPath:IndexPath) {
        thisSelectedID = item
        thisActualCellIndex = (indexPath as NSIndexPath).row
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func getData() {
        feedSelectionArray = [String]()
        //responseElements = [feedListElementData]()
        
        let thisUrl = globalData.globalUrl + "feed?id=" + String(returnAppDelegate().thisCityID)
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        //let postString = "id=2"
        //let requestBodyData = (postString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        //request.HTTPBody = requestBodyData
        
        
        httpGet(request as URLRequest){
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
                        
                        if let sessionJson = response["session"] as? Dictionary<String, AnyObject> {
                            let thisStatus = sessionJson["status"] as! String
                            if (thisStatus == "OK") {
                                
                                if let eventsJson = response["feeditems"] as? Array<AnyObject> {
                                    
                                    for i in 0 ..< eventsJson.count {
                                        let thisString = eventsJson[i]["exhibition_id"] as! String
                                        self.feedSelectionArray.append(thisString)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.getDetailData()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func getDetailData() {
        responseElements = [feedListElementData]()
        
        var thisUrl = globalData.dbUrl + "feed_v2?id=" + String(returnAppDelegate().thisCityID)
        thisUrl = thisUrl + "&search=" + searchExpression
        if (thisCADFilterOn) {
            thisUrl = thisUrl + "&cad=1"
        }
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "GET"
        
        if isInPickEditMode {
            let thisAppDelegate = returnAppDelegate()
            if (thisAppDelegate.sessionUserID != "") {
                let postString = "user_id="+thisAppDelegate.sessionUserID
                let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
                request.httpBody = requestBodyData
            }
        }
        
        httpGet(request as URLRequest){
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
                
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    
                    if let response:AnyObject = json["response"] as AnyObject? {
                        
                        if let sessionJson = response["session"] as? Dictionary<String, AnyObject> {
                            let thisStatus = sessionJson["status"] as! String
                            if (thisStatus == "OK") {
                                
                                if let eventsJson = response["feeditems"] as? Array<AnyObject> {
                                    if (eventsJson.count == 0) {
                                        DispatchQueue.main.async {
                                            
                                            self.noData()
                                            return
                                        }
                                    }
                                    for item in eventsJson {
                                        
                                        let theseImages:Array<AnyObject> = item["images"]! as! Array<AnyObject>
                                        /*
                                        var thisIsFav:Bool = false
                                        if (item["isFav"]! as! Int == 1) {
                                            thisIsFav = true
                                        }
                                        */
                                        
                                        var thisIsOnPickList:Bool = false
                                        if (item["isInPicklist"]! as! Bool == true) {
                                            thisIsOnPickList = true
                                        }
                                        
                                        let thisFeedElement:feedListElementData = feedListElementData(targetID: item["id"]! as! Int, labelText: item["title"]! as! String, backgroundImageURL: "", featured: false, images: theseImages, thisParseEndDate: self.nullToNil(item["end"]! as AnyObject?)!, thisParseStartDate: self.nullToNil(item["opening_start"]! as AnyObject?)!,venueAdress: self.nullToNil(item["venue_quarter"]! as AnyObject?)!, venueName: self.nullToNil(item["venue_name"]! as AnyObject?)!, sortingName: self.nullToNil(item["venue_name"]!)!, isFav: false, isOnPickList: thisIsOnPickList, thisCategoryID: 1, thisCategoryString: "")
                                        
                                       
                                        self.responseElements.append(thisFeedElement)
                                    }
                                    
                                    
                                }
                                DispatchQueue.main.async {
                                    self.dataDone()
                                }
                            }
                        }
                    }
                }
            }
        }
    
    }
    
    func getPickListEditorData() {
        responseElements = [feedListElementData]()
        
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "getFutureExhibitions?city_id=" + String(returnAppDelegate().thisCityID)
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        if (thisAppDelegate.sessionUserID != "") {
            let postString = "user_id="+thisAppDelegate.sessionUserID
            let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
            request.httpBody = requestBodyData
        }
        
        httpGet(request as URLRequest){
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
                        
                        let thisFeedElement:feedListElementData = feedListElementData(targetID: item["id"]! as! Int, labelText: item["title"] as! String, backgroundImageURL: thisImageURL, featured: false, images: theseImages, thisParseEndDate: self.nullToNil(item["end"])!, thisParseStartDate: self.nullToNil(item["start"])!,venueAdress: self.nullToNil(item["venue_quarter"])!, venueName: self.nullToNil(item["venue_name"])!, sortingName: self.nullToNil(item["venue_name"])!, isFav: thisIsFav, isOnPickList: thisIsOnPickList, thisCategoryID: 1, thisCategoryString: "")
                        
                        self.responseElements.append(thisFeedElement)
                    }
                    DispatchQueue.main.async {
                        self.dataDone()
                    }
                }
            }
        }
    }
    
    func getPickListDetail(targetID:String) {
        
        responseElements = [feedListElementData]()
        
        var thisUrl = globalData.dbUrl + "getPicksForPickList?list_id=" + targetID + "&city_id=" + String(returnAppDelegate().thisCityID)
        
        
        thisUrl = thisUrl + "&search=" + searchExpression
        if (thisCADFilterOn) {
            thisUrl = thisUrl + "&cad=1"
        }
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "GET"
        /*
        var postString = "city_id=" + String(returnAppDelegate().thisCityID)
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        */
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
                
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    if let response:AnyObject = json["response"] as AnyObject? {
                        //print(response)
                        
                        if let sessionJson = response["session"] as? Dictionary<String, AnyObject> {
                            let thisStatus = sessionJson["status"] as! String
                            if (thisStatus == "OK") {
                                
                                if let eventsJson = response["feeditems"] as? Array<AnyObject> {
                                    if (eventsJson.count == 0) {
                                        DispatchQueue.main.async {
                                            self.noData()
                                            return
                                        }
                                    }
                                    
//                                    print(eventsJson)
                                    
                                    for item in eventsJson {
                                        //print(item)
                                        
                                        let theseImages:Array<AnyObject> = item["images"]! as! Array<AnyObject>
                                        /*
                                         var thisIsFav:Bool = false
                                         if (item["isFav"]! as! Int == 1) {
                                         thisIsFav = true
                                         }
                                         */
                                        
                                        var thisIsOnPickList:Bool = false
                                        if (item["isInPicklist"]! as! Bool == true) {
                                            thisIsOnPickList = true
                                        }
                    
                                        let thisFeedElement:feedListElementData = feedListElementData(targetID: item["id"]! as! Int, labelText: item["title"]! as! String, backgroundImageURL: "", featured: false, images: theseImages, thisParseEndDate: self.nullToNil(item["end"]! as AnyObject?)!, thisParseStartDate: self.nullToNil(item["opening_start"]! as AnyObject?)!,venueAdress: self.nullToNil(item["venue_quarter"]! as AnyObject?)!, venueName: self.nullToNil(item["venue_name"]! as AnyObject?)!, sortingName: self.nullToNil(item["venue_name"]!)!, isFav: false, isOnPickList: thisIsOnPickList, thisCategoryID: 1, thisCategoryString: "")
                                        
                                        
                                        
                                        self.responseElements.append(thisFeedElement)
                                    }

                                    
                                    
                                }
                                DispatchQueue.main.async {
                                    if (self.responseElements.count == 0) {
                                        self.noPicklistData()
                                        } else {
                                        self.dataDone()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    func noPickerData() {
        noData()
    }
    
    func noPicklistData() {
        removeIndicatior()
        let thisMessage = "Ups, it seems this user has currently no picks for this city!"
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            
        })
        self.present(failureMessage, animated: true, completion: nil)
    }
    
    func noData() {
        removeIndicatior()
        let thisMessage = "You don't follow any pick lists in this city! Tap search to find lists to follow."
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            
        })
        self.present(failureMessage, animated: true, completion: nil)
    }
    func resetSearch() {
        thisCADFilterOn = false
        searchExpression = ""
        addIndicitaor()
        getData()
    }
    func dataDone() {
        createTableView()
    }
    
//    func facebooShareTap() {
//        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
//        content.contentURL = NSURL(string: thisShareLink)! as URL
//        content.contentTitle = "Exhibitionary"
//        content.contentDescription = "My pick list from exhibitionary."
//        //content.imageURL = NSURL(string: self.contentURLImage)
//        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
//    }
    
    func receiveShareLink(link:String) {
        thisShareLink = link
    }
    func mailShareButtonTap() {
        
    }
    
    func twitterShareButtonTap() {
        
    }
    
    func createTableView() {
        removeIndicatior()
        var thisY = CGFloat(0)
        
        
        //let thisImageY = thisScreenBounds.width/4 - 35
        profileImage.removeFromSuperview()
        profileImage = UIImageView(frame: CGRect(x: 5, y: 5, width: 65, height: 65))
        
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        //profileImage.layer.borderWidth = 1
        //profileImage.layer.borderColor = UIColor.black.cgColor
        
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        
        let thisProfileURL = returnAppDelegate().thisProfileURL
        
        if (thisProfileURL == "") {
            profileImage.image = UIImage(named: "MyPicks")
        } else {
            profileImage.sd_setImage(with: URL(string: thisProfileURL))
        }
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(feedViewController.myPicksTapped))
        profileImage.addGestureRecognizer(profileImageTap)
        
        self.view.addSubview(profileImage)
        
        actionLabel.removeFromSuperview()
        actionLabel = UILabel(frame: CGRect(x: 5, y: 65, width: 65, height: 40))
        actionLabel.textColor = UIColor.black
        actionLabel.font = UIFont(name: "Apercu-Bold", size: 10)
        actionLabel.textAlignment = NSTextAlignment.center
        actionLabel.backgroundColor = UIColor.clear
        actionLabel.isUserInteractionEnabled = true
        actionLabel.numberOfLines = 2
        actionLabel.lineBreakMode = .byWordWrapping
        actionLabel.text = "My Picks"
        
        let actionLabelTap = UITapGestureRecognizer(target: self, action: #selector(feedViewController.myPicksTapped))
        actionLabel.addGestureRecognizer(actionLabelTap)
        
        self.view.addSubview(actionLabel)
        self.view.addSubview(thisPickSelectorView.view)
         thisY = 100
        
        
        let thisEndY = thisScreenBounds.height-105-thisY  //-90
        
        tableView = UITableView()
        tableView.alpha = 0
        tableView.frame        =   CGRect(x: 0, y: thisY, width: thisScreenBounds.width, height: thisEndY)
        tableView.delegate     =   self
        tableView.dataSource   =   self
        //tableView.rowHeight    =   250
        
//      tableView.register(feedListSwipeCellView.self, forCellReuseIdentifier: "feedListSwipeCellView")
        tableView.register(feedListSwipeCellView.self, forCellReuseIdentifier: "feedListSwipeCellView")

        
//        print(tableView)
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
//        tableView.tableHeaderView = thisPickSelectorView.view
        
            
        self.view.addSubview(tableView)
//
//        if (thisActualCellIndex != 0) {
//            let thisIndexPath = IndexPath(row: thisActualCellIndex, section: 0)
//            tableView.scrollToRow(at: thisIndexPath, at: .middle, animated: false)
//        }
//
//        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
//            self.tableView.alpha = 1
//        }, completion: {
//            (value: Bool) in
//
//        })
//
        
        
    }
    
    @objc func myPicksTapped() {
        self.performSegue(withIdentifier: "openPicklistEditor", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var thisCount = self.responseElements.count
        if (isInPickEditMode) {
            
        } else {
            
        }
        return thisCount
    }
    
    
    func callPickList(_ sender: pickListScrollView, targetID: String) {
        if (targetID == "0") {
            showPicksAround()
        } else {
            thisLastPickID = targetID
            tableView.removeFromSuperview()
            addIndicitaor()
            let thisTargetID:String = targetID as String
            getPickListDetail(targetID: thisTargetID)
        }
    }
    
    func showPicksAround() {
        self.performSegue(withIdentifier: "showEditors", sender: self)
    }
    
    func firstSetPickList(_ sender: pickListScrollView, targetID: String, listCount: Int) {
        
        if (listCount == 1) {
            noData()
        } else {
            if (thisLastPickID == "") {
                thisListCount = listCount
                tableView.removeFromSuperview()
                addIndicitaor()
                let thisTargetID:String = targetID as String
                getPickListDetail(targetID: thisTargetID)
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        let thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]
        var thisHeight = CGFloat(350)
        
        if (thisElement.featured == true) {
            /*
            thisEntytCategroy = thisElement.category as String!
            switch (thisEntytCategroy) {
                
            default:
                
                break
            }
            
            */
        }
        
        if (isInPickEditMode) {
            thisHeight = CGFloat(100)
        } else {
            thisHeight = CGFloat(350)
        }
        return thisHeight
    }
   
    
    func restTime(_ targetDate:String, targetStartDate:String) -> String {
        //restTime(thisElement.thisParseEndDate, targetStartDate: thisElement.thisParseStartDate)
        let df:DateFormatter = DateFormatter()
        df.locale = Locale(identifier: "us")
        //df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        df.dateFormat = "yyyy-MM-dd"
        //df.timeZone = TimeZone(identifier: "UTC")
        
        
        let sdf:DateFormatter = DateFormatter()
        sdf.locale = Locale(identifier: "en_US")
        sdf.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        //sdf.dateFormat = "yyyy-MM-dd"
        sdf.timeZone = TimeZone(identifier: "UTC")
        //dateFormatter.timeZone = TimeZone(identifier: "UTC")
        //dateFormatter.locale = Locale(identifier: "")
        
        
        let thisEndDateFromString:Date = df.date(from: targetDate)!
        
        thisEndDate = thisEndDateFromString
        let userCalendar = Calendar.current
        
        let endDate = thisEndDate
        
        let hourMinuteComponents:NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month,NSCalendar.Unit.day, NSCalendar.Unit.hour]
        let timeDifference = (userCalendar as NSCalendar).components(hourMinuteComponents, from: Date(), to: endDate, options: [])
        
        var notYet = true
        var thisReturnText = ""//"Time left: "
        
        var thisMonthTillStart = 0
        var thisDaysTillStart = 0
        var thisHoursTillStart = 0
        
        if (targetStartDate != "-") {
            
            //print("START DATE")
            //print(targetStartDate)
            let thisStartDateFromString:Date = sdf.date(from: targetStartDate)!
            //print(thisStartDateFromString)
            
            let startTimeDifference = (userCalendar as NSCalendar).components(hourMinuteComponents, from: Date(), to: thisStartDateFromString, options: [])
            
            thisMonthTillStart = startTimeDifference.month!
            thisDaysTillStart = startTimeDifference.day!
            thisHoursTillStart = startTimeDifference.hour!
            
            //print("HOURS LEFT")
            //print(thisHoursTillStart)
            
            if (thisDaysTillStart < 0) {
                notYet = true
            }
            if (thisDaysTillStart == 0) {
                if (thisHoursTillStart > -24 && thisHoursTillStart < 0) {
                    
                } else {
                    notYet = false
                
                    let thisFormatter = DateFormatter()
                    thisFormatter.dateFormat = "H:mm a"
                    thisFormatter.timeZone = TimeZone(identifier: "UTC")
                    let thisPrintString = thisFormatter.string(from: thisStartDateFromString)
                    thisReturnText = "Opens today " + thisPrintString
                }
                
            }
            
            if (thisMonthTillStart > 0 || thisDaysTillStart > 0) {
                notYet = false
                thisReturnText = "Opens "
            }
            if (thisMonthTillStart > 1) {
                thisReturnText = thisReturnText + "in " + String(describing: thisMonthTillStart) + " months"
            }
            if (thisMonthTillStart == 1) {
                thisReturnText = thisReturnText + "in " + String(describing: thisMonthTillStart) + " month"
            }
            
            if (thisMonthTillStart > 0 && thisDaysTillStart > 0) {
                thisReturnText = thisReturnText + ","
            }
            
            if (thisDaysTillStart > 1) {
                thisReturnText = thisReturnText + "in " + String(thisDaysTillStart) + " days"
            }
            
            if (thisDaysTillStart == 1) {
                if (thisMonthTillStart == 0) {
                    thisReturnText = thisReturnText + " tomorrow"
                } else {
                    thisReturnText = thisReturnText + " today"
                }
            }
        
        }
        
        if (notYet) {
        
        
        let thisMonthLeft = timeDifference.month!
        let thisDaysLeft = timeDifference.day!
        let thisHoursLeft = timeDifference.hour!
            
        var needsLeft = true
        
        if (notYet) {
        
        if (thisMonthLeft > 1) {
            thisReturnText = thisReturnText + String(describing: thisMonthLeft) + " months"
        }
        if (thisMonthLeft == 1) {
            thisReturnText = thisReturnText + String(describing: thisMonthLeft) + " month"
        }
        if (thisMonthLeft > 0 && thisDaysLeft > 0) {
            thisReturnText = thisReturnText + ", "
        }
        
        if (thisDaysLeft > 1) {
            thisReturnText = thisReturnText + String(thisDaysLeft) + " days"
        }
        if (thisDaysLeft == 1) {
            thisReturnText = thisReturnText + String(thisDaysLeft) + " day"
        }
        /*
        print("DAYS LEFT")
        print(endDate)
        print(timeDifference)
        */
        
        if (thisDaysLeft == 0 && thisMonthLeft == 0) {
            thisReturnText = "Ends tomorrow!"
            needsLeft = false
        }
        
            if (thisDaysLeft == 0 && thisMonthLeft == 0 && thisHoursLeft > -24 && thisHoursLeft < 0 ) {
                thisReturnText = "Ends today!"
                needsLeft = false
            }
            
            if(thisDaysLeft < 0 && thisMonthLeft <= 0 && thisHoursLeft <= 0) {
                needsLeft = false
            }
            
        if(needsLeft) {
            thisReturnText = thisReturnText + " left"
        }
        
        }
            
        }
        /*
        if (thisEndDateNumbers > 1) {
            thisEndDateText = String(thisEndDateNumbers) + " days left"
        } else {
            thisEndDateText = "1 day left!"
        }
        if (thisEndDateNumbers == 0) {
            thisEndDateText = "Ends tomorrow!"
        }
        if (thisEndDateNumbers < 0) {
            thisEndDateText = ""
        }
        */
        
        
        return thisReturnText
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]
//        
//        //var cell:UITableViewCell
//        var thisFeedCell:feedListSwipeCellView
//        var _:pickListEditorCell
//        
//            thisFeedCell = (tableView.dequeueReusableCell(withIdentifier: "feedListSwipeCellView", for: indexPath) as? feedListSwipeCellView)!
//            
//            if (thisElement.thisParseEndDate != "-") {
//                let thisEndDateText:String = restTime(thisElement.thisParseEndDate, targetStartDate: thisElement.thisParseStartDate)
//                thisFeedCell.dateLeftText = thisEndDateText
//                thisFeedCell.childDateLabelText(thisEndDateText)
//            }
//            var thisNameQuarter = thisElement.venueName
//            if (thisElement.venueAdress != "") {
//                thisNameQuarter = thisNameQuarter + ", " + thisElement.venueAdress
//            }
//                
//            thisFeedCell.ownIndexPath = indexPath
//            thisFeedCell.setIndexPath(indexPath)
//            thisFeedCell.theseImages = thisElement.images
//            thisFeedCell.thisSetImages(thisElement.images)
//            thisFeedCell.thisID = thisElement.targetID
//        
//            
//            thisFeedCell.actionLabelText = thisElement.labelText
//            thisFeedCell.childActionLabelText(thisElement.labelText)
//            thisFeedCell.addressText = thisNameQuarter
//            thisFeedCell.setChildAddressText(thisNameQuarter)
//            thisFeedCell.thisIDTarget(thisElement.targetID, targetDelegate: self)
//        
//            thisFeedCell.thisDetailDelegate = self
//            thisFeedCell.selectionStyle = UITableViewCell.SelectionStyle.none
//            thisFeedCell.isUserInteractionEnabled = true
//            
//            return thisFeedCell
//        
//        //return cell
//    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]

        var thisFeedCell:feedListSwipeCellView

        thisFeedCell = (tableView.dequeueReusableCell(withIdentifier: "feedListSwipeCellView", for: indexPath) as? feedListSwipeCellView)!
        // Set the data for this cell using the row index and the data property
        let rowData = responseElements[indexPath.row]
        
        var thisNameQuarter = thisElement.venueName
        if (thisElement.venueAdress != "") {
           thisNameQuarter = thisNameQuarter + ", " + thisElement.venueAdress
        }
        
        print(thisNameQuarter)
        
        thisFeedCell.setChildAddressText(thisNameQuarter)
        
        return thisFeedCell
    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]
//        
//        //var cell:UITableViewCell
//        var thisFeedCell:feedListSwipeCellView
//        var _:pickListEditorCell
//        
//            thisFeedCell = (tableView.dequeueReusableCell(withIdentifier: "feedListSwipeCellView", for: indexPath) as? feedListSwipeCellView)!
//            
//            if (thisElement.thisParseEndDate != "-") {
//                let thisEndDateText:String = restTime(thisElement.thisParseEndDate, targetStartDate: thisElement.thisParseStartDate)
//                thisFeedCell.dateLeftText = thisEndDateText
//                thisFeedCell.childDateLabelText(thisEndDateText)
//            }
//            var thisNameQuarter = thisElement.venueName
//            if (thisElement.venueAdress != "") {
//                thisNameQuarter = thisNameQuarter + ", " + thisElement.venueAdress
//            }
//                
//            thisFeedCell.ownIndexPath = indexPath
//            thisFeedCell.setIndexPath(indexPath)
//            thisFeedCell.theseImages = thisElement.images
//            thisFeedCell.thisSetImages(thisElement.images)
//            thisFeedCell.thisID = thisElement.targetID
//        
//            
//            thisFeedCell.actionLabelText = thisElement.labelText
//            thisFeedCell.childActionLabelText(thisElement.labelText)
//            thisFeedCell.addressText = thisNameQuarter
//            thisFeedCell.setChildAddressText(thisNameQuarter)
//            thisFeedCell.thisIDTarget(thisElement.targetID, targetDelegate: self)
//        
//            thisFeedCell.thisDetailDelegate = self
//            thisFeedCell.selectionStyle = UITableViewCell.SelectionStyle.none
//            thisFeedCell.isUserInteractionEnabled = true
//            
//            return thisFeedCell
//        
//        //return cell
//    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetail") {
            let nextViewController = (segue.destination) as! detailViewController
            nextViewController.thisDetailToBeViewed = self.thisSelectedID
        }
    }
    
    
}
