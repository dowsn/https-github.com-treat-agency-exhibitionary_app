//
//  SecondViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 13/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

//CALENDER

//
//  OpeningsViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 16/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

//

import Foundation
import UIKit
//import AMPopTip

struct categoryData {
    var id:Int
    var name:String = ""
}

class exhibitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchResultsUpdating, callFilter {
    
    let thisScreenBounds = UIScreen.main.bounds
    var thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var responseElements = [feedListElementData]()
    var filteredElements = [feedListElementData]()
    
    
    var tableView:UITableView = UITableView()
    var thisUserID = ""
    var thisSessionID = ""
    var thisSelectedUrl = ""
    var thisSelectedTitle = ""
    var thisSelectedID = ""
    var thisSelectedCity = ""
    var thisOldCity = 0
    var segmentController:UISegmentedControl = UISegmentedControl()
    var feedSelectionArray:Array<String> = Array()
    var thisGrey:Bool = true
    var isInFavMode = false
    var isInSharingMode = false
    var thisActualCellIndex = 0
//    var popTip = AMPopTip()
    var selectedIDS:Array<Int> = Array()
    var myPublicPickURL:String = ""
    var thisShareScreen:UIView = UIView()
    var thisShareScreenActive = false
    
    var categoryElements = [categoryData]()
    var categoryFilterActive = false
    var thisTargetCategory = 0
    
    //OLD SEARCH
    
    var searchController = UISearchController(searchResultsController: nil)


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    
        
        let appearance = UITabBarItem.appearance()
        let thisFont = UIFont(name: "Apercu-Regular", size: 12)
        appearance.setTitleTextAttributes([NSAttributedString.Key.font: thisFont!], for: UIControl.State())
        
    }
    
    func addIndicitaor() {
        thisIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        thisIndicator.center = CGPoint(x: thisScreenBounds.width/2, y: 140)
        thisIndicator.startAnimating()
        self.view.addSubview(thisIndicator)
    }
    
    func removeIndicatior() {
        thisIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHeader("Current")
        //setUpMenuButtonWithShare()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge.bottom
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        addIndicitaor()
        setUpMenuButton()
        setTrack("Exhibitions", parameter: "")
        
        tableView.removeFromSuperview()
        
        if (thisShareScreenActive) {
            closeShareScreen()
        }
        isInSharingMode = false
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        thisSelectedCity = String(thisAppDelegate.thisCityID)
        //print(thisAppDelegate.thisCityID)
        if (thisOldCity != thisAppDelegate.thisCityID) {
            thisOldCity = thisAppDelegate.thisCityID
            thisActualCellIndex = 0
            categoryFilterActive = false
            
        }
        
        if (thisUserID == "") {
            getData()
            isInFavMode = false
            segmentController.selectedSegmentIndex = 0
        } else {
            getData()
        }
        getSegmenter()
    }
    
    
    
    func preselection() {
        var i = 0
        for item in responseElements {
            if (item.isOnPickList) {
                let thisIndexPath = IndexPath(row: i, section: 0)
                self.tableView.selectRow(at: thisIndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                let thisCell = tableView.cellForRow(at: thisIndexPath)
                thisCell?.setSelected(true, animated: false)
                selectedIDS.append(item.targetID)
            }
            i = i + 1
        }
    }
    
    func showShareScreen() {
        thisShareScreenActive = true
        isInSharingMode = false
        thisShareScreen = UIView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height))
        thisShareScreen.backgroundColor = UIColor.white
        
        thisShareScreen.alpha = 0
        
        let pickListCloseButton = UIImageView(frame: CGRect(x: thisScreenBounds.width-25, y: 5, width: 20, height: 20))
        pickListCloseButton.image = UIImage(named: "CloseButton")
        pickListCloseButton.isUserInteractionEnabled = true
        let pickListCloseTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionViewController.closeShareScreen))
        pickListCloseButton.addGestureRecognizer(pickListCloseTap)
        
        thisShareScreen.addSubview(pickListCloseButton)
        
        var thisY = CGFloat(30)
        
        let thisTextHint = UILabel(frame: CGRect(x: 30, y: thisY, width: thisScreenBounds.width-60, height: 50))
        thisTextHint.text = "Share your pick list now directly trough this URL, or any of the social services below! In addition your pick list is now visible in the pick list overview for this city!"
        //FONT
        thisTextHint.textColor = UIColor.black
        thisTextHint.font = UIFont(name: "Apercu-Bold", size: 12)
        thisTextHint.numberOfLines = 4
        thisTextHint.textAlignment = .center
        thisShareScreen.addSubview(thisTextHint)
        thisY = 115

        let thisURLHint = UILabel(frame: CGRect(x: 30, y: thisY, width: thisScreenBounds.width-60, height: 15))
        thisURLHint.text = myPublicPickURL
        //FONT
        thisURLHint.textColor = UIColor.black
        thisURLHint.font = UIFont(name: "Apercu-Bold", size: 12)
        thisURLHint.numberOfLines = 1
        thisURLHint.textAlignment = .center
        thisShareScreen.addSubview(thisURLHint)
        
        thisY = 140
        
        
        let facebookButton = UIImageView(frame: CGRect(x: thisScreenBounds.width/2-40, y: thisY, width: 20, height: 20))
        facebookButton.image = UIImage(named: "Facebook")
        facebookButton.isUserInteractionEnabled = true
        
        let facebookButtonTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionViewController.closeShareScreen))
        facebookButton.addGestureRecognizer(facebookButtonTap)
        
        thisShareScreen.addSubview(facebookButton)

        let twitterButton = UIImageView(frame: CGRect(x: thisScreenBounds.width/2-15, y: thisY, width: 20, height: 20))
        twitterButton.image = UIImage(named: "Twitter")
        twitterButton.isUserInteractionEnabled = true
        
        let twitterButtonTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionViewController.closeShareScreen))
        twitterButton.addGestureRecognizer(twitterButtonTap)
        
        thisShareScreen.addSubview(twitterButton)

        let mailButton = UIImageView(frame: CGRect(x: thisScreenBounds.width/2+10, y: thisY, width: 20, height: 20))
        mailButton.image = UIImage(named: "Mail")
        twitterButton.isUserInteractionEnabled = true
        
        let mailButtonTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionViewController.closeShareScreen))
        mailButton.addGestureRecognizer(mailButtonTap)
        
        thisShareScreen.addSubview(mailButton)
        
        self.view.addSubview(thisShareScreen)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.thisShareScreen.alpha = 1
        }, completion: {
            (value: Bool) in
            
        })

        
    }
    
    @objc func closeShareScreen() {
        thisShareScreenActive = false
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.thisShareScreen.alpha = 0
        }, completion: {
            (value: Bool) in
            self.thisShareScreen.removeFromSuperview()
        })
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisCell = tableView.cellForRow(at: indexPath)
        let thisIsSelected = thisCell?.isSelected
        if (thisIsSelected)! {
            print("ADD")
            selectedIDS.append(responseElements[indexPath.row].targetID)
            
            
        } else {
            print("REMOVE")
            if let index = selectedIDS.index(of: responseElements[indexPath.row].targetID) {
                selectedIDS.remove(at: index)
            }
        
            
            //REMOVE FROM TABLE
        
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredElements = responseElements.filter { element in
            
            if (element.labelText.lowercased().contains(searchText.lowercased()) || element.venueName.lowercased().contains(searchText.lowercased()) || element.venueAdress.lowercased().contains(searchText.lowercased())) {
                return true
            } else {
                return false
            }
            //name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    
    func filterContentForCategory(category: Int) {
        filteredElements = responseElements.filter { element in
            if (element.thisCategoryID == category) {
                return true
            } else {
                return false
            }
        }
        tableView.reloadData()
    }
    
    func updateCategryResulsts() {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func getSegmenter() {
        segmentController = UISegmentedControl(items: ["ALL", "MY PICKS"])
        
        segmentController.layer.cornerRadius = 5
        segmentController.layer.masksToBounds = true
        segmentController.layer.borderWidth = 1
        segmentController.layer.borderColor = UIColor.init(red:0.93, green:0.93, blue:0.93, alpha:1.0).cgColor
        
        
        segmentController.setBackgroundImage(imageWithColor(UIColor.white), for: UIControl.State(), barMetrics: .default)
        
        segmentController.setDividerImage(imageWithColor(UIColor.white), forLeftSegmentState: UIControl.State(), rightSegmentState: UIControl.State(), barMetrics: .default)
        
        segmentController.setBackgroundImage(imageWithColor(UIColor.init(red:0.93, green:0.93, blue:0.93, alpha:1.0)), for: .selected, barMetrics: .default)
        
        //segmentController.setBackgroundImage(imageWithColorAndSize(UIColor.init(red:0.93, green:0.93, blue:0.93, alpha:1.0), size: CGSize(width: thisScreenBounds.width, height: 35)), for: .selected, barMetrics: .default)
        
        let thisNormalFont = UIFont(name: "Apercu", size: 13)
        
        segmentController.setTitleTextAttributes([NSAttributedString.Key.font: thisNormalFont!, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.foregroundColor: UIColor.init(red:0.62, green:0.62, blue:0.62, alpha:1.0)], for: UIControl.State())
        
        segmentController.setTitleTextAttributes([NSAttributedString.Key.font: thisNormalFont!, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        
        segmentController.frame = CGRect(x: thisScreenBounds.width/4, y: 5, width: thisScreenBounds.width/2, height: 35)
        segmentController.backgroundColor = UIColor.white
        segmentController.tintColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
        
        segmentController.selectedSegmentIndex = 0
        segmentController.addTarget(self, action: #selector(exhibitionViewController.getSegment), for: .valueChanged)
        self.view.addSubview(segmentController)
        
        segmentController.isUserInteractionEnabled = false
        if (isInFavMode) {
            segmentController.selectedSegmentIndex = 1
        }
    }
    
   
    
    @objc func getSegment() {
        thisActualCellIndex = 0
        segmentController.isUserInteractionEnabled = false
        if (segmentController.selectedSegmentIndex == 0) {
            //ALL
            isInFavMode = false
            
            UIView.animate(withDuration: 0.6, animations: {
                    self.tableView.alpha = 1
                }, completion: { finished in
                    if (finished) {
                        self.tableView.removeFromSuperview()
                        self.addIndicitaor()
                        self.getData()
                    }
            })
        }
        if (segmentController.selectedSegmentIndex == 1) {
            //FAVS
            
            isInFavMode = true
            let thisAppDelegate = returnAppDelegate()
            let thisUserID = thisAppDelegate.sessionUserID
            if (thisUserID == "") {
                let thisMessage = "Where did my picks go? No problem, just log in."
                let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
                failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                    self.segmentController.isUserInteractionEnabled = true
                    self.notLoggedIn()
                    })
                self.present(failureMessage, animated: true, completion: nil)
                return
            }
            
            UIView.animate(withDuration: 0.6, animations: {
                self.tableView.alpha = 1
                }, completion: { finished in
                    if (finished) {
                        self.tableView.removeFromSuperview()
                        self.addIndicitaor()
                        self.getData()
                    }
            })
        }
    }
    
    func notLoggedIn() {
        segmentController.selectedSegmentIndex = 0
        let revealController = self.revealViewController()
        revealController?.revealToggle(animated: true)
    }
    
    func getData() {
        responseElements = [feedListElementData]()
        
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "getFutureExhibitions?city_id=" + String(returnAppDelegate().thisCityID)
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        if (thisAppDelegate.sessionUserID != "") {
            let postString = "user_id="+thisAppDelegate.sessionUserID
            let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
            request.httpBody = requestBodyData
            //print("POST DATA") print(thisUrl) print(postString) print("-----")
        }
        
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
                if let json = jsonOptional as? Array<AnyObject> {
                    
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
                    //
                    //
                    
                    if (self.isInFavMode) {
                        if (thisIsFav) {
                            self.responseElements.append(thisFeedElement)
                        }
                    } else {
                        self.responseElements.append(thisFeedElement)
                    }
                }
                DispatchQueue.main.async {
                    self.getCategories()
                }
                }
            }
        }
        
    }
    
    func dataDone() {
        createTableView()
    }
    
    func getCategories() {
        categoryElements = [categoryData]()
        let thisAll = categoryData(id: 0, name: "All")
        categoryElements.append(thisAll)
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "get_categories"
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        let postString = "city_id="+String(thisAppDelegate.thisCityID)
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            
            if error != nil {
                
            } else {
                //print(String(data: data, encoding: String.Encoding.utf8))
                let jsonOptional: Any!
                do {
                    jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch _ as NSError {
                    jsonOptional = nil
                }
                
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    if let response = json["categories"] as? Array<AnyObject> {
                        
                            for item in response {
                                //print(item)
                                let thisCategoryElement:categoryData = categoryData(id: item["id"]! as! Int, name: self.nullToNil(item["name"])!)
                                self.categoryElements.append(thisCategoryElement)
                            }
                            DispatchQueue.main.async {
                                self.dataDone()
                            }
                        }
                    
                }
            }
        }
    }
    
    func createTableView() {
        removeIndicatior()
            if (isInFavMode && responseElements.count == 0) {
                let thisMessage = "Looks like you don’t have any picks yet. Go on, add one!"
                let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
                failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                    self.segmentController.isUserInteractionEnabled = true
                })
                self.present(failureMessage, animated: true, completion: nil)
            }
        
        
        //responseElements.sortInPlace({$0.sortingName.compare($1.sortingName) == NSComparisonResult.OrderedAscending})
        segmentController.isUserInteractionEnabled = true
        
        
        let thisCategoryListView:categoryListScrollView = categoryListScrollView()
        thisCategoryListView.delegateCall = self
        thisCategoryListView.alpha = 0
        //let thisArray = ["Prenzlberg", "Mitte", "Schöneberg", "Zoo", "Kreuzberg", "Neukölln", "Treptow"]
        thisCategoryListView.recieveTargetArray(targets: categoryElements)
        thisCategoryListView.layoutView()
        thisCategoryListView.frame = CGRect(x: 0, y: 45, width: thisScreenBounds.width, height: 35)
        
        if categoryFilterActive {
            thisCategoryListView.selectCategoryBasedOnTarget(targetID: thisTargetCategory)
        }
        
        self.view.addSubview(thisCategoryListView)
        
        tableView = UITableView()
        
        let thisY = CGFloat.init(80)
        let thisEndY = thisScreenBounds.height-64-thisY-50
        tableView.alpha = 0
        tableView.frame        =   CGRect(x: 0, y: thisY, width: thisScreenBounds.width, height: thisEndY)
        tableView.delegate     =   self
        tableView.dataSource   =   self
        tableView.register(exhibitionFeedListCell.self, forCellReuseIdentifier: "exhibitionFeedListCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.allowsMultipleSelectionDuringEditing = true
        
        self.view.addSubview(tableView)
        //self.edgesForExtendedLayout
        self.edgesForExtendedLayout = UIRectEdge.top
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.extendedLayoutIncludesOpaqueBars = true
        searchController.dimsBackgroundDuringPresentation = false
        
        /*
        searchController.automaticallyAdjustsScrollViewInsets = false
        searchController.extendedLayoutIncludesOpaqueBars = true
        searchController.searchBar.sizeToFit()
        self.definesPresentationContext = true
         */
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0.0, y: 55)
        
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.6)
        tableView.alpha = tableView.alpha * (1) + 1
        thisCategoryListView.alpha = thisCategoryListView.alpha * (1) + 1
        UIView.commitAnimations()
        
        if (thisActualCellIndex != 0) {
            let thisIndexPath = IndexPath(row: thisActualCellIndex, section: 0)
            tableView.scrollToRow(at: thisIndexPath, at: .middle, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredElements.count
        }
        if categoryFilterActive {
            return filteredElements.count
        }
        
        return self.responseElements.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]
        let thisHeight = CGFloat(100)
        
        if (thisElement.featured == true) {
            
        }
        
        return thisHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var thisElement:feedListElementData = responseElements[(indexPath as NSIndexPath).row]
        
        if searchController.isActive && searchController.searchBar.text != "" && filteredElements.count > 0 {
            thisElement = filteredElements[(indexPath as NSIndexPath).row]
        }
        if categoryFilterActive {
            thisElement = filteredElements[(indexPath as NSIndexPath).row]
        }
        
        let cell:exhibitionFeedListCell? = tableView.dequeueReusableCell(withIdentifier: "exhibitionFeedListCell", for: indexPath) as? exhibitionFeedListCell
        cell?.prepareForReuse()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (searchController.isActive) {
            searchController.dismiss(animated: false, completion: ({}))
        }
        if(segue.identifier == "showDetail") {
            let nextViewController = (segue.destination) as! detailViewController
            nextViewController.thisDetailToBeViewed = self.thisSelectedID
        }
    }
    
    func removeFavorite(_ item: String, cell: exhibitionFeedListCell) {
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
    
    func setSpecificIDTo(fav: Bool, id: String) {
        var i = 0
        for var item in responseElements {
            if (String(item.targetID) == id) {
                responseElements[i].isFav = fav
            }
            i = i + 1
        }
    }
    
    func addToFavorites(_ item: String, cell: exhibitionFeedListCell) {
        thisSelectedID = item
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        if (thisUserID == "") {
            let thisMessage = "Where did my picks go? No problem, just log in."
            let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                self.segmentController.isUserInteractionEnabled = true
                self.notLoggedIn()
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
    
    func callDetailViewOfItem(_ item: String, cellIndex: Int) {
        //print("CURRENT CELL")
        //print(cellIndex)
        thisSelectedID = item
        thisActualCellIndex = cellIndex
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    //FILTER
    func filterViewBy(_ sender: categoryListScrollView, targetCategory: Int) {
        //print("Filter by")
        //print(targetCategory)
        if (targetCategory != 0) {
            categoryFilterActive = true
            thisTargetCategory = targetCategory
            filterContentForCategory(category: targetCategory)
        } else {
            categoryFilterActive = false
            tableView.reloadData()
        }
    }
}
