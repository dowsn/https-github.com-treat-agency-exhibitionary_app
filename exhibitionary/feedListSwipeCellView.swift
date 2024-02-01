//
//  feedListSwipeCellView.swift
//  exhibitionary
//
//  Created by Istvan Szilagyi on 23/03/16.
//  Copyright © 2016 Such Company LLC. All rights reserved.
//

import Foundation
import UIKit

class feedListSwipeCellView: UITableViewCell {
    weak var thisDetailDelegate: callDetailViewOfItemProtocol?

    var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .yellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var addressText = "" {
        didSet {
            print("addressText: \(addressText)")
            addressLabel.text = "Info -> Coronavirus (Covid-19), Mitte addressText: Info -> Coronavirus (Covid-19), Mitte Kraupa-Tuskany Zeidler, Kreuzberg addressText: Kraupa-Tuskany Zeidler, Kreuzberg"
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Add the label to the cell's content view
        self.contentView.addSubview(addressLabel)

        // Set up constraints for the label
//        NSLayoutConstraint.activate([
//            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
//            addressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//            addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
//        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChildAddressText(_ text: String) {
        addressText = text
    }
}

//class feedListSwipeCellView: UITableViewCell {
//    var actionLabelText = ""
//    var bkgFotoUrl = ""
//    var dateLeftText = ""
//    var addressText = ""
//
//    var theseImages: [AnyObject] = []
//    var thisID: Int = 0
//    var parentNewsController: feedViewController = feedViewController()
//    var ownIndexPath: IndexPath = IndexPath(row: 0, section: 0)
//
//    let thisScreenBounds = UIScreen.main.bounds
//
//    weak var thisDetailDelegate: callDetailViewOfItemProtocol?
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        self.clipsToBounds = true
//        self.isUserInteractionEnabled = true
//
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(feedListSwipeCellView.handleLeftSwipes))
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(feedListSwipeCellView.handleRightSwipes))
//
//        leftSwipe.direction = .left
//        rightSwipe.direction = .right
//
//        self.addGestureRecognizer(leftSwipe)
//        self.addGestureRecognizer(rightSwipe)
//    }
//
//    func thisIDTarget(_ targetNumber: Int, targetDelegate: callDetailViewOfItemProtocol) {
//        thisID = targetNumber
//    }
//
//    func thisSetImages(_ targetArray: [AnyObject]) {
//        theseImages = targetArray
//    }
//
//    func childActionLabelText(_ text: String) {
//        actionLabelText = text
//    }
//
//    func childDateLabelText(_ text: String) {
//        dateLeftText = text
//    }
//
//    func setChildAddressText(_ text: String) {
//        addressText = text
//    }
//
//    func setIndexPath(_ path: IndexPath) {
//        ownIndexPath = path
//    }
//
//    @objc func handleRightSwipes() {
//        // Implement your logic here
//    }
//
//    @objc func handleLeftSwipes() {
//        // Implement your logic here
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//}
//
//class feedListSwipeCellView: UITableViewCell {
//    var actionLabelText = ""
//    var bkgFotoUrl = ""
//    var dateLeftText = ""
//    var addressText = ""
//
//    var theseImages:Array<AnyObject> = Array()
//    var thisID:Int = 0
//    var parentNewsController:feedViewController = feedViewController()
//    var ownIndexPath:IndexPath = IndexPath(row: 0, section: 0)
//
//    let thisScreenBounds = UIScreen.main.bounds
//
//    var thisViewControllerSwipe:cellInternallPageViewController = cellInternallPageViewController(coder: NSCoder())! // herecoder
//
//    var thisPage = 0
//    weak var thisDetailDelegate:callDetailViewOfItemProtocol?
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        thisViewControllerSwipe = cellInternallPageViewController(coder: NSCoder())! // herecoder
//        thisViewControllerSwipe.actionLabel = actionLabelText
//        thisViewControllerSwipe.targetID = thisID
//        thisViewControllerSwipe.dateLeftLabelText = dateLeftText
//        thisViewControllerSwipe.adressLabelText = addressText
//        thisViewControllerSwipe.ownIndexPath = ownIndexPath
//
//        self.clipsToBounds = true
//        self.isUserInteractionEnabled = true
//        self.contentView.addSubview(thisViewControllerSwipe.view)
//
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(feedListSwipeCellView.handleLeftSwipes))
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(feedListSwipeCellView.handleRightSwipes))
//
//        leftSwipe.direction = .left
//        rightSwipe.direction = .right
//
//        self.addGestureRecognizer(leftSwipe)
//        self.addGestureRecognizer(rightSwipe)
//
//    }
//
//
//
//    func thisIDTarget(_ targetNumber:Int, targetDelegate:callDetailViewOfItemProtocol) {
//        thisID = targetNumber
//        thisViewControllerSwipe.targetID = thisID
//        thisViewControllerSwipe.delegateCall = targetDelegate
//    }
//
//    func thisSetImages(_ targetArray:Array<AnyObject>) {
//        theseImages = targetArray
//        //thisViewControllerSwipe.images = theseImages
//        thisViewControllerSwipe.receivedImagesAndSetsPages(targetArray)
//    }
//
//    func childActionLabelText(_ text:String) {
//        thisViewControllerSwipe.actionLabel = text
//        thisViewControllerSwipe.setMyLabel(text)
//    }
//    func childDateLabelText(_ text:String) {
//        thisViewControllerSwipe.dateLeftLabelText = text
//        thisViewControllerSwipe.setMyDateLabel(text)
//    }
//    func setChildAddressText(_ text:String) {
//        thisViewControllerSwipe.adressLabelText = text
//        thisViewControllerSwipe.setMyAdressLabel(text)
//    }
//
//    func setIndexPath(_ path:IndexPath) {
//        ownIndexPath = path
//
//        thisViewControllerSwipe.ownIndexPath = path
//    }
//
//
//    @objc func handleRightSwipes() {
//
//    }
//
//    @objc func handleLeftSwipes() {
//
//    }
//
//    required init?(coder: NSCoder = NSCoder.empty()) {
//        super.init(coder: coder)
//    }
//
//
//}
