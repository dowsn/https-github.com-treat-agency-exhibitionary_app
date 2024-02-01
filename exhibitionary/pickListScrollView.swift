//
//  pickListScrollView.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 23/11/2016.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

struct pickListData {
    var targetID:String
    var name:String
    var teaser_text:String
    var thumbnailUrl:String
    var order:String
    var city_id:String
}

class pickListScrollView:UIViewController {
    
    var thisCityID = ""
    var picksOverviewArray = [pickListData]()
    var thisContentScrollView:UIScrollView = UIScrollView()
    let thisScreenBounds = UIScreen.main.bounds
    //var thisParentView:feedViewController = feedViewController()
    var thisTargetPickID:String = ""
    
    weak var delegateCall: callPickListDetail?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getData() {
        let thisAppDelegate = returnAppDelegate()
        
        picksOverviewArray = [pickListData]()
    
        let thisFirstPicklist = pickListData(targetID: "0", name: "Editors", teaser_text: "Search for picks in this city.", thumbnailUrl: globalData.globalUrl + "items/frontend/images/Edit.jpg", order: "0", city_id: "0")
        picksOverviewArray.append(thisFirstPicklist)
        
        print("\(thisAppDelegate.sessionUserID)")
        let user_id = thisAppDelegate.sessionUserID != "" ? thisAppDelegate.sessionUserID : "0"
    
        let thisUrl = globalData.globalUrl + "getPickListsForCityID?city_id=" + String(returnAppDelegate().thisCityID) + "&user_id="+user_id
        
                
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "GET"
        
        //let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        //request.httpBody = requestBodyData
        
        httpGet(request as URLRequest){
            (data, error) -> Void in
            
            if error != nil {
                
            } else {
                //var jsonErrorOptional: NSError?
                //print(String(data: data, encoding: String.Encoding.utf8))
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
                                
                                if let eventsJson = response["listitems"] as? Array<AnyObject> {
                                    
                                    for i in 0 ..< eventsJson.count {
                                        //let thisString = eventsJson[i]["exhibition_id"] as! String
                                        let thisId = eventsJson[i]["id"] as! String
                                        let thisName = eventsJson[i]["name"] as! String
                                        let thisText = eventsJson[i]["name"] as! String
                                        let thisThumbnail = eventsJson[i]["thumbnail"] as! String
                                        let thisOrder = eventsJson[i]["order"] as! String
                                        let thisCityID = eventsJson[i]["city_id"] as! String
                                        let thispickListData = pickListData(targetID: thisId, name: thisName, teaser_text: thisText, thumbnailUrl: thisThumbnail, order: thisOrder, city_id: thisCityID)
                                        
                                        
                                        
                                        self.picksOverviewArray.append(thispickListData)
                                    }
                                    
                                    if(eventsJson.count > 0) {
                                        DispatchQueue.main.async {
                                            self.displayElements()
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.noData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func noData() {
        delegateCall?.noPickerData()
    }
    
    
    func displayElements () {
       
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 105)
        var thisWidth = 10
        let elementWidth = 65
        let thisBreak = 10
        
        for i in 0 ..< picksOverviewArray.count {
            
            
            let element = picksOverviewArray[i]
            
            let profileImage = UIImageView(frame: CGRect(x: thisWidth, y: 5, width: elementWidth, height: elementWidth))
            profileImage.contentMode = UIView.ContentMode.scaleAspectFill
            profileImage.layer.cornerRadius = profileImage.frame.size.width/2
            //profileImage.layer.borderWidth = 1
            //profileImage.layer.borderColor = UIColor.black.cgColor
            profileImage.clipsToBounds = true
            profileImage.isUserInteractionEnabled = true
            profileImage.sd_setImage(with: URL(string: element.thumbnailUrl))
            profileImage.tag = i
            
            
            let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(pickListScrollView.selectedPickList))
            profileImage.addGestureRecognizer(profileImageTap)
            
            thisContentScrollView.addSubview(profileImage)
            
            let actionLabel = UILabel(frame: CGRect(x: thisWidth, y: elementWidth, width: elementWidth, height: 40))
            actionLabel.textColor = UIColor.black
            actionLabel.font = UIFont(name: "Apercu-Bold", size: 10)
            actionLabel.textAlignment = NSTextAlignment.center
            actionLabel.backgroundColor = UIColor.clear
            actionLabel.isUserInteractionEnabled = true
            actionLabel.numberOfLines = 2
            actionLabel.lineBreakMode = .byWordWrapping
            actionLabel.text = element.name
            actionLabel.tag = i
            
            let actionLabelTap = UITapGestureRecognizer(target: self, action: #selector(pickListScrollView.selectedPickList))
            actionLabel.addGestureRecognizer(actionLabelTap)
            
            thisContentScrollView.addSubview(actionLabel)
            
            thisWidth = thisWidth + elementWidth + thisBreak
            
        }
        thisContentScrollView.contentSize = CGSize(width: thisWidth+65, height: 95)
        
        self.view.addSubview(thisContentScrollView)
        
        //delegateCall?.firstSetPickList(self, targetID: picksOverviewArray[0].targetID, listCount: picksOverviewArray.count)
        delegateCall?.firstSetPickList(self, targetID: picksOverviewArray[1].targetID, listCount: picksOverviewArray.count)
    }
    
    
    @objc func selectedPickList(sender:UITapGestureRecognizer) {
        let thisTargetIDInt = picksOverviewArray[sender.view?.tag as! Int].targetID
        //let thisTargetID:String = String(describing: thisTargetIDInt!)
        delegateCall?.callPickList(self, targetID: thisTargetIDInt)
    }
}
