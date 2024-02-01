//
//  editorsOverview.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 23/08/2017.
//  Copyright © 2017 Such Company LLC. All rights reserved.
//

import Foundation

class editorsOverview: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let thisScreenBounds = UIScreen.main.bounds
    
    var pickListResponseElements = [pickListElement]()
    
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
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    
        let appearance = UITabBarItem.appearance()
        let thisFont = UIFont(name: "Apercu-Regular", size: 12)
        appearance.setTitleTextAttributes([NSAttributedString.Key.font: thisFont!], for: UIControl.State())
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTrack("Editors", parameter: "")
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getData() {
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "get_userlists_for_city"
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        if (thisAppDelegate.sessionUserID != "") {
            var postString = "loggedin_user_id="+thisAppDelegate.sessionUserID
            postString = postString + "&city_id=" + String(returnAppDelegate().thisCityID)
            
            let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
            request.httpBody = requestBodyData
            
            
            httpGet(request as! URLRequest){
                (data, error) -> Void in
                
                if error != nil {
                    
                } else {
                    print(String(data: data, encoding: String.Encoding.utf8))
                    
                    let jsonOptional: Any!
                    do {
                        jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    } catch _ as NSError {
                        //jsonErrorOptional = error
                        jsonOptional = nil
                    }
                    
                    if let json = jsonOptional as? Dictionary<String, AnyObject> {
                        
                        if let response = json["pick_lists"] as? Array<AnyObject> {
                            
                            for i in 0 ..< response.count {
                                
                                let thisID = self.nullToNil(response[i]["list_id"]! as! String)!
                                let thisFirstName = self.nullToNil(response[i]["firstname"]! as! String)!
                                let thisLastName = self.nullToNil(response[i]["lastname"]! as! String)!
                                
                                let thisImageURL = self.nullToNil(response[i]["image"]! as! String)!
                                let thisDescription = self.nullToNil(response[i]["description"]! as! String)!
                                let thisActiveCities = self.nullToNil(response[i]["city"]! as! String)!
                                
                                var thisIsFollowing:Bool = false
                                if (response[i]["followed"]! as! Bool == true) {
                                    thisIsFollowing = true
                                }
                                
                                let thisElement = pickListElement(listID: thisID, firstName: thisFirstName, lastName: thisLastName, imageUrl: thisImageURL, followed: thisIsFollowing, description: thisDescription, activeCities: thisActiveCities)
                                self.pickListResponseElements.append(thisElement)
                            }
                            if (self.pickListResponseElements.count == 0) {
                                DispatchQueue.main.async {
                                    self.noData()
                                }
                            
                            } else {
                                DispatchQueue.main.async {
                                    self.displayPickLists()
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.noData()
                            }
                        }
                    }
                }
            }
            
        } else {
            let thisMessage = "Want to see and subscribe to pick lists? No problem just log in!"
            let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
            failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
                
                
            })
            self.present(failureMessage, animated: true, completion: nil)
            
            return
        }
    }
    
    func noData() {
        
        let thisMessage = "Looks like there is no list to follow in this city. Why don't you start with your pick list?"
        let failureMessage:UIAlertController = UIAlertController(title: "", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        self.present(failureMessage, animated: true, completion: nil)
    }
    func displayPickLists() {
        tableView = UITableView()
        let thisY = CGFloat.init(0)
        let thisEndY = thisScreenBounds.height-64-thisY-50
        
        tableView.alpha = 0
        tableView.frame        =   CGRect(x: 0, y: thisY, width: thisScreenBounds.width, height: thisEndY)
        tableView.delegate     =   self
        tableView.dataSource   =   self
        tableView.register(editorsListCell.self, forCellReuseIdentifier: "editorsListCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.allowsMultipleSelectionDuringEditing = true
        
        self.view.addSubview(tableView)
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.tableView.alpha = 1
        }, completion: {
            (value: Bool) in
            
        })
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return pickListResponseElements.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisElement:pickListElement = pickListResponseElements[(indexPath as NSIndexPath).row]
        
        let cell:editorsListCell? = tableView.dequeueReusableCell(withIdentifier: "editorsListCell", for: indexPath) as? editorsListCell
        
        cell!.parentNewsController = self
        cell!.loadImageInto(thisElement.imageUrl)
        
        cell!.profileImageURL = thisElement.imageUrl
        cell!.thisID = thisElement.listID
        
        cell!.actionLabel.text = thisElement.firstName + " " + thisElement.lastName
        cell!.adressLabel.text = thisElement.description
        cell!.citiesLabel.text = thisElement.activeCities
        
        cell!.myIndex = (indexPath as NSIndexPath).row
        
        if (thisElement.followed) {
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
    
    func removeFavorite(_ item: String, cell: editorsListCell) {
        
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "unfollow_picklist"
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        var postString = "user_id="+thisAppDelegate.sessionUserID
        postString = postString + "&list_id="+item
        postString = postString + "&city_id="+String(thisAppDelegate.thisCityID)
        postString = postString + "&session_id=" + String(returnAppDelegate().sessionID)
        
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            
            if error != nil {
                
            } else {
                DispatchQueue.main.async {
                    cell.removalDone()
                }
                //print(String(data: data, encoding: String.Encoding.utf8))
            }
        }
    }
    func addToFavorites(_ item: String, cell: editorsListCell) {
        let thisAppDelegate = returnAppDelegate()
        let thisUrl = globalData.dbUrl + "follow_picklist"
        
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        
        var postString = "user_id="+thisAppDelegate.sessionUserID
        postString = postString + "&list_id="+item
        postString = postString + "&city_id="+String(thisAppDelegate.thisCityID)
        postString = postString + "&session_id=" + String(returnAppDelegate().sessionID)
        
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            
            if error != nil {
                
            } else {
                DispatchQueue.main.async {
                    cell.additionDone()
                }
                print(String(data: data, encoding: String.Encoding.utf8))
                
            }
        }
    }
    
    func callDetailViewOfItem(_ item: String, cellIndex: Int) {
    
        thisSelectedID = item
        thisActualCellIndex = cellIndex
    //    self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
}
