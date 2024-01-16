//
//  pickListElementCell.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 26/04/2017.
//  Copyright © 2017 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class pickListElementCell:UICollectionViewCell {
    var profileImage:UIImageView = UIImageView()
    var actionLabel:UILabel = UILabel()
    var thisFollowers:UILabel = UILabel()
    var thisFollowButton:UIImageView = UIImageView()
    var plusLabel:UILabel = UILabel()
    var isFollowing:Bool = false
    var thisID = ""
    
    let thisScreenBounds = UIScreen.main.bounds
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true;
        
        let thisImageY = thisScreenBounds.width/4 - 35
        profileImage = UIImageView(frame: CGRect(x: thisImageY, y: 0, width: 70, height: 70))
        
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        
        self.contentView.addSubview(profileImage)
        
        plusLabel = UILabel(frame: CGRect(x: profileImage.frame.maxX-30, y: 60, width: 30, height: 30))
        plusLabel.layer.cornerRadius = 15
        plusLabel.layer.backgroundColor = UIColor.white.cgColor
        plusLabel.text = "+"
        plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.font = UIFont(name: "Apercu-Bold", size: 17)
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.backgroundColor = UIColor.clear
        plusLabel.isUserInteractionEnabled = true
        
        self.contentView.addSubview(plusLabel)
        
        actionLabel = UILabel(frame: CGRect(x: 0, y: 70, width: thisScreenBounds.width/2, height: 40))
        actionLabel.textColor = UIColor.black
        actionLabel.font = UIFont(name: "Apercu-Bold", size: 15)
        actionLabel.textAlignment = NSTextAlignment.center
        actionLabel.backgroundColor = UIColor.clear
        actionLabel.isUserInteractionEnabled = true
        actionLabel.numberOfLines = 2
        actionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        self.contentView.addSubview(actionLabel)
        
        thisFollowers = UILabel(frame: CGRect(x: 0, y: 70, width: thisScreenBounds.width/2, height: 40))
        thisFollowers.textColor = UIColor.black
        thisFollowers.font = UIFont(name: "Apercu-Bold", size: 12)
        thisFollowers.textAlignment = NSTextAlignment.center
        thisFollowers.backgroundColor = UIColor.clear
        thisFollowers.isUserInteractionEnabled = true
        thisFollowers.numberOfLines = 1
        thisFollowers.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        self.contentView.addSubview(thisFollowers)
    }
    
    func changeToMinus() {
        plusLabel.layer.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
        plusLabel.textColor = UIColor.white
        plusLabel.text = "-"
    }
    
    func changeToPlus() {
        plusLabel.layer.backgroundColor = UIColor.white.cgColor
        plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.text = "+"
    }
    
    
}
