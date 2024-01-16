//
//  imageDetailViewer.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 24/04/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class imageDetailViewer: UIViewController, UIScrollViewDelegate {
    var thisTargetUrl = ""
    var thisTargetTitle = ""
    var thisTargetID = ""
    var thisIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var thisContentScrollView:UIScrollView = UIScrollView()
    var thisImageView:UIImageView = UIImageView()
    let thisScreenBounds = UIScreen.main.bounds
    let loadingLabel = UILabel()
    var titleLabel = UILabel()
    var thisLikeAmount = 0
    
    var thisUserID = ""
    var thisSessionID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        getImage()
    }
    
    func addIndicitaor() {
        thisIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        thisIndicator.center = self.view.center
        thisIndicator.startAnimating()
        self.view.addSubview(thisIndicator)
    }
    
    func removeIndicatior() {
        thisIndicator.removeFromSuperview()
    }
    
    
    func getImage() {
        addIndicitaor()
        thisContentScrollView.frame = CGRect(x: 0, y: 0, width: thisScreenBounds.width, height: thisScreenBounds.height-64)
        thisContentScrollView.clipsToBounds = true
        thisContentScrollView.isScrollEnabled  = true
        thisContentScrollView.delegate = self
        
        /*
        thisImageView.sd_setImageWithPreviousCachedImageWithURL(NSURL(string: thisTargetUrl), andPlaceholderImage: nil, options: [], progress: nil, completed: {image, error, imagecachetype, url in
            self.imageLoaded(url, thisImage: image, thisError: error)
        })
         */
        
        
        /*
        thisImageView.sd_setImage(with: URL(string: thisTargetUrl), completed: {(image, error, imagecachetype,url) in
            self.imageLoaded(url, thisImage: image, thisError: error)
        } as SDWebImageCompletionBlock!)
        */
    }
    
    func imageLoaded(_ url:URL, thisImage:UIImage?, thisError:NSError?) {
        if (thisImage != nil) {
            thisImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: thisImage!.size)
            thisContentScrollView.contentSize = thisImage!.size
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageDetailViewer.scrollViewDoubleTapped(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            doubleTapRecognizer.numberOfTouchesRequired = 1
            thisContentScrollView.addGestureRecognizer(doubleTapRecognizer)
            
            let scrollViewFrame = thisContentScrollView.frame
            let scaleWidth = scrollViewFrame.size.width / thisContentScrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / thisContentScrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight);
            thisContentScrollView.minimumZoomScale = minScale;
            
            thisContentScrollView.maximumZoomScale = 2.0
            thisContentScrollView.zoomScale = minScale;
            
            thisContentScrollView.addSubview(thisImageView)
            self.view.addSubview(thisContentScrollView)
            
            centerScrollViewContents()
        }
    }
    
    func centerScrollViewContents() {
        let boundsSize = thisContentScrollView.bounds.size
        var contentsFrame = thisImageView.frame
        
        if contentsFrame.size.width <= boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        thisImageView.frame = contentsFrame
    }
    
    @objc func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.location(in: thisImageView)
        
        // 2
        var newZoomScale = thisContentScrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, thisContentScrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = thisContentScrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h);
        
        // 4
        thisContentScrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return thisImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    
}
