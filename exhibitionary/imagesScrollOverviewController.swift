//
//  imagesScrollOverviewController.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 06/05/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation

class imagesScrollOverviewController:UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let thisScreenBounds = UIScreen.main.bounds
    
    var images:Array<AnyObject> = []
    var targetID:Int = 0
    
    var pageViewController: UIPageViewController!
    var currentPageViewContentController = imagesScrollPageView()
    //target
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]?) {
        super.init(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: navigationOrientation, options: options)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        
    }
    
    func receivedImagesAndSetsPages(_ theseImages:Array<AnyObject>) {
        images = theseImages
        if(images.count > 0) {
            let pageContentViewController = self.viewControllerAtIndex(0) as! imagesScrollPageView
            
            currentPageViewContentController = pageContentViewController
            
            self.setViewControllers([pageContentViewController], direction:
                                        UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //print(self.images.count)
        let pageContentViewController = viewController as! imagesScrollPageView
        
        var index = pageContentViewController.pageIndex
        index = index + 1
        if(index >= self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let pageContentViewController = viewController as! imagesScrollPageView
        
        var index = pageContentViewController.pageIndex
        if(index <= 0){
            return nil
        }
        index = index - 1
        return self.viewControllerAtIndex(index)
    }
    
    
    func viewControllerAtIndex(_ index : Int) -> UIViewController? {
        
        if((self.images.count == 0) || (index >= self.images.count)) {
            return nil
        }
        let pageContentViewController = imagesScrollPageView()
        
        //pageContentViewController.setActionLabelText(actionLabel)
        
        var thisEventImageUrl:String =  ""
        
        if(images.count > 0) {
            //globalData.globalUrl +  images[index]["url"] as String!
            let thisImageUrl = images[index]["url"] as! String
            thisEventImageUrl = thisImageUrl
            
            pageContentViewController.bkgImage.sd_setImageWithPreviousCachedImage(with: URL(string: thisEventImageUrl), placeholderImage: UIImage(), options: [], progress: nil, completed: {image, error, imagecachetype, url in
                
            })
            
            pageContentViewController.pageIndex = index
        }
        
        
        
        return pageContentViewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return images.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
