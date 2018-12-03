//
//  PreAlertItemView.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/20/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
extension MainViewController{
    
    /*
     * Create PrelaertView
     * # tag for view = 1001
     */
    @objc func showPrealertView() {
        self.trackContentBox = NSView(frame: NSMakeRect(contentBox.frame.origin.x,contentBox.frame.origin.y  ,
                                                        contentBox.frame.size.width, contentBox.frame.size.height))
        self.trackContentBox!.wantsLayer = true
        //self.trackContentBox!.borderType = .lineBorder
        //self.trackContentBox!.boxType = .custom
        
        self.contentBox.addSubview(self.trackContentBox!)
        trackContentBox!.leftAnchor.constraint(equalTo: self.trackContentBox!.leftAnchor, constant: 0.0).isActive = true
        trackContentBox!.topAnchor.constraint(equalTo: self.trackContentBox!.topAnchor, constant: 0.0).isActive = true
        trackContentBox!.rightAnchor.constraint(equalTo: self.trackContentBox!.rightAnchor, constant: 0.0).isActive = true
        trackContentBox!.bottomAnchor.constraint(equalTo: self.trackContentBox!.bottomAnchor, constant: 0.0).isActive = true
        
        lastPrealertBox = self.trackContentBox
        self.createBottomSection()
        
        viewModel.getPrealertList()
        viewModel.didFinishFetch = {
            self.createPrealertView()
        }
    }
    
    func createPrealertView(){
        
        //if let trackView = self.contentBox.viewWithTag(1001) as? NSBox {
        // trackView.isHidden = false
        // }else{
        //create content box  prealert info
        let prealertBox = NSView()
        prealertBox.viewWithTag(1001)
        prealertBox.wantsLayer = true
        prealertBox.layer?.backgroundColor = NSColor.white.cgColor
        
        self.trackContentBox?.addSubview(prealertBox)
        prealertBox.addConstraintTop(topOffset: 0, toItem: self.trackContentBox!, firstAttribute: .top, secondAttribute: .top)
        prealertBox.addConstraintRight(rightOffset: 0, toItem: self.trackContentBox!)
        prealertBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: self.trackContentBox!)
        prealertBox.addConstraintHeight(height: self.trackContentBox!.frame.size.height - 30)
        //create text count items
        let countItemsTextField = NSTextField()
        countItemsTextField.stringValue = "Last 10 prealert shown"
        countItemsTextField.isEditable = false
        countItemsTextField.drawsBackground = false
        countItemsTextField.isBezeled = false
        countItemsTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        countItemsTextField.sizeToFit()
        //create image refresh
        let imageRefresh = NSImageView.init(frame:NSMakeRect(countItemsTextField.frame.size.width + 15, 8, 10, 10))
        imageRefresh.image = NSImage(named:"icon_refresh")
        
        let buttonPrealert = NSButton()
        buttonPrealert.wantsLayer = true
        buttonPrealert.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgLightBlue).cgColor
        buttonPrealert.isBordered = true
        buttonPrealert.title = "New Prealert"
        buttonPrealert.action = #selector(MainViewController.showPrealertView)
        
        // add items to trackbox
        prealertBox.addSubview(countItemsTextField)
        prealertBox.addSubview(imageRefresh)
        prealertBox.addSubview(buttonPrealert)
        
        //track content constrains
        //trackBox.addConstraintsToItem(leftOffset: 0, rightOffset: 0, topOffset: 0, height: contentBox.frame.size.height, toItem: contentBox)
        //textfield constrains
        countItemsTextField.addConstraintLeft(leftOffset: 20.0, firstAttribute: .leading, secondAttribute: .leading, toItem: prealertBox)
        countItemsTextField.addConstraintTop(topOffset: 10, toItem: prealertBox, firstAttribute: .top, secondAttribute: .top)
        countItemsTextField.addConstraintWidth(width: countItemsTextField.frame.width)
        countItemsTextField.addConstraintHeight(height: 20.0)
        //textfield constrains
        imageRefresh.addConstraintLeft(leftOffset: 20.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: countItemsTextField)
        imageRefresh.addConstraintTop(topOffset: 10, toItem: prealertBox, firstAttribute: .top, secondAttribute: .top)
        imageRefresh.addConstraintWidth(width: 20.0)
        imageRefresh.addConstraintHeight(height: 20.0)
        
        buttonPrealert.addConstraintRight(rightOffset: -20, toItem: prealertBox)
        buttonPrealert.addConstraintTop(topOffset: 10, toItem: prealertBox, firstAttribute: .top, secondAttribute: .top)
        buttonPrealert.addConstraintWidth(width: self.contentBox.frame.size.width / 2 - (40) )
        buttonPrealert.addConstraintHeight(height: 40)
        self.lastPrealertBox = buttonPrealert
        if let prealertList = self.viewModel.preAlertList{
            for prealertItem in prealertList{
                self.listOfPrealert(parentBox: prealertBox,labelCount: countItemsTextField,prealertItem:prealertItem)
            }
        }
        // }
    }
    private func listOfPrealert(parentBox: NSView, labelCount: NSView, prealertItem: PreAlert){
        
        let prealertItemBoxHeight = 60
        //create content box  del track item
        let prealertItemBox = NSView()
        prealertItemBox.wantsLayer = true
        prealertItemBox.layer?.borderWidth = 1
        prealertItemBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
       
        
        /** items del box **/
        let imageRefresh = NSImageView.init(frame:NSMakeRect(15, 8, 10, 10))
        imageRefresh.image = NSImage(named:"icon_prealert")
        
        //create text desc items
        let descriptionTextField = NSTextField()
        descriptionTextField.stringValue = prealertItem.description!
        descriptionTextField.isEditable = false
        descriptionTextField.drawsBackground = false
        descriptionTextField.isBezeled = false
        descriptionTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
        //create text courier items
        let courierTrackingTextField = NSTextField()
        courierTrackingTextField.stringValue = prealertItem.courierTracking!
        courierTrackingTextField.isEditable = false
        courierTrackingTextField.drawsBackground = false
        courierTrackingTextField.isBezeled = false
        courierTrackingTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
        //create text courier name items
        let courierNameTextField = NSTextField()
        courierNameTextField.stringValue = prealertItem.courierName!
        courierNameTextField.isEditable = false
        courierNameTextField.drawsBackground = false
        courierNameTextField.isBezeled = false
        courierNameTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
        let editPrealert = NSButton()
        editPrealert.wantsLayer = true
        editPrealert.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgLightBlue).cgColor
        editPrealert.isBordered = true
        editPrealert.title = "Edit"
        editPrealert.action = #selector(MainViewController.showPrealertView)
        
        prealertItemBox.addSubview(imageRefresh)
        prealertItemBox.addSubview(descriptionTextField)
        prealertItemBox.addSubview(courierTrackingTextField)
        prealertItemBox.addSubview(courierNameTextField)
        prealertItemBox.addSubview(editPrealert)
        parentBox.addSubview(prealertItemBox)
        /** section constraints **/
        //add constraint
        prealertItemBox.addConstraintTop(topOffset: 15, toItem: self.lastPrealertBox, firstAttribute: .top, secondAttribute: .bottom)
        prealertItemBox.addConstraintRight(rightOffset: -20, toItem: self.trackContentBox)
        prealertItemBox.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: self.trackContentBox)
        prealertItemBox.addConstraintHeight(height: CGFloat(prealertItemBoxHeight))
        
        imageRefresh.addConstraintWidth(width: 30)
        imageRefresh.addConstraintHeight(height: 30)
        imageRefresh.addConstraintLeft(leftOffset: 10, firstAttribute: .leading, secondAttribute: .leading, toItem: prealertItemBox)
        imageRefresh.addConstraintTop(topOffset: 15, toItem: prealertItemBox, firstAttribute: .top, secondAttribute: .top)
      
        descriptionTextField.addConstraintLeft(leftOffset: 10, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
        descriptionTextField.addConstraintTop(topOffset: 0, toItem: prealertItemBox, firstAttribute: .top, secondAttribute: .top)
        descriptionTextField.addConstraintWidth(width: ((self.trackContentBox!.frame.size.width - 40) * 50) / 100)
        descriptionTextField.addConstraintHeight(height: CGFloat((prealertItemBoxHeight / 3)))
        
        courierTrackingTextField.addConstraintLeft(leftOffset: 10, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
        courierTrackingTextField.addConstraintTop(topOffset: 0, toItem: descriptionTextField, firstAttribute: .top, secondAttribute: .bottom)
        courierTrackingTextField.addConstraintWidth(width: ((self.trackContentBox!.frame.size.width - 40) * 50) / 100)
        courierTrackingTextField.addConstraintHeight(height: CGFloat((prealertItemBoxHeight / 3) ))
        
        courierNameTextField.addConstraintLeft(leftOffset: 10, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
        courierNameTextField.addConstraintTop(topOffset: 0, toItem: courierTrackingTextField, firstAttribute: .top, secondAttribute: .bottom)
        courierNameTextField.addConstraintWidth(width: ((self.trackContentBox!.frame.size.width - 40) * 50) / 100)
        courierNameTextField.addConstraintHeight(height: CGFloat((prealertItemBoxHeight / 3) ))
        
        editPrealert.addConstraintRight(rightOffset: -15, toItem: prealertItemBox)
        editPrealert.addConstraintTop(topOffset: 10, toItem: prealertItemBox, firstAttribute: .top, secondAttribute: .top)
        editPrealert.addConstraintWidth(width: 80)
        editPrealert.addConstraintHeight(height: 40)
        self.lastPrealertBox = prealertItemBox
    }
    
}
