//
//  citySelectorCell.swift
//  Exhibitionary
//
//  Created by Istvan Szilagyi on 22/08/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class citySelectorCell: UITableViewCell {
    
    
    var nameLabel:UILabel = UILabel()
    var thisID:Int = 1
    var thisLon:String = ""
    var thisLat:String = ""
    var thisAbbr:String = ""
    var thisParentCityOverview:citySelectorView = citySelectorView()
    
    let thisScreenBounds = UIScreen.main.bounds
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.clipsToBounds = true
        
        nameLabel = UILabel(frame: CGRect(x: 40, y: 4, width: thisScreenBounds.width-40, height: 40))
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont(name: "Apercu-Bold", size: 15)
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.backgroundColor = UIColor.clear
        nameLabel.isUserInteractionEnabled = true
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.contentView.addSubview(nameLabel)
        
        self.isUserInteractionEnabled = true
        let thisTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(citySelectorCell.thisTapped))
        self.addGestureRecognizer(thisTapGestureRecognizer)
        
    }
    
    required init?(coder: NSCoder = NSCoder.empty()) {
        super.init(coder: coder)
    }
    
    @objc func thisTapped() {
        thisParentCityOverview.thisChangeCityTo(thisID, lon: thisLon, lat: thisLat, abbr: thisAbbr)
        
    }
}
