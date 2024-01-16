//
//  locateViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 16/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

//MAP


import Foundation
import UIKit
import GoogleMaps
import SDWebImage

struct feedListElementWithGeoData {
    var targetID:Int
    var labelText:String
    var backgroundImageURL:String
    var featured:Bool = false
    var images:Array<AnyObject>
    var lat:String
    var long:String
    var isFav:Bool = false
    var openingStart:String
    var venueName:String
    var venueStreet:String
    var venueQuartier:String
    var thisCategoryID:Int
    var thisCategoryString:String = ""
}


class locateViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchResultsUpdating, callFilter {
    let thisScreenBounds = UIScreen.main.bounds
    
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    var mapView: GMSMapView!
    var responseElements = [feedListElementWithGeoData]()
    var filteredElements = [feedListElementWithGeoData]()
    
    var thisSelectedID = ""
    var thisSelectedCity = ""
    var segmentController:UISegmentedControl = UISegmentedControl()
    var feedSelectionArray:Array<String> = Array()
    var thisContentView:UIView = UIView()
    var isInFavMode = false
    var thisMarkerWindow:UIView = UIView()
    
    var thisOldCity = 0
    var thisPrevLat = Double(0)
    var thisPrevLong = Double(0)
    
    var thisZoom = Float(0)
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var categoryElements = [categoryData]()
    var categoryFilterActive = false
    var thisTargetCategory = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let appearance = UITabBarItem.appearance()
        let thisFont = UIFont(name: "Apercu-Regular", size: 12)
        appearance.setTitleTextAttributes([NSAttributedString.Key.font: thisFont!], for: UIControl.State())

    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHeader("Map")
        self.automaticallyAdjustsScrollViewInsets = false
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTrack("Map", parameter: "")
        setUpMenuButton()
        
        let thisAppDelegate = returnAppDelegate()
        thisSelectedCity = String(thisAppDelegate.thisCityID)
        
        if (thisOldCity != thisAppDelegate.thisCityID) {
            
            thisOldCity = thisAppDelegate.thisCityID
            thisPrevLat = 0
            thisPrevLong = 0
            thisSelectedID = ""
            categoryFilterActive = false
        }
        
        thisContentView = UIView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height-64))
        
        var thisLong = Double(thisAppDelegate.thisCityLong)
        var thisLat = Double(thisAppDelegate.thisCityLat)
        var zoom = Float(10)
        
        //52.231803, 21.015868
                
        if (Int(thisPrevLat) != 0) {
            thisLat = thisPrevLat
            thisLong = thisPrevLong
            zoom = 14
            
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: thisLat!, longitude: thisLong!, zoom: zoom)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 80, width: thisScreenBounds.width, height: thisContentView.frame.maxY-64), camera: camera) //thisScreenBounds.height-
        //mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        thisContentView.addSubview(mapView)
        
        let searchButtonImage = UIImage(named: "SearchButton.png")
        let searchButtonImageScaled = UIImage(cgImage: (searchButtonImage?.cgImage)!, scale: 3, orientation: UIImage.Orientation.up)
        let searchButtonImageView = UIImageView(frame: CGRect(x: thisScreenBounds.width-40, y: 10, width: 30, height: 30))
        searchButtonImageView.image = searchButtonImageScaled
        searchButtonImageView.contentMode = .scaleAspectFill
        //searchButtonImageView.backgroundColor = UIColor.white
        searchButtonImageView.isUserInteractionEnabled = true
        
        let searchButtonImageViewTap = UITapGestureRecognizer(target: self, action: #selector(locateViewController.showSearch))
        searchButtonImageView.addGestureRecognizer(searchButtonImageViewTap)
        
        thisContentView.addSubview(searchButtonImageView)
        
        self.view.addSubview(thisContentView)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        
        let thisUserID = thisAppDelegate.sessionUserID
        if (thisUserID == "") {
            isInFavMode = false
            getData()
        } else {
            getData()
        }
        
        getSegmenter()
        
        if (isInFavMode) {
            segmentController.selectedSegmentIndex = 1
        }
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    @objc func showSearch() {
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.extendedLayoutIncludesOpaqueBars = true
        searchController.dimsBackgroundDuringPresentation = false
        
        //searchController.view.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 44)
        
        self.present(searchController, animated: true, completion: nil)
        
        //thisContentView.addSubview(searchController.view)
        
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredElements = responseElements.filter { element in
            if (element.labelText.lowercased().contains(searchText.lowercased()) || element.venueName.lowercased().contains(searchText.lowercased()) || element.venueStreet.lowercased().contains(searchText.lowercased()) || element.venueQuartier.lowercased().contains(searchText.lowercased())
                ) {
                return true
            } else {
                return false
            }
            //name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        mapView.clear()
        createTableView()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    func filterContentForCategory(category: Int) {
        filteredElements = responseElements.filter { element in
            if (element.thisCategoryID == category) {
                return true
            } else {
                return false
            }
        }
        
        mapView.clear()
        createTableView()
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
        segmentController.isUserInteractionEnabled = false
        thisPrevLong = 0
        thisPrevLat = 0
        thisSelectedID = ""
        if (segmentController.selectedSegmentIndex == 0) {
            //ALL
            
            isInFavMode = false
            mapView.clear()
            getData()
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
                    self.notLoggedIn()
                    })
                self.present(failureMessage, animated: true, completion: nil)
                return
            }
            
            mapView.clear()
            getData()
        }
    }
    
    func notLoggedIn() {
        segmentController.selectedSegmentIndex = 0
        let revealController = self.revealViewController()
        revealController?.revealToggle(animated: true)
    }
    
    func opensToday (_ openingDate:String) -> Bool {
        var isOpeningToday = false
        
        if (openingDate != "-") {
        
            var thisEndDate:Date = Date()
            let df:DateFormatter = DateFormatter()
            df.locale = Locale(identifier: "us")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            df.timeZone = TimeZone(identifier: "UTC")
            
            let thisEndDateFromString:Date = df.date(from: openingDate)!
            thisEndDate = thisEndDateFromString
            
            let userCalendar = NSCalendar.current
        
            
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
    
    
    
    
    func getData() {
        responseElements = [feedListElementWithGeoData]()
        
        var thisUrl = globalData.dbUrl + "getExhibitions?city_id=" + String(returnAppDelegate().thisCityID)
        
        /*
        thisUrl = thisUrl + "&search=" + searchExpression
        if (thisCADFilterOn) {
            thisUrl = thisUrl + "&cad=1"
        }
        */
        
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

                    
                    let thisFeedElement:feedListElementWithGeoData = feedListElementWithGeoData(targetID: item["id"]! as! Int, labelText: item["title"] as! String, backgroundImageURL: thisImageURL, featured: false, images: theseImages, lat: self.nullToNil(item["venue_lat"])!, long: self.nullToNil(item["venue_long"])!, isFav: thisIsFav, openingStart: self.nullToNil(item["opening_start"])!, venueName: self.nullToNil(item["venue_name"])!, venueStreet: self.nullToNil(item["venue_street"])!, venueQuartier: self.nullToNil(item["venue_quarter"])!, thisCategoryID: item["venue_quarter_id"]! as! Int, thisCategoryString: self.nullToNil(item["venue_quarter"])!)
                    
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
        let thisCategoryListView:categoryListScrollView = categoryListScrollView()
        thisCategoryListView.delegateCall = self
        
        //let thisArray = ["Prenzlberg", "Mitte", "Schöneberg", "Zoo", "Kreuzberg", "Neukölln", "Treptow"]
        thisCategoryListView.recieveTargetArray(targets: categoryElements)
        thisCategoryListView.layoutView()
        thisCategoryListView.frame = CGRect(x: 0, y: 45, width: thisScreenBounds.width, height: 35)
        self.view.addSubview(thisCategoryListView)
        
        if categoryFilterActive {
            thisCategoryListView.selectCategoryBasedOnTarget(targetID: thisTargetCategory)
        }

        
        createTableView()
    }
    
    func getCategories() {
        categoryElements = [categoryData]()
        let thisAll = categoryData(id: 0, name: "All")
        categoryElements.append(thisAll)
        
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "get_quarters"
        
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
                    if let response = json["quarters"] as? Array<AnyObject> {
                        
                        for item in response {
                            
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
        var i = 0
        segmentController.isUserInteractionEnabled = true
        if (isInFavMode && responseElements.count == 0) {
            let thisMessage = "Looks like you don’t have any picks yet. Go on, add one!"
            let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                self.segmentController.isUserInteractionEnabled = true
            })
            self.present(failureMessage, animated: true, completion: nil)
        }
        
        var thisElements = responseElements
        if (searchController.isActive && searchController.searchBar.text != "") { thisElements = filteredElements }
        if (categoryFilterActive) { thisElements = filteredElements }
        
        for item in thisElements {
            
            var thisLat = ""
            var thisLong = ""
            if(item.lat != "" && item.long != "") {
                 thisLat = item.lat.trimmingCharacters(in: CharacterSet.whitespaces)
                 thisLong = item.long.trimmingCharacters(in: CharacterSet.whitespaces)
            } else {
                
            }
            
            
            if (item.lat != "-" && item.lat != "") {
                let position = CLLocationCoordinate2DMake(Double(thisLat)!, Double(thisLong)!)
                let marker = GMSMarker(position: position)
                marker.icon = UIImage(named: "LocateButtons")
                
                if (item.isFav) {
                    marker.icon = UIImage(named: "LocateButtonsBlack")
                }
                if (opensToday(item.openingStart)) {
                    marker.icon = UIImage(named: "LocateButtonsRed")
                }
                marker.title = item.labelText
//                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.opacity = 0.8
                //marker.flat = true
                marker.map = mapView
                marker.userData = i
                marker.tracksInfoWindowChanges = true
                if (item.targetID == Int(thisSelectedID)) {
                    mapView.selectedMarker = marker
                    mapView.animate(toZoom: thisZoom)
                }
                
            }
            
        i = i + 1
        }
        
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let thisString = marker.userData as! Int
        var thisCallDetailElement = String(responseElements[thisString].targetID)
        
        thisPrevLat = Double(responseElements[thisString].lat)!
        thisPrevLong = Double(responseElements[thisString].long)!
        
        if (searchController.isActive && searchController.searchBar.text != "") {
            thisCallDetailElement = String(filteredElements[thisString].targetID)
            thisPrevLat = Double(filteredElements[thisString].lat)!
            thisPrevLong = Double(filteredElements[thisString].long)!
        }
        
        if (categoryFilterActive) {
            thisCallDetailElement = String(filteredElements[thisString].targetID)
            thisPrevLat = Double(filteredElements[thisString].lat)!
            thisPrevLong = Double(filteredElements[thisString].long)!
        }
        
        callDetailViewOfItem(thisCallDetailElement)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change?[NSKeyValueChangeKey.newKey] as! CLLocation
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            didFindMyLocation = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.removeObserver(self, forKeyPath: "myLocation")
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let thisObject = marker.userData as! Int
        
        thisMarkerWindow = UIView(frame: CGRect(x: 0, y: 0, width: thisScreenBounds.width-50, height: 100))
        //thisMarkerWindow.backgroundColor = UIColor.whiteColor()
        
        
        
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = CGRect(x: 0, y: 0, width: thisScreenBounds.width-50, height: 100)
        rectShape1.position = CGPoint(x: (thisScreenBounds.width-50)/2, y: 50)
        rectShape1.cornerRadius = 8
        rectShape1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        
        thisMarkerWindow.layer.addSublayer(rectShape1)
        
        
        /*
        let thisImageWindow:UIImageView = UIImageView(frame: CGRectMake(0, 0, thisScreenBounds.width-50, 120))
        thisImageWindow.contentMode = UIViewContentMode.ScaleAspectFill
        thisImageWindow.layer.cornerRadius = 8
        thisImageWindow.layer.borderWidth = 0
        thisImageWindow.clipsToBounds = true
        
        thisMarkerWindow.addSubview(thisImageWindow)
        */
        
        let profileImage = UIImageView(frame: CGRect(x: 15, y: 15, width: 70, height: 70))
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 0
        profileImage.clipsToBounds = true
        
        thisMarkerWindow.addSubview(profileImage)
        
        var thisItem = self.responseElements[thisObject]
        if (searchController.isActive && searchController.searchBar.text != "") {
            thisItem = self.filteredElements[thisObject]
        }
        if (categoryFilterActive) {
            thisItem = self.filteredElements[thisObject]
        }
        let thisURL = URL(string: thisItem.backgroundImageURL)
        
        profileImage.sd_setImageWithPreviousCachedImage(with: thisURL, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: { (thisimage, thiserror, imageCacheType, url) in
            profileImage.image = thisimage
            
        })
               
        //profileImage.sd_setImageWithURL(thisURL)
        //thisImageWindow.sd_setImageWithURL(NSURL(string:    ))
        
        
        var thisActionLabelText = thisItem.labelText
        
        if (opensToday(thisItem.openingStart)) {
            
            var thisEndDate:Date = Date(timeIntervalSince1970: 0)
            let df:DateFormatter = DateFormatter()
            df.locale = Locale(identifier: "us")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let thisEndDateFromString:Date = df.date(from: thisItem.openingStart)!
            thisEndDate = thisEndDateFromString
            
            
            let dateFormatterHour = DateFormatter()
            dateFormatterHour.timeZone = TimeZone(identifier: "UTC")
            dateFormatterHour.dateFormat = "HH:mm"
            let thisHourDateString:String = dateFormatterHour.string(from: thisEndDate)
            /*
            let thisOpening:UILabel = UILabel(frame: CGRectMake(10, 130, thisScreenBounds.width-60, 20))
            thisOpening.textAlignment = .Left
            thisOpening.font = UIFont(name: "Apercu-Bold", size: 15)
            thisOpening.text =
            */
            
            thisActionLabelText = thisActionLabelText + " opens today! " + "Starting at: " + thisHourDateString
            
        }
        /*
        let thisVenueLabel:UILabel = UILabel(frame: CGRectMake(10, 150, thisScreenBounds.width-60, 20))
        thisVenueLabel.textAlignment = .Left
        thisVenueLabel.font = UIFont(name: "Apercu-Bold", size: 15)
        thisVenueLabel.text = responseElements[thisObject].labelText
        
        thisMarkerWindow.addSubview(thisVenueLabel)
         */
        let actionLabel = UILabel(frame: CGRect(x: 90, y: 10, width: thisScreenBounds.width-160, height: 40))
        actionLabel.textColor = UIColor.black
        actionLabel.font = UIFont(name: "Apercu-Bold", size: 15)
        actionLabel.textAlignment = NSTextAlignment.left
        actionLabel.backgroundColor = UIColor.clear
        actionLabel.isUserInteractionEnabled = true
        actionLabel.numberOfLines = 2
        actionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        actionLabel.text = thisActionLabelText
        thisMarkerWindow.addSubview(actionLabel)
        
        
        /*
        let thisExhibitionNameLabel:UILabel = UILabel(frame: CGRectMake(10, 170, thisScreenBounds.width-60, 20))
        thisExhibitionNameLabel.textAlignment = .Left
        thisExhibitionNameLabel.font = UIFont(name: "Apercu-Bold", size: 15)
        thisExhibitionNameLabel.text = responseElements[thisObject].venueName + ", " + responseElements[thisObject].venueStreet
        */
        
        
        let adressLabel = UILabel(frame: CGRect(x: 90, y: actionLabel.frame.maxY, width: thisScreenBounds.width-160, height: 40))
        adressLabel.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        adressLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        adressLabel.textAlignment = NSTextAlignment.left
        adressLabel.backgroundColor = UIColor.clear
        adressLabel.isUserInteractionEnabled = true
        adressLabel.numberOfLines = 2
        adressLabel.text = thisItem.venueName + ", " + thisItem.venueStreet
        
        thisMarkerWindow.addSubview(adressLabel)
        
        return thisMarkerWindow
        
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
    
    func callDetailViewOfItem(_ item: String) {
        thisSelectedID = item
        thisZoom = mapView.camera.zoom
        //print("CALL " + item)
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //FILTER
    func filterViewBy(_ sender: categoryListScrollView, targetCategory: Int) {
        if (targetCategory != 0) {
            categoryFilterActive = true
            thisTargetCategory = targetCategory
            filterContentForCategory(category: targetCategory)
            thisSelectedID = ""
        } else {
            categoryFilterActive = false
            mapView.clear()
            createTableView()
        }
    }
    
}

