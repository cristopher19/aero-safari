//
//  TrackItemView.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/16/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
extension MainViewController{
    /*
     * Create tracking view
     * # tag for view = 1001
     */
    @objc func showTrackingView() {
        self.cartContentBox?.isHidden = true
        self.prealertContentBox?.isHidden = true
        self.profileContentBox?.isHidden = true
        if (self.contentBox.viewWithTag(900) == nil ){
            // - 12 del scroll / - 30 de la section bottom
            self.trackContentBox = NSView(frame: NSMakeRect(contentBox.frame.origin.x,contentBox.frame.origin.y  ,
                                                            contentBox.frame.size.width, contentBox.frame.size.height))
            self.trackContentBox!.wantsLayer = true
            //self.trackContentBox!.borderType = .lineBorder
            //self.trackContentBox!.boxTyßpe = .custom
            
            self.contentBox.addSubview(self.trackContentBox!)
            trackContentBox!.leftAnchor.constraint(equalTo: self.trackContentBox!.leftAnchor, constant: 0.0).isActive = true
            trackContentBox!.topAnchor.constraint(equalTo: self.trackContentBox!.topAnchor, constant: 0.0).isActive = true
            trackContentBox!.rightAnchor.constraint(equalTo: self.trackContentBox!.rightAnchor, constant: 0.0).isActive = true
            trackContentBox!.bottomAnchor.constraint(equalTo: self.trackContentBox!.bottomAnchor, constant: 0.0).isActive = true
            
            lastTrackBox = self.trackContentBox
            self.createBottomSection(parentSection: self.trackContentBox!)
            
            viewModel.getOrderPackagesList()
            viewModel.didFinishFetch = {
                self.createTrackingView()
            }
        }else{
            self.trackContentBox?.isHidden = false
        }
    }
    
    //section tracking - prealert
    func createBottomSection(parentSection: NSView){
        /** track box **/
        let trackBox = NSBox()
        trackBox.wantsLayer = true
        trackBox.borderType = .lineBorder
        trackBox.boxType = .custom
        trackBox.fillColor = NSColor(hex: ColorPalette.BackgroundColor.bgTabGray)
        
        //create text tracking
        let trackingTextField = NSTextField()
        trackingTextField.stringValue = "Tracking"
        trackingTextField.isEditable = false
        trackingTextField.drawsBackground = false
        trackingTextField.isBezeled = false
        trackingTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        trackingTextField.tag = 900
        /** prealert box **/
        let prealertBox = NSBox()
        prealertBox.wantsLayer = true
        prealertBox.borderType = .lineBorder
        prealertBox.boxType = .custom
        prealertBox.fillColor = NSColor(hex: ColorPalette.BackgroundColor.bgTabGray)
        
        //create text prealert
        let prealertTextField = NSTextField()
        prealertTextField.stringValue = "Prealert"
        prealertTextField.isEditable = false
        prealertTextField.drawsBackground = false
        prealertTextField.isBezeled = false
        prealertTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        prealertTextField.sizeToFit()
        
        /** add views **/
        trackBox.addSubview(trackingTextField)
        prealertBox.addSubview(prealertTextField)
        
        parentSection.addSubview(trackBox)
        parentSection.addSubview(prealertBox)
        
        /** add constraint  box **/
        trackBox.addConstraintHeight(height: 30)
        trackBox.addConstraintWidth(width: self.trackContentBox!.frame.size.width / 2)
        trackBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: self.trackContentBox)
        trackBox.addConstraintBottom(topOffset: 0, toItem: self.trackContentBox, firstAttribute: .bottom, secondAttribute: .bottom)
        
        prealertBox.addConstraintHeight(height: 30)
        prealertBox.addConstraintWidth(width: self.trackContentBox!.frame.size.width / 2)
        prealertBox.addConstraintLeft(leftOffset: 1, firstAttribute: .leading, secondAttribute: .trailing, toItem: trackBox)
        prealertBox.addConstraintBottom(topOffset: 0, toItem: self.trackContentBox, firstAttribute: .bottom, secondAttribute: .bottom)
        
        /** add constraint  text to box **/
        prealertTextField.addConstraintHeight(height: 20)
        prealertTextField.addConstraintWidth(width: prealertTextField.frame.width)
        
        trackingTextField.addConstraintHeight(height: 20)
        trackingTextField.addConstraintWidth(width: prealertTextField.frame.width)
        
        let xConstraintTrackingTextField = NSLayoutConstraint(item: trackingTextField, attribute: .centerX, relatedBy: .equal, toItem: trackBox, attribute: .centerX, multiplier: 1, constant: 0)
        
        let xConstraintPrealertTextField = NSLayoutConstraint(item: prealertTextField, attribute: .centerX, relatedBy: .equal, toItem: prealertBox, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([xConstraintTrackingTextField, xConstraintPrealertTextField])
        //buttons action
        let buttonTrack = NSButton()
        buttonTrack.wantsLayer = true
        buttonTrack.layer?.backgroundColor = NSColor.clear.cgColor
        buttonTrack.isBordered = false
        buttonTrack.title = ""
        
        buttonTrack.action = #selector(MainViewController.showTrackingView)
        
        let buttonPrealert = NSButton()
        buttonPrealert.wantsLayer = true
        buttonPrealert.layer?.backgroundColor = NSColor.clear.cgColor
        buttonPrealert.isBordered = false
        buttonPrealert.title = ""
        buttonPrealert.action = #selector(MainViewController.showPrealertView)
        
        trackBox.addSubview(buttonTrack)
        prealertBox.addSubview(buttonPrealert)
        //butons constraint
        buttonTrack.addConstraintsToItem(leftOffset: 0, rightOffset: 0, topOffset: 0, height: 30, toItem: trackBox)
        buttonPrealert.addConstraintsToItem(leftOffset: 0, rightOffset: 0, topOffset: 0, height: 30, toItem: prealertBox)
    }
    
    
    
    
    
    func createTrackingView(){
        
        
        
        let trackBox = NSView()
        trackBox.viewWithTag(1001)
        trackBox.wantsLayer = true
        trackBox.layer?.backgroundColor = NSColor.white.cgColor
        
        
        
        self.trackContentBox?.addSubview(trackBox)
        
        
        trackBox.addConstraintTop(topOffset: 0, toItem: self.trackContentBox!, firstAttribute: .top, secondAttribute: .top)
        trackBox.addConstraintRight(rightOffset: 0, toItem: self.trackContentBox!)
        trackBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: self.trackContentBox!)
        trackBox.addConstraintHeight(height: self.trackContentBox!.frame.size.height - 30)
        
        // Initial scrollview
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = NSColor.white
        scrollView.hasVerticalScroller = true
        
        trackBox.addSubview(scrollView)
        trackBox.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        trackBox.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        
        // Initial clip view
        let clipView = NSClipView()
        clipView.layer?.backgroundColor = NSColor.white.cgColor
        clipView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentView = clipView
        scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        // Initial document view
        let documentView = NSView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.wantsLayer = true
        documentView.layer?.backgroundColor = NSColor.white.cgColor
        
        scrollView.documentView = documentView
        clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .left, relatedBy: .equal, toItem: documentView, attribute: .left, multiplier: 1.0, constant: 0))
        clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: documentView, attribute: .top, multiplier: 1.0, constant: 0))
        clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .right, relatedBy: .equal, toItem: documentView, attribute: .right, multiplier: 1.0, constant: 0))
        
        //create text count items
        let countItemsTextField = NSTextField()
        countItemsTextField.stringValue = "Last 10 trackings"
        countItemsTextField.isEditable = false
        countItemsTextField.drawsBackground = false
        countItemsTextField.isBezeled = false
        countItemsTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        countItemsTextField.sizeToFit()
        //create image refresh
        let imageRefresh = NSImageView.init(frame:NSMakeRect(countItemsTextField.frame.size.width + 15, 8, 10, 10))
        imageRefresh.image = NSImage(named:"icon_refresh")
        documentView.addSubview(countItemsTextField)
        documentView.addSubview(imageRefresh)
        
        //textfield constrains
        countItemsTextField.addConstraintLeft(leftOffset: 20.0, firstAttribute: .leading, secondAttribute: .leading, toItem: clipView)
        countItemsTextField.addConstraintTop(topOffset: 10, toItem: clipView, firstAttribute: .top, secondAttribute: .top)
        countItemsTextField.addConstraintWidth(width: countItemsTextField.frame.width)
        countItemsTextField.addConstraintHeight(height: 20.0)
        //textfield constrains
        imageRefresh.addConstraintLeft(leftOffset: 20.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: countItemsTextField)
        imageRefresh.addConstraintTop(topOffset: 10, toItem: clipView, firstAttribute: .top, secondAttribute: .top)
        imageRefresh.addConstraintWidth(width: 20.0)
        imageRefresh.addConstraintHeight(height: 20.0)
        
        self.lastTrackBox = countItemsTextField
        if let trackingList = self.viewModel.trackingList{
            self.lastTrackBox = countItemsTextField
            self.listOfTracking(parentBox: documentView,trackList:trackingList)
            
        }
        
        /*
         let trackItemBox = NSView()
         trackItemBox.wantsLayer = true
         trackItemBox.layer?.backgroundColor = NSColor.white.cgColor
         trackItemBox.layer?.borderWidth = 1
         trackItemBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
         
         // Subview1
         let view1 = NSView()
         view1.translatesAutoresizingMaskIntoConstraints = false
         view1.wantsLayer = true
         view1.layer?.backgroundColor = NSColor.red.cgColor
         documentView.addSubview(view1)
         
         
         let view2 = NSView()
         view2.translatesAutoresizingMaskIntoConstraints = false
         view2.wantsLayer = true
         view2.layer?.backgroundColor = NSColor.red.cgColor
         documentView.addSubview(view2)
         
         view1.addConstraintTop(topOffset: 15, toItem: clipView, firstAttribute: .top, secondAttribute: .top)
         view1.addConstraintRight(rightOffset: -20, toItem: clipView)
         view1.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: clipView)
         view1.addConstraintHeight(height: 200)
         
         documentView.addSubview(trackItemBox)
         trackItemBox.addConstraintTop(topOffset: 15, toItem: view1, firstAttribute: .top, secondAttribute: .bottom)
         trackItemBox.addConstraintRight(rightOffset: -20, toItem: clipView)
         trackItemBox.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: clipView)
         trackItemBox.addConstraintHeight(height: 200)
         
         
         view2.addConstraintTop(topOffset: 15, toItem: trackItemBox, firstAttribute: .top, secondAttribute: .bottom)
         view2.addConstraintRight(rightOffset: -20, toItem: clipView)
         view2.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: clipView)
         view2.addConstraintHeight(height: 200)
         view2.addConstraintBottom(topOffset: -40, toItem: documentView, firstAttribute: .bottom, secondAttribute: .bottom)
         */
        scrollView.documentView = documentView
        
        
    }
    
    private func listOfTracking(parentBox:NSView,trackList: [PackageOrderView]){
        for (index,trackItem) in trackList.enumerated(){
            let descriptionBoxHeight = 30
            
            //create content box  del track item
            let trackItemBox = NSView()
            trackItemBox.translatesAutoresizingMaskIntoConstraints = false
            trackItemBox.wantsLayer = true
            trackItemBox.layer?.backgroundColor = NSColor.white.cgColor
            trackItemBox.layer?.borderWidth = 1
            trackItemBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
            
            let buttonTrackClick = NSButton()
            buttonTrackClick.isTransparent = true
            buttonTrackClick.title = ""
            buttonTrackClick.tag = UrlPages.checkOut.idPage
            buttonTrackClick.action = #selector(MainViewController.openUrlInWeb(_:))
            
            //create text date
            let dateTextField =  TextFieldStyle()
            dateTextField.stringValue = "Date:"
            
            //create text aerotrack
            let aeroTrackTextField = TextFieldStyle()
            aeroTrackTextField.stringValue = "Aerotrack #:"
            
            //create text status
            let statusTextField = TextFieldStyle()
            statusTextField.stringValue = "Status: "
            
            //create text datevalue
            let dateValueTextField = TextFieldStyle()
            dateValueTextField.stringValue = trackItem.packageOrderDate!.formatStringAeroDate
            
            
            //create text aerotrack value
            let aeroTrackValueTextField = TextFieldStyle()
            aeroTrackValueTextField.stringValue = trackItem.packageOrderNum!
            
            
            //create text status value
            let statusValueTextField = TextFieldStyle()
            statusValueTextField.stringValue = trackItem.packageOrderStatus!
            
            
            /** section button **/
            //create content box de la descripcion del item
            let descriptionSectionBox = NSView(frame: NSMakeRect(contentBox.frame.origin.x,contentBox.frame.origin.y,
                                                                 contentBox.frame.size.width,contentBox.frame.size.height))
            descriptionSectionBox.wantsLayer = true
            descriptionSectionBox.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgLightGray).cgColor
            descriptionSectionBox.layer?.borderWidth = 1
            descriptionSectionBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
            
            let imageRefresh = NSImageView.init(frame:NSMakeRect(15, 8, 10, 10))
            let url = URL(string: trackItem.packageImageUrl ?? "")
            if(url != nil){
                imageRefresh.sd_setImage(with: URL(string: (url?.absoluteString)!), placeholderImage: NSImage(named: "defaultImage"))
            }else{
                imageRefresh.sd_setImage(with: URL(string: ("")), placeholderImage: NSImage(named: "defaultImage"))
            }
            
            //create text item description
            let itemDescriptionTextField = TextFieldStyle()
            itemDescriptionTextField.stringValue = trackItem.packageOrderDescripcion!
            itemDescriptionTextField.sizeToFit()
            
            //add subviews
            /**top section **/
            trackItemBox.addSubview(dateTextField)
            trackItemBox.addSubview(aeroTrackTextField)
            trackItemBox.addSubview(statusTextField)
            trackItemBox.addSubview(dateValueTextField)
            trackItemBox.addSubview(aeroTrackValueTextField)
            trackItemBox.addSubview(statusValueTextField)
            trackItemBox.addSubview(buttonTrackClick)
            /** bottom section **/
            descriptionSectionBox.addSubview(imageRefresh)
            descriptionSectionBox.addSubview(itemDescriptionTextField)
            
            trackItemBox.addSubview(descriptionSectionBox)
            //add to parent view
            parentBox.addSubview(trackItemBox)
            /** section constraints **/
            //add constraint
            trackItemBox.addConstraintTop(topOffset: 15, toItem: self.lastTrackBox, firstAttribute: .top, secondAttribute: .bottom)
            trackItemBox.addConstraintRight(rightOffset: -20, toItem: parentBox)
            trackItemBox.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: parentBox)
            trackItemBox.addConstraintHeight(height: 80)
            
            buttonTrackClick.addConstraintTop(topOffset: 15, toItem: self.lastTrackBox, firstAttribute: .top, secondAttribute: .bottom)
            buttonTrackClick.addConstraintRight(rightOffset: -20, toItem: parentBox)
            buttonTrackClick.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: parentBox)
            buttonTrackClick.addConstraintHeight(height: 80)
            
            //constraint fields
            dateTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .leading, toItem: trackItemBox)
            dateTextField.addConstraintTop(topOffset: 5.0, toItem: trackItemBox, firstAttribute: .top, secondAttribute: .top)
            dateTextField.addConstraintWidth(width: (self.trackContentBox!.frame.size.width*18)/100)
            
            
            aeroTrackTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: dateTextField)
            aeroTrackTextField.addConstraintTop(topOffset: 5.0, toItem: trackItemBox, firstAttribute: .top, secondAttribute: .top)
            aeroTrackTextField.addConstraintWidth(width: ((self.trackContentBox!.frame.size.width*28)/100) )
            
            statusTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: aeroTrackTextField)
            statusTextField.addConstraintTop(topOffset: 5.0, toItem: trackItemBox, firstAttribute: .top, secondAttribute: .top)
            statusTextField.addConstraintWidth(width: (self.trackContentBox!.frame.size.width*54)/100)
            
            //add constraint values
            dateValueTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .leading, toItem: trackItemBox)
            dateValueTextField.addConstraintTop(topOffset: 5.0, toItem: dateTextField, firstAttribute: .top, secondAttribute: .bottom)
            dateValueTextField.addConstraintWidth(width: (self.trackContentBox!.frame.size.width*18)/100)
            
            aeroTrackValueTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: dateValueTextField)
            aeroTrackValueTextField.addConstraintTop(topOffset: 5.0, toItem: aeroTrackTextField, firstAttribute: .top, secondAttribute: .bottom)
            aeroTrackValueTextField.addConstraintWidth(width: ((self.trackContentBox!.frame.size.width*28)/100) )
            
            statusValueTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: aeroTrackValueTextField)
            statusValueTextField.addConstraintTop(topOffset: 5.0, toItem: statusTextField, firstAttribute: .top, secondAttribute: .bottom)
            
            statusValueTextField.addConstraintWidth(width: (self.trackContentBox!.frame.size.width*53)/100)
            
            /** description box section **/
            descriptionSectionBox.addConstraintHeight(height: CGFloat(descriptionBoxHeight))
            descriptionSectionBox.addConstraintLeft(leftOffset: 0.0, firstAttribute: .leading, secondAttribute: .leading, toItem: trackItemBox)
            descriptionSectionBox.addConstraintRight(rightOffset: 0.0, toItem: trackItemBox)
            descriptionSectionBox.addConstraintBottom(topOffset: 0.0, toItem: trackItemBox, firstAttribute: .bottom, secondAttribute: .bottom)
            
            imageRefresh.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .leading, toItem: descriptionSectionBox)
            imageRefresh.addConstraintHeight(height: 20)
            imageRefresh.addConstraintWidth(width: 20)
            imageRefresh.addConstraintTop(topOffset:  CGFloat((descriptionBoxHeight / 2)) - (20 / 2), toItem: descriptionSectionBox, firstAttribute: .top, secondAttribute: .top)
            
            itemDescriptionTextField.addConstraintWidth(width: itemDescriptionTextField.frame.size.width)
            itemDescriptionTextField.addConstraintHeight(height: itemDescriptionTextField.frame.size.height)
            itemDescriptionTextField.addConstraintLeft(leftOffset: 5, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
            itemDescriptionTextField.addConstraintTop(topOffset: CGFloat((descriptionBoxHeight / 2)) - (itemDescriptionTextField.frame.size.height / 2) , toItem: descriptionSectionBox, firstAttribute: .top, secondAttribute: .top)
            
            self.lastTrackBox = trackItemBox
            
            if(index == (trackList.count - 1)){
                trackItemBox.addConstraintBottom(topOffset: -40, toItem: parentBox, firstAttribute: .bottom, secondAttribute: .bottom)
            }
        }
    }
    
    
}
