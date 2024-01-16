//
//  exhibitionFeedListCell.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 06/04/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class exhibitionFeedListCell: UITableViewCell {
    var actionLabel:UILabel = UILabel()
    var adressLabel:UILabel = UILabel()
    var plusLabel:UILabel = UILabel()
    var dateLabel:UILabel = UILabel()
    var bkgImage:UIImageView = UIImageView()
    var profileImage = UIImageView()
    var profileImageURL:String = ""
    var divider = UIView()
    var thisID:Int = 0
    var parentNewsController:exhibitionViewController = exhibitionViewController()
    var isFav:Bool = false
    var myIndex:Int = 0
    
    let thisScreenBounds = UIScreen.main.bounds
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.clipsToBounds = true
        
        profileImage = UIImageView(frame: CGRect(x: 15, y: 15, width: 70, height: 70))
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 0
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        
        self.contentView.addSubview(profileImage)
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionFeedListCell.imageTap))
        profileImage.addGestureRecognizer(profileImageTap)
        
        actionLabel = UILabel(frame: CGRect(x: 120, y: 10, width: thisScreenBounds.width-140, height: 40))
        actionLabel.textColor = UIColor.black
        actionLabel.font = UIFont(name: "Apercu-Bold", size: 15)
        actionLabel.textAlignment = NSTextAlignment.left
        actionLabel.backgroundColor = UIColor.clear
        actionLabel.isUserInteractionEnabled = true
        actionLabel.numberOfLines = 2
        actionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.contentView.addSubview(actionLabel)
        /*
        let pinImage:UIImageView = UIImageView(frame: CGRectMake(120, actionLabel.frame.maxY+5, 10, 10))
        pinImage.image = UIImage(named: "locate_48x48_Mini")
        pinImage.contentMode = .ScaleAspectFill
        self.contentView.addSubview(pinImage)
        */
        //adressLabel = UILabel(frame: CGRectMake(135, actionLabel.frame.maxY, thisScreenBounds.width-150, 20))
        adressLabel = UILabel(frame: CGRect(x: 120, y: actionLabel.frame.maxY, width: thisScreenBounds.width-150, height: 40))
        adressLabel.textColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 250)
        adressLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        adressLabel.textAlignment = NSTextAlignment.left
        adressLabel.backgroundColor = UIColor.clear
        adressLabel.isUserInteractionEnabled = true
        adressLabel.numberOfLines = 2
        adressLabel.lineBreakMode = .byWordWrapping
        
        self.contentView.addSubview(adressLabel)
        
        let addressLableTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionFeedListCell.imageTap))
        adressLabel.addGestureRecognizer(addressLableTap)
        
        /*
        let storyLineView = UIView(frame: CGRect(x: 0,y: 29, width: thisScreenBounds.width,height: 1))
        storyLineView.backgroundColor = UIColor.blackColor()
        
        self.contentView.addSubview(storyLineView)
        */
 
        self.isUserInteractionEnabled = true
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionFeedListCell.imageTap))
        actionLabel.addGestureRecognizer(imageTap)
        
        plusLabel = UILabel(frame: CGRect(x: 60, y: 60, width: 30, height: 30))
        plusLabel.layer.cornerRadius = 15
        plusLabel.layer.backgroundColor = UIColor.white.cgColor
        plusLabel.text = "+"
        plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.font = UIFont(name: "Apercu-Bold", size: 17)
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.backgroundColor = UIColor.clear
        plusLabel.isUserInteractionEnabled = true
        
        let pulsTap = UITapGestureRecognizer(target: self, action: #selector(exhibitionFeedListCell.plusTapped))
        plusLabel.addGestureRecognizer(pulsTap)
        
        self.contentView.addSubview(plusLabel)
        
    }
    
    func loadImageInto(_ thisURL:String) {
        profileImage.sd_setImage(with: URL(string: thisURL))
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func plusTapped() {
        let thisAppDelegate = returnAppDelegate()
        let thisUserID = thisAppDelegate.sessionUserID
        if (thisUserID != "") {
            if (isFav) {
                    parentNewsController.removeFavorite(String(thisID), cell: self)
                    plusLabel.layer.backgroundColor = UIColor.white.cgColor
                    plusLabel.textColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
                    plusLabel.text = "..."
                    plusLabel.isUserInteractionEnabled = false
                    isFav = false
            } else {
                    parentNewsController.addToFavorites(String(thisID), cell: self)
                    plusLabel.layer.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1).cgColor
                    plusLabel.textColor = UIColor.white
                    plusLabel.text = "..."
                    plusLabel.isUserInteractionEnabled = false
                    isFav = true
                }
        } else {
            parentNewsController.addToFavorites(String(thisID), cell: self)
        }
    }
   
    func additionDone() {
        plusLabel.text = "-"
        plusLabel.isUserInteractionEnabled = true
    }
    
    func removalDone() {
        plusLabel.text = "+"
        plusLabel.isUserInteractionEnabled = true
    }
    
    @objc func imageTap() {
        parentNewsController.callDetailViewOfItem(String(thisID), cellIndex: myIndex)
        //let thisParentViewController = self.pare
    }
    
    
}