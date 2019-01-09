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
        
        boxCart.fillColor = NSColor.white
        boxTrack.fillColor = NSColor(hex:ColorPalette.BackgroundColor.bgLightBlue)
        
        self.cartContentBox?.isHidden = true
        self.prealertContentBox?.isHidden = true
        self.profileContentBox?.isHidden = true
        
        if (self.contentBox.viewWithTag(900) == nil || trackRemoveView){
            trackRemoveView = false
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
            self.createBottomSection(parentSection: self.trackContentBox! ,isTrack: true)
            
            viewModel.getOrderPackagesList()
            viewModel.updateLoadingStatus = {
                let _ = self.viewModel.isLoading ? self.activityIndicatorStart() : self.activityIndicatorStop()
            }
            viewModel.didFinishFetch = {
                self.createTrackingView()
            }
        }else{
            self.trackContentBox?.isHidden = false
        }
    }
    // MARK: - UI Setup
    private func activityIndicatorStart() {
        // Code for show activity indicator view
        // ...
        print("start loading")
        self.gifView = NSView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        self.gifView!.wantsLayer = true
        self.gifView!.layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "spinner", withExtension: "gif")!)
        let jeremyGif = NSImage.sd_animatedGIF(with: imageData)
        let imageView = NSImageView(image: jeremyGif!)
        imageView.tag = 666
        imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - 40, y: (self.view.frame.size.height / 2) - 40, width: 80, height: 80)
        self.gifView!.addSubview(imageView)
        view.addSubview(self.gifView!)
    }
    
    private func activityIndicatorStop() {
        // Code for stop activity indicator view
        // ...
        print("stop loading")
        if(self.gifView != nil){
            self.gifView!.removeFromSuperview()
        }
    }
    //section tracking - prealert
    func createBottomSection(parentSection: NSView, isTrack: Bool){
        /** track box **/
        let trackBox = NSBox()
        trackBox.wantsLayer = true
        trackBox.borderType = .lineBorder
        trackBox.boxType = .custom
        trackBox.fillColor = isTrack ? NSColor(hex: ColorPalette.BackgroundColor.bgTabGray) : NSColor(hex: ColorPalette.BackgroundColor.bgTabMidGray)
        
        //create text tracking
        let trackingTextField = NSTextField()
        trackingTextField.stringValue = "track_title".localized()
        trackingTextField.isEditable = false
        trackingTextField.drawsBackground = false
        trackingTextField.isBezeled = false
        trackingTextField.textColor = isTrack ? NSColor(hex: ColorPalette.TextColor.textBlue) : NSColor(hex: ColorPalette.TextColor.textDarkGray)
        trackingTextField.tag = 900
        
        /** prealert box **/
        let prealertBox = NSBox()
        prealertBox.wantsLayer = true
        prealertBox.borderType = .lineBorder
        prealertBox.boxType = .custom
        prealertBox.fillColor = isTrack ? NSColor(hex: ColorPalette.BackgroundColor.bgTabMidGray) : NSColor(hex: ColorPalette.BackgroundColor.bgTabGray)
        
        //create text prealert
        let prealertTextField = NSTextField()
        prealertTextField.stringValue = "prealert_title".localized()
        prealertTextField.isEditable = false
        prealertTextField.drawsBackground = false
        prealertTextField.isBezeled = false
        prealertTextField.textColor = isTrack ? NSColor(hex: ColorPalette.TextColor.textDarkGray) : NSColor(hex: ColorPalette.TextColor.textBlue)
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
        
        
        let packagesCount = self.viewModel.trackingList?.count ?? 0
        if(packagesCount == 0){
            self.createTrackEmpty(parent: trackBox)
        }else{
            
            // Initial scrollview
            let scrollView = NSScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.borderType = .noBorder
            scrollView.layer?.backgroundColor = NSColor.red.cgColor
            scrollView.hasVerticalScroller = true
            
            trackBox.addSubview(scrollView)
            trackBox.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
            trackBox.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
            
            // Initial clip view
            let clipView = NSClipView()
            clipView.layer?.backgroundColor = NSColor.white.cgColor
            clipView.backgroundColor = NSColor.white
            clipView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.contentView = clipView
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0))
            
            // Initial document view
            let documentView = FlippedView()
            documentView.translatesAutoresizingMaskIntoConstraints = false
            documentView.wantsLayer = true
            documentView.layer?.backgroundColor = NSColor.white.cgColor
            
            scrollView.documentView = documentView
            clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .left, relatedBy: .equal, toItem: documentView, attribute: .left, multiplier: 1.0, constant: 0))
            clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: documentView, attribute: .top, multiplier: 1.0, constant: 0))
            clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .right, relatedBy: .equal, toItem: documentView, attribute: .right, multiplier: 1.0, constant: 0))
            
            //create text count items
            let countItemsTextField = NSTextField()
            countItemsTextField.stringValue = "track_title_last_trackings".localized()
            countItemsTextField.isEditable = false
            countItemsTextField.drawsBackground = false
            countItemsTextField.isBezeled = false
            countItemsTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
            countItemsTextField.sizeToFit()
            //create image refresh
            let imageRefresh = NSImageView.init(frame:NSMakeRect(countItemsTextField.frame.size.width + 15, 8, 10, 10))
            imageRefresh.image = NSImage(named:"icon_refresh")
            
            let refreshImageClick: NSClickGestureRecognizer = NSClickGestureRecognizer()
            refreshImageClick.action = #selector(MainViewController.refreshTrackList(_:))
            imageRefresh.addGestureRecognizer(refreshImageClick)
            
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
            scrollView.documentView = documentView
            
        }
    }
    
    private func createTrackEmpty(parent: NSView){
        //create text count items
        let countItemsTextField = NSTextField()
        countItemsTextField.stringValue = "track_title_last_trackings".localized()
        countItemsTextField.isEditable = false
        countItemsTextField.drawsBackground = false
        countItemsTextField.isBezeled = false
        countItemsTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        countItemsTextField.sizeToFit()
        //create image refresh
        let imageRefresh = NSImageView.init(frame:NSMakeRect(countItemsTextField.frame.size.width + 15, 8, 10, 10))
        imageRefresh.image = NSImage(named:"icon_refresh")
        
        let refreshImageClick: NSClickGestureRecognizer = NSClickGestureRecognizer()
        refreshImageClick.action = #selector(MainViewController.refreshTrackList(_:))
        imageRefresh.addGestureRecognizer(refreshImageClick)
        
        parent.addSubview(countItemsTextField)
        parent.addSubview(imageRefresh)
        
        //textfield constrains
        countItemsTextField.addConstraintLeft(leftOffset: 20.0, firstAttribute: .leading, secondAttribute: .leading, toItem: contentBox)
        countItemsTextField.addConstraintTop(topOffset: 10, toItem: contentBox, firstAttribute: .top, secondAttribute: .top)
        countItemsTextField.addConstraintWidth(width: countItemsTextField.frame.width)
        countItemsTextField.addConstraintHeight(height: 20.0)
        //textfield constrains
        imageRefresh.addConstraintLeft(leftOffset: 20.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: countItemsTextField)
        imageRefresh.addConstraintTop(topOffset: 10, toItem: contentBox, firstAttribute: .top, secondAttribute: .top)
        imageRefresh.addConstraintWidth(width: 20.0)
        imageRefresh.addConstraintHeight(height: 20.0)
        
        self.lastTrackBox = countItemsTextField
        
        let imageInfoNotData = NSImageView.init(frame:NSMakeRect(15, 8, 10, 10))
        imageInfoNotData.image = NSImage(named: "icon_info")
        
        //create text desc items
        let prealertEmptyTextField = TextFieldStyle()
        prealertEmptyTextField.stringValue = "track_any".localized()
        prealertEmptyTextField.sizeToFit()
        
        
        parent.addSubview(imageInfoNotData)
        parent.addSubview(prealertEmptyTextField)
        
        imageInfoNotData.addConstraintWidth(width: 30.0)
        imageInfoNotData.addConstraintHeight(height: 30.0)
        imageInfoNotData.addConstraintLeft(leftOffset: (contentBox.frame.size.width / 2) - 15, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        imageInfoNotData.addConstraintTop(topOffset: 35.0, toItem: lastTrackBox, firstAttribute: .top, secondAttribute: .bottom)
        
        prealertEmptyTextField.addConstraintWidth(width: prealertEmptyTextField.frame.size.width)
        prealertEmptyTextField.addConstraintLeft(leftOffset: (contentBox.frame.size.width / 2) - (prealertEmptyTextField.frame.size.width / 2), firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        prealertEmptyTextField.addConstraintTop(topOffset: 25.0, toItem: imageInfoNotData, firstAttribute: .top, secondAttribute: .bottom)
        
    }
    
    @objc func refreshTrackList(_ sender: Any){
        trackContentBox?.removeFromSuperview()
        trackRemoveView = true
        self.showTrackingView()
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
            dateTextField.stringValue = "track_date".localized()
            
            //create text aerotrack
            let aeroTrackTextField = TextFieldStyle()
            aeroTrackTextField.stringValue = "track_aero_track".localized()
            
            //create text status
            let statusTextField = TextFieldStyle()
            statusTextField.stringValue = "track_status".localized()
            
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
