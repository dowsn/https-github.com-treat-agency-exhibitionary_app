//
//  cellInternallPageViewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 21/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

extension NSCoder {
  class func empty() -> NSCoder {
    let data = NSMutableData()
      let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.finishEncoding()
      return NSKeyedUnarchiver(forReadingWith: data as Data)
  }
}

class cellInternallPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let thisScreenBounds = UIScreen.main.bounds
    
    var images:Array<AnyObject> = []
    var actionLabel:String = ""
    var dateLeftLabelText:String = ""
    var targetID:Int = 0
    var adressLabelText:String = ""
    var ownIndexPath:IndexPath = IndexPath()
    
    var pageViewController: UIPageViewController!
    var currentPageViewContentController = pageViewControllerContentView()
    var targetDetailView = detailViewController()
    
    weak var delegateCall: callDetailViewOfItemProtocol?
    
    init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [String : Any]?) {
        
        
        super.init(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: navigationOrientation, options: [UIPageViewController.OptionsKey.interPageSpacing: 0])
    }
    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder = NSCoder.empty()) {
//        super.init(coder: coder)
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getDetailForElement() {
        delegateCall?.callDetailViewOfItem(self, item: String(targetID), indexPath: ownIndexPath)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    func receivedImagesAndSetsPages(_ theseImages:Array<AnyObject>) {
        images = theseImages
       
        if(images.count > 0) {
            
            let pageContentViewController = self.viewControllerAtIndex(0) as! pageViewControllerContentView
            pageContentViewController.overLaytext = actionLabel
            pageContentViewController.thisDaysLeftText = dateLeftLabelText
            pageContentViewController.adressText = adressLabelText
            pageContentViewController.totalIndex = self.images.count
            
            pageContentViewController.view.clipsToBounds = true
                
                
            currentPageViewContentController = pageContentViewController
            
            self.setViewControllers([pageContentViewController], direction:
                                        UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
    }
    
    func setMyLabel(_ text:String) {
        actionLabel = text
        currentPageViewContentController.setActionLabelText(actionLabel)
    }
    func setMyDateLabel(_ text:String) {
        dateLeftLabelText = text
    }
    func setMyAdressLabel(_ text:String) {
        adressLabelText = text
        currentPageViewContentController.setAddressLabelText(text)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let pageContentViewController = viewController as! pageViewControllerContentView
        pageContentViewController.setActionLabelText(actionLabel)
        pageContentViewController.totalIndex = images.count
        
        var index = pageContentViewController.pageIndex
        index = index + 1
        if(index >= self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
    
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let pageContentViewController = viewController as! pageViewControllerContentView
        
        pageContentViewController.totalIndex = images.count
        
        var index = pageContentViewController.pageIndex
        
        index = index - 1
        
        if(index <= 1) {
            
            pageContentViewController.setActionLabelText(actionLabel)
            pageContentViewController.setAddressLabelText(adressLabelText)
            pageContentViewController.setDateLeftLabel(dateLeftLabelText)
        }
        
        
        if(index < 0){
            pageContentViewController.setActionLabelText(actionLabel)
            pageContentViewController.setAddressLabelText(adressLabelText)
            pageContentViewController.setDateLeftLabel(dateLeftLabelText)
            return nil
        }
        
        
        return self.viewControllerAtIndex(index)
        
    }
    
    
    func viewControllerAtIndex(_ index : Int) -> UIViewController? {
        if((self.images.count == 0) || (index >= self.images.count)) {
            return nil
        }
        let pageContentViewController = pageViewControllerContentView()
        pageContentViewController.totalIndex = self.images.count
        
        
        var thisEventImageUrl:String =  ""

        if(images.count > 0) {
            //globalData.globalUrl +  images[index]["url"] as String!
        let thisImageUrl = images[index]["url"] as! String
        thisEventImageUrl = thisImageUrl
        
        pageContentViewController.bkgImage.sd_setImageWithPreviousCachedImage(with: URL(string: thisEventImageUrl), placeholderImage: UIImage(), options: [], progress: nil, completed: {image, error, imagecachetype, url in
                
            })
            
            pageContentViewController.pageIndex = index
        }
        pageContentViewController.overLaytext = actionLabel
        pageContentViewController.thisDaysLeftText = dateLeftLabelText
        pageContentViewController.adressText = adressLabelText
        
        
        return pageContentViewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return images.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
