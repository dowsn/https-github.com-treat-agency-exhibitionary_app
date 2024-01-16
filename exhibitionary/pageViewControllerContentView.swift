//
//  pageViewControllerContentView.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 23/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class pageViewControllerContentView: UIViewController {
    
    var backGroundImageURL:String = ""
    var overLaytext:String = ""
    var titleText:String = ""
    var thisID:Int = 0
    var pageIndex:Int = 0
    var totalIndex:Int = 0
    var thisDaysLeftText:String = ""
    var adressText:String = ""
    
    var thisScreenBounds = UIScreen.main.bounds
    var bkgImage:UIImageView = UIImageView()
    var actionLabel:UILabel = UILabel()
    var imageDarkener:UIView = UIView()
    var titleLabel:UILabel = UILabel()
    var dateLabel:UILabel = UILabel()
    var addressLabel:UILabel = UILabel()
    var pagination:UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.view.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 350)
        self.view.clipsToBounds = true
        
        bkgImage.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 350)
        bkgImage.contentMode = UIView.ContentMode.scaleAspectFill
        bkgImage.clipsToBounds = true
        self.view.addSubview(bkgImage)
        self.automaticallyAdjustsScrollViewInsets = false
        //+55
        imageDarkener.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: 350)
        imageDarkener.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
        //imageDarkener.hidden = true
        
        actionLabel = UILabel(frame: CGRect(x: 10, y: 150, width: thisScreenBounds.width-20, height: 60))
        actionLabel.textColor = UIColor.white
        actionLabel.font = UIFont(name: "Apercu-Bold", size: 24)
        actionLabel.numberOfLines = 2
        actionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        actionLabel.textAlignment = NSTextAlignment.center
        actionLabel.clipsToBounds = false
        
        //actionLabel.backgroundColor = globalData.labelStandardBackgroundColor
        actionLabel.isUserInteractionEnabled = false
        actionLabel.text = overLaytext// + String(pageIndex)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: actionLabel.frame.maxY+10, width: thisScreenBounds.width, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.font = UIFont(name: "Apercu-Regular", size: 16)
        titleLabel.textAlignment = NSTextAlignment.center
        //actionLabel.backgroundColor = globalData.labelStandardBackgroundColor
        titleLabel.isUserInteractionEnabled = false
        titleLabel.text = titleText
        
        
        dateLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 200, height: 40))
        dateLabel.textColor = UIColor.white
        dateLabel.font = UIFont(name: "Apercu-Bold", size: 16)
        if (thisDaysLeftText != "") {
            dateLabel.text = thisDaysLeftText
        }
        /*
        pagination = UILabel(frame: CGRectMake(thisScreenBounds.width-220, 20, 200, 40))
        pagination.textColor = UIColor.whiteColor()
        pagination.font = UIFont(name: "Apercu-Bold", size: 16)
        pagination.text = String(pageIndex) + " / " + String(totalIndex)
        pagination.textAlignment = NSTextAlignment.Right
        */
        
        
        addressLabel = UILabel(frame: CGRect(x: 10, y: 310, width: thisScreenBounds.width-20, height: 40))
        addressLabel.textColor = UIColor.white
        addressLabel.font = UIFont(name: "Apercu-Bold", size: 14)
        addressLabel.text = adressText
        
        if (pageIndex == 0) {
            self.view.addSubview(imageDarkener)
            self.view.addSubview(actionLabel)
            self.view.addSubview(titleLabel)
            
            self.view.addSubview(dateLabel)
            self.view.addSubview(addressLabel)
        }
        
        
        if (totalIndex > 1) {
        for counter in 1 ... totalIndex {
            
            
            //2 Space, 10 width
            //let totalWidth = totalIndex * 12
            var thisX = CGFloat(((totalIndex-counter) * 10) + 5)
            thisX = thisScreenBounds.width - 10 - thisX

            let circlePath = UIBezierPath(arcCenter: CGPoint(x: thisX, y: 41), radius: CGFloat(3), startAngle: CGFloat(0), endAngle: CGFloat(M_PI*2), clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            
            if (counter == self.pageIndex+1) {
                shapeLayer.fillColor = UIColor.white.cgColor
            } else {
                shapeLayer.fillColor = UIColor.clear.cgColor
            }
            
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 1.2
            
            view.layer.addSublayer(shapeLayer)
            
            /*
            let thisCircle = UIImage(named: "Circle_Empty")
            let thisImageView = UIImageView(frame: CGRectMake(thisX, 20, 10, 10))
            thisImageView.contentMode = .ScaleAspectFill
            thisImageView.image = thisCircle
            
            self.view.addSubview(thisImageView)
            */
            
        }
        }
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(pageViewControllerContentView.imageTap))
        self.view.addGestureRecognizer(imageTap)
        self.view.isUserInteractionEnabled = true
    }
    
    func setActionLabelText(_ text:String) {
        actionLabel.text = text
    }
    
    func setAddressLabelText(_ text:String) {
        addressLabel.text = text
    }
    
    func setDateLeftLabel(_ text:String) {
        dateLabel.text = text
    }
    
    @objc func imageTap() {
        let parentNewsController = self.parent as! cellInternallPageViewController
        parentNewsController.getDetailForElement()
    }
}
