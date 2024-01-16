//
//  categoryListScrollView.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 18/07/2017.
//  Copyright © 2017 Such Company LLC. All rights reserved.
//

import Foundation

class categoryListScrollView:UIScrollView {
    
    var thisCategoryList:[categoryData] = [categoryData]()
    var thisContentScrollView:UIScrollView = UIScrollView()
    let thisScreenBounds = UIScreen.main.bounds
    
    let elementWidth = 120

    weak var delegateCall: callFilter?
/*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    */
    func recieveTargetArray(targets: [categoryData]) {
        thisCategoryList = targets
        
    }
    @objc func layoutView() {
        //thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 30)
        self.backgroundColor = .white
        
        var thisWidth = 10
        
        let thisBreak = 10
        
        for i in 0 ..< thisCategoryList.count {
            
            let element = thisCategoryList[i]
            let actionLabel = UILabel(frame: CGRect(x: thisWidth, y: 0, width: elementWidth, height: 35))
            
            actionLabel.font = UIFont(name: "Apercu-Medium", size: 11)
            actionLabel.textAlignment = NSTextAlignment.center
            actionLabel.backgroundColor = UIColor.clear
            actionLabel.isUserInteractionEnabled = true
            actionLabel.numberOfLines = 2
            actionLabel.lineBreakMode = .byWordWrapping
            actionLabel.text = element.name.uppercased()
            actionLabel.textColor = UIColor.black
            actionLabel.tag = element.id
            

            
            let actionLabelTap = UITapGestureRecognizer(target: self, action: #selector(categoryListScrollView.selectedCategory))
            actionLabel.addGestureRecognizer(actionLabelTap)
            //actionLable.addGestureRecognizer(actionLabelTap)
            
            if element.name == "All" {
            let thisSelectedLayer = CALayer()
            thisSelectedLayer.borderColor = UIColor.black.cgColor
            thisSelectedLayer.borderWidth = 2
            thisSelectedLayer.frame = CGRect(x: 0, y: 33, width: elementWidth, height: 2)
            actionLabel.layer.addSublayer(thisSelectedLayer)
            }
            self.addSubview(actionLabel)
            
            thisWidth = thisWidth + elementWidth + thisBreak
        
        }
        
        //thisContentScrollView.contentSize = CGSize(width: thisWidth, height: 30)
        self.contentSize = CGSize(width: thisWidth, height: 30)
        //self.view.addSubview(thisContentScrollView)
    }
    
    func removeAllSelection() {
        for element in self.subviews {
            if (element.layer.sublayers != nil) {
                for thisLayer in element.layer.sublayers! {
                    thisLayer.removeFromSuperlayer()
                }
            }
        }
    }
    func selectCategoryBasedOnTarget(targetID:Int) {
        removeAllSelection()
        for element in self.subviews {
            if element.tag == targetID {
                let thisSelectedLayer = CALayer()
                thisSelectedLayer.borderColor = UIColor.black.cgColor
                thisSelectedLayer.borderWidth = 2
                thisSelectedLayer.frame = CGRect(x: 0, y: 33, width: elementWidth, height: 2)

                
                element.layer.addSublayer(thisSelectedLayer)
                
                self.scrollRectToVisible(element.frame, animated: true)
            }
        }
    }
    @objc func selectedCategory(sender:UITapGestureRecognizer) {
        
        let thisTargetIDInt = sender.view?.tag
            
            //thisCategoryList[(sender.view?.tag)!]
        removeAllSelection()
        
        
        let thisSelectedLayer = CALayer()
        thisSelectedLayer.borderColor = UIColor.black.cgColor
        thisSelectedLayer.borderWidth = 2
        thisSelectedLayer.frame = CGRect(x: 0, y: 33, width: elementWidth, height: 2)
        
        sender.view?.layer.addSublayer(thisSelectedLayer)
        
        delegateCall?.filterViewBy(self, targetCategory: thisTargetIDInt!)
    }
    
}
