//
//  classicalImageScrollerView.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 06/05/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

class classicalImageScrollerView: UIViewController, UIGestureRecognizerDelegate {
    
    var images:Array<AnyObject> = []
    let thisScreenBounds = UIScreen.main.bounds
    var thisParentView:detailViewController = detailViewController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        if(images.count > 0) {
        
            var counter:Int = 0;
            var thisx:Int = 0
            for item in images {
                
                
                if (counter > 0) {
                    thisx = (counter * (Int(thisScreenBounds.width/3)+10))
                }
                
                
                let thisImageWindow = UIImageView()
                thisImageWindow.frame = CGRect(x: thisx, y: 0, width: Int(thisScreenBounds.width/3), height: Int(thisScreenBounds.width/3))
                thisImageWindow.contentMode = UIView.ContentMode.scaleAspectFill
                thisImageWindow.clipsToBounds = true
                thisImageWindow.sd_setImage(with: URL(string: item["url"] as! String))
                thisImageWindow.tag = counter
                counter = counter + 1
                thisImageWindow.isUserInteractionEnabled = true
                
                let thisButton = UIButton(frame:  CGRect(x: thisx, y: 0, width: Int(thisScreenBounds.width/3), height: Int(thisScreenBounds.width/3)))
                thisButton.backgroundColor = UIColor.black
                
                let thisImageTap = UITapGestureRecognizer(target: thisParentView, action: #selector(thisParentView.imageTap))
                
                //thisImageTap.delegate = self
                thisImageWindow.addGestureRecognizer(thisImageTap)
                
                self.view.addSubview(thisImageWindow)
                //self.view.addSubview(thisButton)
                
            }
        }
    }
    
    func imageTap() {
        print("TAP")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
