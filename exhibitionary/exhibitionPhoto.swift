//
//  exhibitionPhoto.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 04/07/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import NYTPhotoViewer

class exhibitionPhoto:NSObject, NYTPhoto {

    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])

    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    
    init(image: UIImage? = nil, imageData: Data? = nil, attributedCaptionTitle: NSAttributedString) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }
    
}
