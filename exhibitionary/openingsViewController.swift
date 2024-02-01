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

struct openingFeedListElementData {
    var targetID:Int
    var labelText:String
    var backgroundImageURL:String
    var featured:Bool = false
    var images:Array<AnyObject>
    var thisParseEndDate:Date
    var venueAdress:String = ""
    var venueName:String = ""
    var thisParseOpeningDate:Date
    var opensToday:Bool = false
    var opensHour:String = ""
    var isFav:Bool = false
    var thisCategoryID:Int
    var thisCategoryString:String = ""
}

class openingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchResultsUpdating, callFilter {
    
    let thisScreenBounds = UIScreen.main.bounds
    var thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var responseElements = [openingFeedListElementData]()
    var filteredElements = [openingFeedListElementData]()
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
    var theseDays:Array<String> = Array()
    var theseDayCounts:Array<Int> = Array()
    var responseElementsInSection = [Array<openingFeedListElementData>]()
    var isInFavMode = false
    var thisActualCellIndex = 0
    var thisActualSection = 0
    var hasRestoreableCellIndex = false
    
    var categoryElements = [categoryData]()
    var categoryFilterActive = false
    var thisTargetCategory = 0
    
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
        
        setUpHeader("Openings")
        
        self.automaticallyAdjustsScrollViewInsets = false
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        addIndicitaor()
        
        setTrack("Openings", parameter: "")
        setUpMenuButton()
        
        tableView.removeFromSuperview()
        
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        thisSelectedCity = String(thisAppDelegate.thisCityID)
        
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
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        
        if (searchController.searchBar.text != "") {
        
        filteredElements = responseElements.filter { element in
            if (element.labelText.lowercased().contains(searchText.lowercased()) || element.venueName.lowercased().contains(searchText.lowercased()) || element.venueAdress.lowercased().contains(searchText.lowercased())) {
                return true
            } else {
                return false
            }
            //name.lowercaseString.containsString(searchText.lowercaseString)
        }
            
        
        } else {
            //tableView.removeFromSuperview()
            //sortArray()
            
            filteredElements = responseElements.reversed()
        }
        
        sortFilteredArray()
        
    }
    
    func filterContentForCategory(category: Int) {
        filteredElements = responseElements.filter { element in
            if (element.thisCategoryID == category) {
                return true
            } else {
                return false
            }
        }
        sortFilteredArray()
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
    
    
    
    func getSegment() {
        //thisActualCellIndex = 0
        hasRestoreableCellIndex = false
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
    
    
   
    
    func thisDateCreator(_ inputDate:String) -> Date {
        var thisEndDate:Date = Date(timeIntervalSince1970: 0)
        
        if (inputDate != "-") {
            let df:DateFormatter = DateFormatter()
            df.locale = Locale(identifier: "us")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let thisEndDateFromString:Date = df.date(from: inputDate)!
            thisEndDate = thisEndDateFromString
        }
        
        return thisEndDate
    
    }
    
    func getData() {
        responseElements = [openingFeedListElementData]()
        
        let thisAppDelegate = returnAppDelegate()
        
        var thisUrl = globalData.dbUrl + "getExhibitions?city_id=" + String(returnAppDelegate().thisCityID)
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        if (thisAppDelegate.sessionUserID != "") {
            let postString = "user_id="+thisAppDelegate.sessionUserID
            let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
            request.httpBody = requestBodyData
        }
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            //print("Data")
            //print(String(data: data, encoding: String.Encoding.utf8))
            if error != nil {
                
            } else {
                
                //var e:NSError
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
                    
                    let thisFeedElement:openingFeedListElementData = openingFeedListElementData(targetID: item["id"] as! Int, labelText: self.nullToNil(item["title"])!, backgroundImageURL: thisImageURL, featured: false, images: theseImages, thisParseEndDate: self.thisDateCreator(self.nullToNil(item["opening_end"])!), venueAdress: self.nullToNil(item["venue_quarter"])!, venueName: self.nullToNil(item["venue_name"])!, thisParseOpeningDate: self.thisDateCreator(self.nullToNil(item["opening_start"])!), opensToday: false, opensHour: "", isFav: thisIsFav, thisCategoryID: item["category_id"]! as! Int, thisCategoryString: self.nullToNil(item["category_name"])!)
                    
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
            
            let endDate = thisEndDate
            
            let hourMinuteComponents:NSCalendar.Unit = [NSCalendar.Unit.day]
            let timeDifference = (userCalendar as NSCalendar).components(hourMinuteComponents, from: Date(), to: endDate, options: [])
            
            //print(timeDifference.day)
            
            if (timeDifference.day == 0) {
                isOpeningToday = true
            }
        }
        return isOpeningToday
    }
    
    
    func sortArray() {
        
        responseElements.sort(by: {$0.thisParseOpeningDate.compare($1.thisParseOpeningDate) == ComparisonResult.orderedAscending})
    
        var thisLastElement = ""
        var thisTotalDays = 0
        var thisNumberOfElements = 1
        theseDayCounts = Array()
        theseDays = Array()
        responseElementsInSection = [Array<openingFeedListElementData>]()
        
        var thisSubArray = [openingFeedListElementData]()
        var thisDateString = ""
        
        let df:DateFormatter = DateFormatter()
        df.locale = Locale(identifier: "us")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //"1970-01-01 00:00:00 +0000"
        let thisEndDateFromString:Date = df.date(from: "1970-01-01 00:00:00")!
        
        let thisEndDate = thisEndDateFromString
        
        for var item in responseElements {
            
            if(item.thisParseOpeningDate != thisEndDate) {
                
                let dateFormatter = DateFormatter()
                
                //dateFormatter.locale = NSLocale(localeIdentifier: "us")
                //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "EEEE, d MMMM"
                
                thisDateString = dateFormatter.string(from: item.thisParseOpeningDate)
                
               
                let userCalendar = Calendar.current
                
                
                var components:DateComponents = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
                
                var today:Date = userCalendar.date(from: components)!
                
                components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: item.thisParseOpeningDate)
                
                var otherDate:Date = userCalendar.date(from: components)!
                var thisHourDateString = ""
                let dateFormatterHour = DateFormatter()
                dateFormatterHour.timeZone = TimeZone(identifier: "UTC")
                dateFormatterHour.dateFormat = "HH:mm"
                thisHourDateString = dateFormatterHour.string(from: item.thisParseOpeningDate)
                item.opensHour = "Opening: " + thisHourDateString
                
                if(item.thisParseEndDate != thisEndDate) {
                        thisHourDateString = dateFormatterHour.string(from: item.thisParseEndDate)
                        item.opensHour = item.opensHour + " - " + thisHourDateString
                }
                /*
                print("TODAY: ")
                print(today)

                print("OTHER DATE")
                print(otherDate)
                */
                if(today == otherDate) {
                    //TODAY
                    
                    item.opensToday = true
                    
                    
                    if (thisLastElement != thisDateString) {
                        thisSubArray = [openingFeedListElementData]()
                        thisTotalDays = thisTotalDays + 1
                        thisNumberOfElements = 1
                        theseDays.append(thisDateString)
                        
                        thisLastElement = thisDateString
                        
                        thisSubArray.append(item)
                    } else {
                        thisNumberOfElements = thisNumberOfElements + 1
                        thisSubArray.append(item)
                    }
                    
                }
                
                components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
                today = userCalendar.date(from: components)!
                components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: item.thisParseOpeningDate)
                otherDate = userCalendar.date(from: components)!
                /*
                print("----")
                print("TODAY: ")
                print(today)
                
                print("OTHER DATE")
                print(otherDate)
                */
                
                if(today.compare(otherDate) == ComparisonResult.orderedAscending) {
                    //FUTURE
                    
                    
                    if (thisLastElement != thisDateString) {
                        if (!thisSubArray.isEmpty) {
                            responseElementsInSection.append(thisSubArray)
                            theseDayCounts.append(thisNumberOfElements)
                            
                            thisSubArray = [openingFeedListElementData]()
                            thisTotalDays = thisTotalDays + 1
                            thisNumberOfElements = 1
                            theseDays.append(thisDateString)
                            
                            thisLastElement = thisDateString
                        } else {
                            thisSubArray = [openingFeedListElementData]()
                            thisTotalDays = thisTotalDays + 1
                            thisNumberOfElements = 1
                            theseDays.append(thisDateString)
                            
                            thisLastElement = thisDateString
                        }
                        
                        thisSubArray.append(item)
                        
                    } else {
                        thisNumberOfElements = thisNumberOfElements + 1
                        thisSubArray.append(item)
                    }
                    
                }
                
                if(item.opensToday) {
                    
                }
                
            }
            
            
        }
       
        if (!thisSubArray.isEmpty) {
            responseElementsInSection.append(thisSubArray)
            theseDayCounts.append(thisNumberOfElements)
        }
        
        
        if (thisTotalDays > 0) {
            createTableFromSortedArray()
            return
        } else {
            
            var thisMessage = "There are no shows here at the moment. Check back soon!"
            if (isInFavMode) {
                thisMessage = "Looks like you don’t have any picks yet. Go on, add one!"
            }
            let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                    self.segmentController.isUserInteractionEnabled = true
                })
            self.present(failureMessage, animated: true, completion: nil)
            return
        }
    }
    
    func sortFilteredArray() {
        
        filteredElements.sort(by: {$0.thisParseOpeningDate.compare($1.thisParseOpeningDate) == ComparisonResult.orderedAscending})
        
        var thisLastElement = ""
        var thisTotalDays = 0
        var thisNumberOfElements = 1
        theseDayCounts = Array()
        theseDays = Array()
        responseElementsInSection = [Array<openingFeedListElementData>]()
        
        var thisSubArray = [openingFeedListElementData]()
        var thisDateString = ""
        
        let df:DateFormatter = DateFormatter()
        df.locale = Locale(identifier: "us")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //"1970-01-01 00:00:00 +0000"
        let thisEndDateFromString:Date = df.date(from: "1970-01-01 00:00:00")!
        
        let thisEndDate = thisEndDateFromString
        
        for var item in filteredElements {
            
            if(item.thisParseOpeningDate != thisEndDate) {
                
                let dateFormatter = DateFormatter()
                
                //dateFormatter.locale = NSLocale(localeIdentifier: "us")
                //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "EEEE, d MMMM"
                
                thisDateString = dateFormatter.string(from: item.thisParseOpeningDate)
                
                
                let userCalendar = Calendar.current
                
                
                var components:DateComponents = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
                
                var today:Date = userCalendar.date(from: components)!
                
                components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: item.thisParseOpeningDate)
                
                var otherDate:Date = userCalendar.date(from: components)!
                var thisHourDateString = ""
                let dateFormatterHour = DateFormatter()
                dateFormatterHour.timeZone = TimeZone(identifier: "UTC")
                dateFormatterHour.dateFormat = "HH:mm"
                thisHourDateString = dateFormatterHour.string(from: item.thisParseOpeningDate)
                item.opensHour = "Opening: " + thisHourDateString
                
                if(item.thisParseEndDate != thisEndDate) {
                    thisHourDateString = dateFormatterHour.string(from: item.thisParseEndDate)
                    item.opensHour = item.opensHour + " - " + thisHourDateString
                }
                /*
                 print("TODAY: ")
                 print(today)
                 
                 print("OTHER DATE")
                 print(otherDate)
                 */
                if(today == otherDate) {
                    //TODAY
                    
                    item.opensToday = true
                    
                    
                    if (thisLastElement != thisDateString) {
                        thisSubArray = [openingFeedListElementData]()
                        thisTotalDays = thisTotalDays + 1
                        thisNumberOfElements = 1
                        theseDays.append(thisDateString)
                        
                        thisLastElement = thisDateString
                        
                        thisSubArray.append(item)
                    } else {
                        thisNumberOfElements = thisNumberOfElements + 1
                        thisSubArray.append(item)
                    }
                    
                }
                
                components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
                today = userCalendar.date(from: components)!
                components = (userCalendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: item.thisParseOpeningDate)
                otherDate = userCalendar.date(from: components)!
                /*
                 print("----")
                 print("TODAY: ")
                 print(today)
                 
                 print("OTHER DATE")
                 print(otherDate)
                 */
                
                if(today.compare(otherDate) == ComparisonResult.orderedAscending) {
                    //FUTURE
                    
                    
                    if (thisLastElement != thisDateString) {
                        if (!thisSubArray.isEmpty) {
                            responseElementsInSection.append(thisSubArray)
                            theseDayCounts.append(thisNumberOfElements)
                            
                            thisSubArray = [openingFeedListElementData]()
                            thisTotalDays = thisTotalDays + 1
                            thisNumberOfElements = 1
                            theseDays.append(thisDateString)
                            
                            thisLastElement = thisDateString
                        } else {
                            thisSubArray = [openingFeedListElementData]()
                            thisTotalDays = thisTotalDays + 1
                            thisNumberOfElements = 1
                            theseDays.append(thisDateString)
                            
                            thisLastElement = thisDateString
                        }
                        
                        thisSubArray.append(item)
                        
                    } else {
                        thisNumberOfElements = thisNumberOfElements + 1
                        thisSubArray.append(item)
                    }
                    
                }
                
                if(item.opensToday) {
                    
                }
                
            }
            
            
        }
        
        if (!thisSubArray.isEmpty) {
            responseElementsInSection.append(thisSubArray)
            theseDayCounts.append(thisNumberOfElements)
        }
        
        tableView.reloadData()
        
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
        
        
        sortArray()
    }
    
    func createTableFromSortedArray() {
        removeIndicatior()
        /*
        //responseElementsInSection[indexPath.section][indexPath.row]
        var i = 0
        for item in responseElementsInSection {
            print("----")
            print(theseDays[i])
            for subitem in item {
                print(subitem.labelText)
            }
            i = i + 1
        }
        */
        
        
        segmentController.isUserInteractionEnabled = true
        
        let thisCategoryListView:categoryListScrollView = categoryListScrollView()
        thisCategoryListView.delegateCall = self
        thisCategoryListView.alpha = 0
        
        //let thisArray = ["Prenzlberg", "Mitte", "Schöneberg", "Zoo", "Kreuzberg", "Neukölln", "Treptow"]
        thisCategoryListView.recieveTargetArray(targets: categoryElements)
        thisCategoryListView.layoutView()
        thisCategoryListView.frame = CGRect(x: 0, y: 45, width: thisScreenBounds.width, height: 35)
        self.view.addSubview(thisCategoryListView)
        
        if categoryFilterActive {
            thisCategoryListView.selectCategoryBasedOnTarget(targetID: thisTargetCategory)
        }
        
         tableView = UITableView()
         
         let thisY = CGFloat.init(80)
         let thisEndY = thisScreenBounds.height-64-thisY-50
        
         tableView.alpha = 0
         tableView.frame        =   CGRect(x: 0, y: thisY, width: thisScreenBounds.width, height: thisEndY)
         tableView.delegate     =   self
         tableView.dataSource   =   self
         tableView.register(openingsFeedListCell.self, forCellReuseIdentifier: "openingsFeedListCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
         self.view.addSubview(tableView)
       
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.extendedLayoutIncludesOpaqueBars = true
        searchController.dimsBackgroundDuringPresentation = false

        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0.0, y: 55)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.6)
        tableView.alpha = tableView.alpha * (1) + 1
        thisCategoryListView.alpha = thisCategoryListView.alpha * (1) + 1
        UIView.commitAnimations()
 
        if (hasRestoreableCellIndex) {
            let thisIndexPath = IndexPath(row: thisActualCellIndex, section: thisActualSection)
            tableView.scrollToRow(at: thisIndexPath, at: .middle, animated: false)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //print("Amount of Secitons in Table View: " + String(self.responseElementsInSection.count))
        
        return self.responseElementsInSection.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("Rows in section " + String(section) + ": " + String(self.responseElementsInSection[section].count))
        
        return self.responseElementsInSection[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let thisElement:openingFeedListElementData = responseElements[indexPath.row]
        let thisHeight = CGFloat(100)
        return thisHeight
    }
    /*
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //
        return self.theseDays[section]
    }
 */
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let thisView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 30))
        thisView.backgroundColor = UIColor.white
        
        let thisLabel = UILabel(frame: CGRect(x: 10, y: 0, width: thisScreenBounds.width-20, height: 30))
        
        let thisSectionText = self.theseDays[section]
        
        let thisText = NSMutableAttributedString(string: thisSectionText.uppercased())
        
        let rangeEnd = thisSectionText.range(of: ",")
        let endIndex:Int = thisSectionText.distance(from: thisSectionText.startIndex, to: (rangeEnd?.lowerBound)!)
        let finalIndex:Int = thisSectionText.distance(from: thisSectionText.startIndex, to: thisSectionText.endIndex)
        
        thisText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Apercu-Bold", size: 14)!, range: NSMakeRange(0, finalIndex))
        
        thisText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250), range: NSMakeRange(0, finalIndex))
        
        
        thisText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Apercu-Bold", size: 14)!, range: NSMakeRange(0, endIndex))
        
        thisText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, endIndex))
        
        thisLabel.attributedText = thisText
        
        thisView.addSubview(thisLabel)
        
        return thisView
    }
    
    func getDaysElements(_ dateString:String) -> Array<openingFeedListElementData> {
        var thisArray = Array<openingFeedListElementData>()
        
        for item in responseElements {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            let thisDateString = dateFormatter.string(from: item.thisParseOpeningDate)
            if (thisDateString == dateString) {
                thisArray.append(item)
            }
            
        }
        return thisArray
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let thisDaysElements:Array<openingFeedListElementData> = getDaysElements(self.theseDays[indexPath.section])
        //print(thisDaysElements)
        var thisElement:openingFeedListElementData = responseElementsInSection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        //print("Showing: " + thisElement.labelText)
        //let cell:openingsFeedListCell? = tableView.dequeueReusableCellWithIdentifier("openingsFeedListCell", forIndexPath: indexPath) as? openingsFeedListCell
        let cell:openingsFeedListCell = openingsFeedListCell(style: .default, reuseIdentifier: "openingsFeedListCell")
        
        let thisLabelText = thisElement.labelText
        cell.parentNewsController = self
        cell.loadImageInto(thisElement.backgroundImageURL)
        cell.profileImageURL = thisElement.backgroundImageURL
        cell.thisID = thisElement.targetID
        cell.actionLabel.text = thisLabelText
        cell.adressLabel.text = thisElement.venueName + ", " + thisElement.venueAdress
        cell.hoursLabel.text = ""
        cell.myIndex = (indexPath as NSIndexPath).row
        cell.mySection = (indexPath as NSIndexPath).section
        cell.hoursLabel.text = thisElement.opensHour
        
        if (thisElement.opensToday) {
            
        }
        
        
        if (thisElement.isFav) {
            cell.plusLabel.layer.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
            cell.plusLabel.textColor = UIColor.white
            cell.plusLabel.text = "-"
            cell.isFav = true
        }
        
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if (thisGrey) {
            thisGrey = false
            cell.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 250)
        } else {
            thisGrey = true
            cell.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 250)
        }
        return cell
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
    
    func removeFavorite(index: Int, section: Int) {
        responseElementsInSection[section][index].isFav = false
    }
    
    func addToFavorites(index: Int, section: Int) {
        responseElementsInSection[section][index].isFav = true
    }
    
    func displayNonLoggedInMessage() {
        let thisMessage = "Where did my picks go? No problem, just log in."
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            self.notLoggedIn()
            })
        self.present(failureMessage, animated: true, completion: nil)
        return
    }
    func callDetailViewOfItem(_ item: String, cellIndex: Int, sectionIndex: Int) {
        
        thisSelectedID = item
        thisActualCellIndex = cellIndex
        thisActualSection = sectionIndex
        hasRestoreableCellIndex = true
        
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    //FILTER
    func filterViewBy(_ sender: categoryListScrollView, targetCategory: Int) {
        //print("Filter by")
        //print(targetCategory)
        if (targetCategory != 0) {
            categoryFilterActive = true
            filterContentForCategory(category: targetCategory)
            thisTargetCategory = targetCategory
        } else {
            categoryFilterActive = false
            sortArray()
        }
    }
}
