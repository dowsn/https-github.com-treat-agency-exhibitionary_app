//
//  feedListTinyCell.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 01/04/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//


import Foundation
import UIKit

class feedListTinyCell: UITableViewCell {
    var actionLabel:UILabel = UILabel()
    var dateLabel:UILabel = UILabel()
    var bkgImage:UIImageView = UIImageView()
    var profileImage = UIImageView()
    var divider = UIView()
    var thisID:Int = 0
    var parentNewsController:openingsViewController = openingsViewController()
    var plusLabel:UILabel = UILabel()
    
    let thisScreenBounds = UIScreen.main.bounds
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.clipsToBounds = true
        
        actionLabel = UILabel(frame: CGRect(x: 10, y: 0, width: thisScreenBounds.width-45, height: 30))
        actionLabel.textColor = UIColor.black
        actionLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        actionLabel.textAlignment = NSTextAlignment.left
        actionLabel.backgroundColor = globalData.labelStandardBackgroundColor
        actionLabel.isUserInteractionEnabled = true
        actionLabel.numberOfLines = 2
        self.contentView.addSubview(actionLabel)
        
        let storyLineView = UIView(frame: CGRect(x: 0,y: 29, width: thisScreenBounds.width,height: 1))
        storyLineView.backgroundColor = UIColor.black
        
        self.contentView.addSubview(storyLineView)
        self.isUserInteractionEnabled = true
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(feedListTinyCell.imageTap))
        self.addGestureRecognizer(imageTap)
        
        plusLabel = UILabel(frame: CGRect(x: thisScreenBounds.width-30, y: 0, width: 30, height: 30))
        plusLabel.text = "+"
        plusLabel.textColor = UIColor.white
        plusLabel.font = UIFont(name: "Apercu-Regular", size: 14)
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.backgroundColor = UIColor(red: 55/255, green: 57/255, blue: 61/255, alpha: 1)
        plusLabel.isUserInteractionEnabled = true
        
        let pulsTap = UITapGestureRecognizer(target: self, action: #selector(feedListTinyCell.plusTapped))
        plusLabel.addGestureRecognizer(pulsTap)
        
        self.contentView.addSubview(plusLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func plusTapped() {
        //parentNewsController.addToFavorites(String(thisID), cell: self)
        //plusLabel.removeFromSuperview()
    }
    
    @objc func imageTap() {
        parentNewsController.callDetailViewOfItem(String(thisID), cellIndex: 0, sectionIndex: 0)
        //let thisParentViewController = self.pare
    }
    
    
}
