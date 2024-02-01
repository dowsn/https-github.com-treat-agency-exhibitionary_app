//
//  feedListCell.swift
//  performancenation
//
//  Created by Istvan Szilagyi on 08/02/16.
//  Copyright © 2016 such company. All rights reserved.
//

import Foundation
import UIKit

class feedListCell: UITableViewCell {
    var actionLabel:UILabel = UILabel()
    var dateLabel:UILabel = UILabel()
    var bkgImage:UIImageView = UIImageView()
    var profileImage = UIImageView()
    var divider = UIView()
    var thisID:String = ""
    var parentNewsController:feedViewController = feedViewController()
    
    let thisScreenBounds = UIScreen.main.bounds
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.clipsToBounds = true
        
        bkgImage.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 250)
        bkgImage.contentMode = UIView.ContentMode.scaleAspectFill
        bkgImage.clipsToBounds = true
        self.contentView.addSubview(bkgImage)
        
        actionLabel = UILabel(frame: CGRect(x: 0, y: 220, width: thisScreenBounds.width, height: 30))
        actionLabel.textColor = globalData.fontStandardColor
        actionLabel.font = globalData.standardHeadlineFont
        actionLabel.textAlignment = NSTextAlignment.center
        actionLabel.backgroundColor = globalData.labelStandardBackgroundColor
        actionLabel.isUserInteractionEnabled = false
        self.contentView.addSubview(actionLabel)
        
        /*
        profileImage.frame = CGRectMake(5, 5, 42, 42)
        profileImage.contentMode = UIViewContentMode.ScaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.clipsToBounds = true
        
        profileImage.userInteractionEnabled = true
        */

        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(feedListCell.imageTap))
        bkgImage.addGestureRecognizer(imageTap)
        bkgImage.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    }
    
    @objc func imageTap() {
        print("tapped")
        //parentNewsController.getDetailForElement(thisID)
    }
    
    
}
