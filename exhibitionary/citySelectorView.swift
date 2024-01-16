//
//  citySelectorView.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 22/08/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit


struct cityInfo {
    var id:Int
    var name:String
    var long:String
    var lat:String
    var abbr:String

}
class citySelectorView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var thisCityArray = [cityInfo]()
    var tableView = UITableView()
    let thisScreenBounds = UIScreen.main.bounds
    var thisGrey:Bool = true
    var thisY:CGFloat = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let thisNavigationController = UINavigationController(rootViewController: self)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isOpaque = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        let revealController = self.revealViewController()
        
        let revealButtonItemWithImage = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        revealButtonItemWithImage.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Apercu-Bold", size: 20)!], for: UIControl.State())
        
        self.navigationItem.leftBarButtonItem = revealButtonItemWithImage
        
        
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        getCityOverview()
        
        let welcomeTextLabel = UILabel(frame: CGRect(x: 20, y: 5, width: thisScreenBounds.width-40, height: 40))
        welcomeTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        welcomeTextLabel.numberOfLines = 10
        welcomeTextLabel.font = UIFont(name: "Apercu-Regular", size: 18)
        welcomeTextLabel.textColor = UIColor.black
        welcomeTextLabel.textAlignment = NSTextAlignment.left
        welcomeTextLabel.text = "Tap on a city to switch:";
        
        self.view.addSubview(welcomeTextLabel)
        
        thisY = welcomeTextLabel.frame.maxY+5
    }
    
    func getCityOverview (){
        let thisUrl = globalData.globalUrl + "getCities"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            self.thisCityArray = [cityInfo]()
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
                if let json = jsonOptional as? Array<AnyObject> {
                
                for item in json {
                    let thisCityElement:cityInfo = cityInfo(id: item["id"] as! Int, name: self.nullToNil(item["name"])!, long: self.nullToNil(item["long"])!, lat: self.nullToNil(item["lat"])!, abbr: self.nullToNil(item["short_name"])!)
                    self.thisCityArray.append(thisCityElement)
                }
                
                DispatchQueue.main.async {
                    self.createTableView()
                }
                }
            }
        }
    }
    
    func createTableView() {
        tableView = UITableView()
        
        
        let thisEndY = thisScreenBounds.height-64-thisY
        
        tableView.frame        =   CGRect(x: 0, y: thisY, width: thisScreenBounds.width, height: thisEndY)
        tableView.delegate     =   self
        tableView.dataSource   =   self
        tableView.register(citySelectorCell.self, forCellReuseIdentifier: "citySelectorCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.view.addSubview(tableView)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thisCityArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let thisHeight = CGFloat(45)
        return thisHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let thisElement = thisCityArray[(indexPath as NSIndexPath).row]
        
            let cell:citySelectorCell? = tableView.dequeueReusableCell(withIdentifier: "citySelectorCell", for: indexPath) as? citySelectorCell
        
            cell?.nameLabel.text = thisElement.name.uppercased()
            cell?.thisParentCityOverview = self
            cell?.thisID = thisElement.id
            cell?.thisLon = thisElement.long
            cell?.thisLat = thisElement.lat
            cell?.thisAbbr = thisElement.abbr
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
            if (thisGrey) {
                thisGrey = false
                cell!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 250)
            } else {
                thisGrey = true
                cell!.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 250)
            }
            return cell!
    }
    
    func thisChangeCityTo(_ id:Int, lon: String, lat: String, abbr: String) {
        
        let thisAppDelegate = returnAppDelegate()
        thisAppDelegate.thisCityID = id
        thisAppDelegate.thisCityLat = lat
        thisAppDelegate.thisCityLong = lon
        thisAppDelegate.thisCityAbbr = abbr
        
        UserDefaults.standard.set(id, forKey: "thisCityID")
        UserDefaults.standard.set(lat, forKey: "thisCityLat")
        UserDefaults.standard.set(lon, forKey: "thisCityLon")
        UserDefaults.standard.set(abbr, forKey: "abbr")
        
        setTrack("City", parameter: String(id))
        
        let revealController = self.revealViewController()
        revealController?.rightRevealToggle(self)
        
        let thisUITabBar = revealController?.frontViewController as! UITabBarController
        let thisNavigController = thisUITabBar.selectedViewController as! UINavigationController
        
        
        thisNavigController.topViewController?.setUpMenuButton()
        thisNavigController.topViewController?.viewWillAppear(true)
        
        
    }

}
