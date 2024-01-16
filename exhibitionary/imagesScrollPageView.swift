//
//  imagesScrollPageView.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 06/05/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

class imagesScrollPageView: UIViewController {

    var imageUrl:String = ""
    
    let thisScreenBounds = UIScreen.main.bounds
    var bkgImage:UIImageView = UIImageView()
    var pageIndex:Int = 0
    
    override func viewDidLoad() {
            super.viewDidLoad()
            self.view.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width/3, height: thisScreenBounds.width/3)
        
            self.view.clipsToBounds = true
        
        bkgImage.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width/3, height: thisScreenBounds.width/3)
        bkgImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.addSubview(bkgImage)
        
        
    }
}
