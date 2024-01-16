//
//  feedListSwipeCellView.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 23/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class feedListSwipeCellView: UITableViewCell {
    var actionLabelText = ""
    var bkgFotoUrl = ""
    var dateLeftText = ""
    var addressText = ""
    
    var theseImages:Array<AnyObject> = Array()
    var thisID:Int = 0
    var parentNewsController:feedViewController = feedViewController()
    var ownIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    
    let thisScreenBounds = UIScreen.main.bounds
    
    var thisViewControllerSwipe:cellInternallPageViewController = cellInternallPageViewController(coder: NSCoder())!
    var thisPage = 0
    weak var thisDetailDelegate:callDetailViewOfItemProtocol?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thisViewControllerSwipe = cellInternallPageViewController(coder: NSCoder())!
        thisViewControllerSwipe.actionLabel = actionLabelText
        thisViewControllerSwipe.targetID = thisID
        thisViewControllerSwipe.dateLeftLabelText = dateLeftText
        thisViewControllerSwipe.adressLabelText = addressText
        thisViewControllerSwipe.ownIndexPath = ownIndexPath
        
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.contentView.addSubview(thisViewControllerSwipe.view)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(feedListSwipeCellView.handleLeftSwipes))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(feedListSwipeCellView.handleRightSwipes))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        self.addGestureRecognizer(leftSwipe)
        self.addGestureRecognizer(rightSwipe)

    }
    
    
    
    func thisIDTarget(_ targetNumber:Int, targetDelegate:callDetailViewOfItemProtocol) {
        thisID = targetNumber
        thisViewControllerSwipe.targetID = thisID
        thisViewControllerSwipe.delegateCall = targetDelegate
    }
    
    func thisSetImages(_ targetArray:Array<AnyObject>) {
        theseImages = targetArray
        //thisViewControllerSwipe.images = theseImages
        thisViewControllerSwipe.receivedImagesAndSetsPages(targetArray)
    }
    
    func childActionLabelText(_ text:String) {
        thisViewControllerSwipe.actionLabel = text
        thisViewControllerSwipe.setMyLabel(text)
    }
    func childDateLabelText(_ text:String) {
        thisViewControllerSwipe.dateLeftLabelText = text
        thisViewControllerSwipe.setMyDateLabel(text)
    }
    func setChildAddressText(_ text:String) {
        thisViewControllerSwipe.adressLabelText = text
        thisViewControllerSwipe.setMyAdressLabel(text)
    }
    
    func setIndexPath(_ path:IndexPath) {
        ownIndexPath = path
        
        thisViewControllerSwipe.ownIndexPath = path
    }

    
    @objc func handleRightSwipes() {
        
    }

    @objc func handleLeftSwipes() {
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}
