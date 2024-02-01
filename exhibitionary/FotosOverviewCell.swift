//
//  FotosOverviewCell.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 17/04/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

class FotosOverViewCell: UICollectionViewCell {
    var albumNameLabel:UILabel = UILabel()
    var image:UIImageView = UIImageView()
    var thisFotoUrl = ""
    let thisScreenBound = UIScreen.main.bounds
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true;
        
        image = UIImageView(frame: CGRect(x: 0, y: 0, width: thisScreenBound.width/4-5, height: thisScreenBound.width/4-5))
        image.contentMode = .scaleAspectFill
        self.contentView.addSubview(image)
        /*
        albumNameLabel = UILabel(frame: CGRectMake(5, 225, thisScreenBound.width/2-5, 20))
        albumNameLabel.textColor = UIColor.whiteColor()
        albumNameLabel.font = UIFont(name: "Apercu-Regular", size: 8)
        albumNameLabel.textAlignment = NSTextAlignment.Center
        albumNameLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.contentView.addSubview(albumNameLabel)
         */
        
    }
}
