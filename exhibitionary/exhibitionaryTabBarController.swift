//
//  exhibitionaryTabBarController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 15/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    init?(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
        
        let attributedOptions : [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let attributedString = try? NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)

        self.init(attributedString?.string ?? "")
       
    }
}

extension UITableViewCell {
    func returnAppDelegate() -> AppDelegate {
        let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return thisAppDelegate
    }
    
    func httpGet(_ request: URLRequest!, callback: @escaping (Data, String?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                callback(Data(), error!.localizedDescription)
            } else {
                callback(data!, nil)
            }
        })
        task.resume()
    }
    
}
extension UIViewController {
    
    func displayOKMessageError(_ thisMessage:String) {
        let failureMessage:UIAlertController = UIAlertController(title: "Error", message: thisMessage, preferredStyle: UIAlertController.Style.alert)
        failureMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {action -> Void in
            
            })
        self.present(failureMessage, animated: true, completion: nil)
    }
    
    func generateImage(_ desiredWidth:CGFloat, desiredHeight:CGFloat, sourceImage:UIImage) -> UIImage {
        
        let currentImageWidth = sourceImage.size.width
        let currentImageHeight = sourceImage.size.height
        var newDesiredWith = desiredWidth
        var newDesiredHeight = desiredHeight
        var imageratio:CGFloat = 1
        
        if (currentImageWidth >= currentImageHeight) {
            imageratio = currentImageWidth/currentImageHeight
            newDesiredWith = newDesiredHeight * imageratio
        } else {
            imageratio = currentImageHeight/currentImageWidth
            newDesiredHeight = newDesiredWith*imageratio
        }
        
        UIGraphicsBeginImageContext(CGSize(width: newDesiredWith, height: newDesiredHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newDesiredWith, height: newDesiredHeight))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: newDesiredWith, height: 440)
        UIGraphicsBeginImageContext(CGSize(width: newDesiredWith, height: newDesiredHeight));
        let imgRef:CGImage = newImage.cgImage!.cropping(to: rect)!
        let newCroppedImage:UIImage = UIImage(cgImage: imgRef)
        
        return newCroppedImage
    }
    
    func showUpperMenu() {
        /*
        let thisFrontSelector = citySelectorView()
        //self.navigationController?.addChildViewController(thisFrontSelector)
        self.addChildViewController(thisFrontSelector)
        
        do {
            let thisRevealController = self.view.window?.rootViewController as! SWRevealViewController
            print(thisRevealController.frontViewController)
            do {
                let thisTabBar = thisRevealController.frontViewController as! exhibitionaryTabBarController
                print(thisTabBar.tabBar.selectedItem?.title)
                if (thisTabBar.tabBar.selectedItem?.title == "Picks") {
                    let thisCurrentTopViewNavigationController = thisTabBar.selectedViewController as! UINavigationController
                    let thisCurrentTopView = thisCurrentTopViewNavigationController.topViewController as! feedViewController
                    thisCurrentTopView.acitvateSearch(targetDelegate: thisCurrentTopView)
                }
                
                if (thisTabBar.tabBar.selectedItem?.title == "Current") {
                    let thisCurrentTopViewNavigationController = thisTabBar.selectedViewController as! UINavigationController
                    let thisCurrentTopView = thisCurrentTopViewNavigationController.topViewController as! exhibitionViewController
                    thisCurrentTopView.acitvateSearch(targetDelegate: thisCurrentTopView)
                }
                
                if (thisTabBar.tabBar.selectedItem?.title == "Openings") {
                    let thisCurrentTopViewNavigationController = thisTabBar.selectedViewController as! UINavigationController
                    let thisCurrentTopView = thisCurrentTopViewNavigationController.topViewController as! openingsViewController
                    thisCurrentTopView.acitvateSearch(targetDelegate: thisCurrentTopView)
                }
                
                if (thisTabBar.tabBar.selectedItem?.title == "Map") {
                    let thisCurrentTopViewNavigationController = thisTabBar.selectedViewController as! UINavigationController
                    let thisCurrentTopView = thisCurrentTopViewNavigationController.topViewController as! locateViewController
                    thisCurrentTopView.acitvateSearch(targetDelegate: thisCurrentTopView)
                }
                
            } catch {
            
            }
            
        } catch {
        
        }
        */
    }
    
    
   
    
    func setUpHeader(_ MyTitle:String) {
        
        /*
        let headerLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        headerLogo.image = UIImage(named: "MenuLogo")
        */
        let workAroundImageView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        let thisSectionTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        thisSectionTitle.text = MyTitle
        thisSectionTitle.font = UIFont(name: "Apercu-Bold", size: 20)
        thisSectionTitle.textAlignment = NSTextAlignment.center
        workAroundImageView.addSubview(thisSectionTitle)
        
        self.navigationItem.titleView = workAroundImageView
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isOpaque = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Apercu-Bold", size: 20)!], for: UIControl.State())
        navigationItem.backBarButtonItem = backButton
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
    }
    
    func setUpMenuButton() {
        let revealController = self.revealViewController()
        revealController?.tapGestureRecognizer()
        
        let thisLoginCutsomView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        thisLoginCutsomView.backgroundColor = .white
        thisLoginCutsomView.layer.cornerRadius = 15
        thisLoginCutsomView.clipsToBounds = true
        
        let loginButtonImage = UIImage(named: "Login6666.png")
        let loginButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        loginButtonImageView.contentMode = .scaleAspectFill
        /*if (returnAppDelegate().thisProfileURL != "") {
            loginButtonImageView.sd_setImage(with: URL(string: returnAppDelegate().thisProfileURL))
        } else {
            loginButtonImageView.image = loginButtonImage
        }
        */
        loginButtonImageView.image = loginButtonImage
        thisLoginCutsomView.addSubview(loginButtonImageView)
        
        let thisLoginTap:UITapGestureRecognizer = UITapGestureRecognizer(target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        thisLoginCutsomView.addGestureRecognizer(thisLoginTap)
        
        let loginButtonItemWitImage = UIBarButtonItem(customView: thisLoginCutsomView)
        
        /*
        let loginButtonImageScaled = UIImage(cgImage: (loginButtonImage?.cgImage)!, scale: 3, orientation: UIImageOrientation.up)
        
        let revealButtonItemWithImage = UIBarButtonItem(image: loginButtonImageScaled, style: UIBarButtonItemStyle.plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        revealButtonItemWithImage.width = 66
        
        
            //   loginButtonImageScaled.sd_lo
        
        */
        self.revealViewController().rearViewRevealWidth = UIScreen.main.bounds.width
        
        self.revealViewController().rightViewRevealWidth = UIScreen.main.bounds.width
        self.revealViewController().rightViewRevealDisplacement = CGFloat(0)
        self.revealViewController().rightViewRevealOverdraw = CGFloat(0)
        
        let thisCityID = returnAppDelegate().thisCityID
        //print(thisCityID)
        
        //let settingsButtonImage = UIImage(named: "SettingsButton.png")
        //let settingsButtonImageScaled = UIImage(cgImage: (settingsButtonImage?.cgImage)!, scale: 3, orientation: UIImageOrientation.up)
        //let settingButtonItemWitImage = UIBarButtonItem(image: settingsButtonImageScaled, style: UIBarButtonItemStyle.plain, target: revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        
        let thisCustomView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        thisCustomView.backgroundColor = .black
        thisCustomView.layer.cornerRadius = 2
        let thisLable:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 30, height: 10))
        
        thisLable.textColor = .white
        thisLable.font = globalData.standardTextFont
        //thisLable.text = returnAppDelegate().thisCityAbbr
        
        thisLable.attributedText = NSAttributedString(string: returnAppDelegate().thisCityAbbr, attributes: [NSAttributedString.Key.kern: 1.2])
        thisCustomView.addSubview(thisLable)
        
        let thisTriangle = UIImage(named: "Triangle")
        let thisTriangleImageView = UIImageView(frame: CGRect(x: 38, y: 13, width: 5, height: 5))
        thisTriangleImageView.contentMode = .scaleAspectFit
        thisTriangleImageView.image = thisTriangle
        
        thisCustomView.addSubview(thisTriangleImageView)
        
        let thisTap:UITapGestureRecognizer = UITapGestureRecognizer(target: revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        thisCustomView.addGestureRecognizer(thisTap)
        
        let settingButtonItemWitImage = UIBarButtonItem(customView: thisCustomView)
        
        /*
        settingButtonItemWitImage.title =
        settingButtonItemWitImage.target = revealController
        settingButtonItemWitImage.action =
        settingButtonItemWitImage.tintColor = UIColor.white
         */
        
        //let settingButtonItemWitImage = UIBarButtonItem(title: String(thisCityID), style: .plain, target: revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        
        settingButtonItemWitImage.width = 66
       
        self.navigationItem.leftBarButtonItems = [loginButtonItemWitImage]
        self.navigationItem.rightBarButtonItems = [settingButtonItemWitImage] //searchButtonItemWitImage
    }
    /*
    func setUpMenuButtonWithShare() {
        let revealController = self.revealViewController()
        revealController?.tapGestureRecognizer()
        
        /*
         let thisAppDelegate = returnAppDelegate()
         let thisUserID = thisAppDelegate.sessionUserID
         var thisTitle = "LOGGED IN"
         
         if (thisUserID == "") {
         thisTitle = "LOGIN"
         }
         
         
         let loginButton = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
         loginButton.image = UIImage(named: "Login200200.png")
         let workAroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
         workAroundImageView.addSubview(loginButton)
         
         
         let revealButtonWithStrechedImage = UIBarButtonItem(customView: workAroundImageView)
         revealButtonWithStrechedImage.action = #selector(SWRevealViewController.revealToggle(_:))
         */
        //let revealButtonItem = UIBarButtonItem(title: thisTitle, style: UIBarButtonItemStyle.Plain, target: revealController, action: )
        //revealButtonItem.tintColor = UIColor.blackColor()
        
        let loginButtonImage = UIImage(named: "Login6666.png")
        let loginButtonImageScaled = UIImage(cgImage: (loginButtonImage?.cgImage)!, scale: 3, orientation: UIImageOrientation.up)
        
        let revealButtonItemWithImage = UIBarButtonItem(image: loginButtonImageScaled, style: UIBarButtonItemStyle.plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        revealButtonItemWithImage.width = 66
        
        self.revealViewController().rearViewRevealWidth = UIScreen.main.bounds.width
        
        self.revealViewController().rightViewRevealWidth = UIScreen.main.bounds.width
        self.revealViewController().rightViewRevealDisplacement = CGFloat(0)
        self.revealViewController().rightViewRevealOverdraw = CGFloat(0)
        
        let settingsButtonImage = UIImage(named: "SettingsButton.png")
        let settingsButtonImageScaled = UIImage(cgImage: (settingsButtonImage?.cgImage)!, scale: 3, orientation: UIImageOrientation.up)
        let settingButtonItemWitImage = UIBarButtonItem(image: settingsButtonImageScaled, style: UIBarButtonItemStyle.plain, target: revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        settingButtonItemWitImage.width = 66
        
        let shareButtonImage = UIImage(named: "ShareButton");
        let shareButtonImageScaled = UIImage(cgImage: (shareButtonImage?.cgImage)!, scale: 3, orientation: UIImageOrientation.up)
        //let shareButtonItemWitImage = UIBarButtonItem(image: shareButtonImageScaled, style: UIBarButtonItemStyle.plain, target: revealController, action: #selector(exhibitionaryTabBarController.shareMenu))
        
        /*
         let searchButtonImage = UIImage(named: "SearchButton.png")
         let searchButtonImageScaled = UIImage(cgImage: (searchButtonImage?.cgImage)!, scale: 3, orientation: UIImageOrientation.up)
         let searchButtonItemWitImage = UIBarButtonItem(image: searchButtonImageScaled, style: UIBarButtonItemStyle.plain, target: revealController, action: #selector(exhibitionaryTabBarController.showUpperMenu))
         searchButtonItemWitImage.width = 66
         */
        
        
        //self.navigationItem.rightBarButtonItem = settingButtonItemWitImage
        self.navigationItem.leftBarButtonItem = revealButtonItemWithImage
        //self.navigationItem.rightBarButtonItems = [settingButtonItemWitImage, shareButtonItemWitImage] //searchButtonItemWitImage
    }
    */
    /*
    func shareMenu() {
        do {
            let thisRevealController = self.view.window?.rootViewController as! SWRevealViewController
            print(thisRevealController.frontViewController)
            do {
                let thisTabBar = thisRevealController.frontViewController as! exhibitionaryTabBarController
                //print(thisTabBar.tabBar.selectedItem?.title)
                if (thisTabBar.tabBar.selectedItem?.title == "Current") {
                    let thisCurrentTopViewNavigationController = thisTabBar.selectedViewController as! UINavigationController
                    let thisCurrentTopView = thisCurrentTopViewNavigationController.topViewController as! exhibitionViewController
                    //thisCurrentTopView.acitvateSearch(targetDelegate: thisCurrentTopView)
                    thisCurrentTopView.transformToShare()
                }
            }
        }
    }
    */
    
    func setAndShowCitySelector() {
    
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor);
        context?.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    func imageWithColorAndSize(_ color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 55, width: size.width, height: size.height)
        let thisBig: CGSize = CGSize(width: size.width, height: 60)
        UIGraphicsBeginImageContextWithOptions(thisBig, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    
    func returnAppDelegate() -> AppDelegate {
        let thisAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return thisAppDelegate
    }
    
    func removeMenuButton() {
        
        //print(self.navigationItem.leftBarButtonItem)
    }
    
    func createLine(_ desiredWidth:CGFloat, desiredY:CGFloat)  -> CAShapeLayer {
        let border = CAShapeLayer()
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor =  UIColor.white.cgColor
        //UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1).CGColor
        border.lineWidth = 1.0
        border.lineJoin = CAShapeLayerLineJoin.round
        //border.lineDashPattern = [1,2]
        
        let path = CGMutablePath()
        //CGPathMoveToPoint(path, nil, 0, desiredY)
        path.move(to: CGPoint(x:0, y: desiredY))
        //CGPathAddLineToPoint(path, nil, desiredWidth, desiredY)
        path.addLine(to: CGPoint(x: desiredWidth, y: desiredY), transform: CGAffineTransform())
        border.path = path
        
        return border
        
        
    }
    
    func nullToNil(_ value : Any?) -> String? {
        if value is NSNull {
            return "-"
        } else {
            return value as? String
        }
    }
    
    func httpGet(_ request: URLRequest!, callback: @escaping (Data, String?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                callback(Data(), error!.localizedDescription)
            } else {
                callback(data!, nil)
            }
        })
        task.resume()
    }
    
    func setTrack(_ category: String, parameter: String) {
        var userID = "0"
        var thisSessionID = "0"
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        let sessionID = thisAppDelegate.sessionID
        if (thisUserID != "") {
            userID = thisUserID
            thisSessionID = sessionID
        }
        let thisUrl = globalData.globalUrl + "add_stat"
        let request = NSMutableURLRequest(url: URL(string: thisUrl)!)
        request.httpMethod = "POST"
        var postString = "session_id="+thisSessionID+"&"
        postString = postString + "user_id="+userID+"&"
        postString = postString + "category="+category+"&"
        postString = postString + "page_id="+parameter
    
        let requestBodyData = (postString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
        
        
        httpGet(request as! URLRequest){
            (data, error) -> Void in
            if error != nil {
                
            } else {
                //print(String(data: data, encoding: NSUTF8StringEncoding))
            }
        }
    }

}

struct globalData {
    
    
    //"http://54.229.72.229/exhibitionary/api/" 
    //"http://fileserver.istvanszilagyi.com/exhibitionary/api/"
    static let globalUrl = "http://localhost:8888/exhibitionary/api/"
    
    //"http://34.252.146.154/exhibitionary2/api/"
//    static let dbUrl = "http://dev.exhibitionary.com/api/"
    static let dbUrl = "http://localhost:8888/exhibitionary/api/"
    //"http://cms.eyeout.com/api_v2/apps/1/"
    static let labelStandardBackgroundColor = UIColor.white
    static let fontStandardColor = UIColor.black
    static let standardTextFont = UIFont(name: "Apercu-Regular", size: 12)
    static let standardHeadlineFont = UIFont(name: "Apercu-Bold", size: 24)
}

class exhibitionaryTabBarController: UITabBarController {
    @IBOutlet weak var thisTabBar: UITabBar!
    override func viewDidLoad() {
        //setUpHeader()
        super.viewDidLoad()
        thisTabBar.tintColor = UIColor.white
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        
        thisTabBar.selectionIndicatorImage = imageWithColorAndSize(UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 255), size: tabBarItemSize).resizableImage(withCapInsets: UIEdgeInsets.zero)
        
        tabBar.frame.size.width = self.view.frame.width + 4
        tabBar.frame.origin.x = -2

        
        //imageWithColor()
        
    }
}
