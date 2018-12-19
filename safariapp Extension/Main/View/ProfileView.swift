//
//  ProfileView.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/23/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
extension MainViewController{
    /*
     * Create Profile view
     * # tag for view = 1001
     */
    @objc func showProfileView() {
        self.cartContentBox?.isHidden = true
        self.prealertContentBox?.isHidden = true
        self.trackContentBox?.isHidden = true
        if (self.contentBox.viewWithTag(902) == nil ){
        // - 12 del scroll / - 30 de la section bottom
        self.profileContentBox = NSView(frame: NSMakeRect(contentBox.frame.origin.x,contentBox.frame.origin.y  ,
                                                        contentBox.frame.size.width, contentBox.frame.size.height))
        self.profileContentBox!.wantsLayer = true
        //self.profileContentBox!.borderType = .lineBorder
        //self.profileContentBox!.boxType = .custom
        
        self.contentBox.addSubview(self.profileContentBox!)
        profileContentBox!.leftAnchor.constraint(equalTo: self.profileContentBox!.leftAnchor, constant: 0.0).isActive = true
        profileContentBox!.topAnchor.constraint(equalTo: self.profileContentBox!.topAnchor, constant: 0.0).isActive = true
        profileContentBox!.rightAnchor.constraint(equalTo: self.profileContentBox!.rightAnchor, constant: 0.0).isActive = true
        profileContentBox!.bottomAnchor.constraint(equalTo: self.profileContentBox!.bottomAnchor, constant: 0.0).isActive = true
        
        self.createProfileView()
        }else{
            self.profileContentBox?.isHidden =  false
        }
        
    }
    
    func createProfileView(){
        let profileBox = NSView()
        profileBox.viewWithTag(1001)
        profileBox.wantsLayer = true
        profileBox.layer?.backgroundColor = NSColor.white.cgColor
        
        self.profileContentBox?.addSubview(profileBox)
        profileBox.addConstraintTop(topOffset: 0, toItem: self.profileContentBox!, firstAttribute: .top, secondAttribute: .top)
        profileBox.addConstraintRight(rightOffset: 0, toItem: self.profileContentBox!)
        profileBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: self.profileContentBox!)
        profileBox.addConstraintHeight(height: self.profileContentBox!.frame.size.height)
        //create text count items
        let accountTitleTextField = NSTextField()
        accountTitleTextField.tag = 902
        accountTitleTextField.stringValue = "Account"
        accountTitleTextField.isEditable = false
        accountTitleTextField.drawsBackground = false
        accountTitleTextField.isBezeled = false
        accountTitleTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        accountTitleTextField.sizeToFit()
        
        
        let buttonLogOut = NSButton()
        buttonLogOut.wantsLayer = true
        buttonLogOut.layer?.cornerRadius = 4
        buttonLogOut.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgDarkBlue).cgColor
        buttonLogOut.isBordered = true
        buttonLogOut.title = "LogOut"
        buttonLogOut.action = #selector(MainViewController.logOutPressed)
        
        // add items to trackbox
        profileBox.addSubview(accountTitleTextField)
        profileBox.addSubview(buttonLogOut)
        

        accountTitleTextField.addConstraintLeft(leftOffset: 15.0, firstAttribute: .leading, secondAttribute: .leading, toItem: profileBox)
        accountTitleTextField.addConstraintTop(topOffset: 10, toItem: profileBox, firstAttribute: .top, secondAttribute: .top)
        accountTitleTextField.addConstraintWidth(width: accountTitleTextField.frame.width)
        accountTitleTextField.addConstraintHeight(height: 20.0)
       
        
        buttonLogOut.addConstraintRight(rightOffset: -15, toItem: profileBox)
        buttonLogOut.addConstraintTop(topOffset: 10, toItem: profileBox, firstAttribute: .top, secondAttribute: .top)
        buttonLogOut.addConstraintWidth(width: self.contentBox.frame.size.width / 2 - (40) )
        buttonLogOut.addConstraintHeight(height: 40)
       
        lastProfileBox = buttonLogOut
        self.createProfileOptions(parent: profileBox)
    }
    
    func createProfileOptions(parent: NSView){
        //agrega el haeder de profile info
        let userInfoheaderView = self.createProfileHeaderBox(icon: "icon_profile", title: "Profile Information", editUrl: UrlPages.editProfile.idPage, parent: parent)
        self.createProfileInformation(parent: userInfoheaderView)
        
        //agrega el haeder del addres information
        let addresInfoheaderView = self.createProfileHeaderBox(icon: "profile_address", title: "Address Information", editUrl: UrlPages.editProfileAddress.idPage, parent: parent)
        self.createAddresInformation(parent: addresInfoheaderView)
        
        
    }
    func createProfileHeaderBox(icon: String,title: String, editUrl: Int, parent: NSView) -> NSView{
        /** Profile Information **/
        let profileInformationItemBoxHeight: CGFloat = 100
        let profileInformationHeaderBoxHeight: CGFloat = 40
        let imageWidth: CGFloat = 25
        let imageHeight: CGFloat = 25
        //create content box  del track item
        let profileInformationItemBox = NSView(frame: NSMakeRect(profileContentBox!.frame.origin.x,profileContentBox!.frame.origin.y  ,
                                                                  profileContentBox!.frame.size.width - 30, profileContentBox!.frame.size.height))
        profileInformationItemBox.wantsLayer = true
        profileInformationItemBox.layer?.cornerRadius = 4
        profileInformationItemBox.layer?.borderWidth = 1
        profileInformationItemBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
        
        //header of box
        let headerProfileItemBox = NSView()
        headerProfileItemBox.wantsLayer = true
        headerProfileItemBox.layer?.borderWidth = 1
        headerProfileItemBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
        headerProfileItemBox.layer!.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgTabGray).cgColor
        
        /** items del header **/
        let imageRefresh = NSImageView.init()
        imageRefresh.image = NSImage(named:icon)
        
        //create text desc items
        let profileInformationTitleTextField = NSTextField()
        profileInformationTitleTextField.stringValue = title
        profileInformationTitleTextField.isEditable = false
        profileInformationTitleTextField.drawsBackground = false
        profileInformationTitleTextField.isBezeled = false
        profileInformationTitleTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        profileInformationTitleTextField.sizeToFit()
        
        let editInformationTextField = NSTextField()
        editInformationTextField.stringValue = "Edit Information"
        editInformationTextField.isEditable = false
        editInformationTextField.drawsBackground = false
        editInformationTextField.isBezeled = false
        editInformationTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        editInformationTextField.sizeToFit()
        editInformationTextField.tag = editUrl
        
        let editInformationTextFieldClick: NSClickGestureRecognizer = NSClickGestureRecognizer()
        editInformationTextFieldClick.action = #selector(MainViewController.openUrlInWeb(_:))
        editInformationTextField.addGestureRecognizer(editInformationTextFieldClick)
        
       
        
        headerProfileItemBox.addSubview(imageRefresh)
        headerProfileItemBox.addSubview(profileInformationTitleTextField)
        headerProfileItemBox.addSubview(editInformationTextField)
        profileInformationItemBox.addSubview(headerProfileItemBox)
        //add to parent
        parent.addSubview(profileInformationItemBox)
        /** Constraint **/
        profileInformationItemBox.addConstraintTop(topOffset: 15, toItem: lastProfileBox, firstAttribute: .top, secondAttribute: .bottom)
        profileInformationItemBox.addConstraintRight(rightOffset: -15, toItem: self.profileContentBox!)
        profileInformationItemBox.addConstraintLeft(leftOffset: 15, firstAttribute: .leading, secondAttribute: .leading, toItem: self.profileContentBox!)
        profileInformationItemBox.addConstraintHeight(height: profileInformationItemBoxHeight)
        
        headerProfileItemBox.addConstraintHeight(height: profileInformationHeaderBoxHeight)
        headerProfileItemBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: profileInformationItemBox)
        headerProfileItemBox.addConstraintRight(rightOffset: 0, toItem: profileInformationItemBox)
        headerProfileItemBox.addConstraintTop(topOffset: 0, toItem: profileInformationItemBox, firstAttribute: .top, secondAttribute: .top)
        
        imageRefresh.addConstraintLeft(leftOffset: 15, firstAttribute: .leading, secondAttribute: .leading, toItem: headerProfileItemBox)
        imageRefresh.addConstraintHeight(height: imageHeight)
        imageRefresh.addConstraintWidth(width: imageWidth)
        imageRefresh.addConstraintTop(topOffset: (profileInformationHeaderBoxHeight / 2) - imageHeight / 2, toItem: headerProfileItemBox, firstAttribute: .top, secondAttribute: .top)
        
        profileInformationTitleTextField.addConstraintHeight(height: 20)
        profileInformationTitleTextField.addConstraintTop(topOffset: profileInformationHeaderBoxHeight/2 - profileInformationTitleTextField.frame.size.height / 2, toItem: headerProfileItemBox, firstAttribute: .top, secondAttribute: .top)
        profileInformationTitleTextField.addConstraintWidth(width: profileInformationTitleTextField.frame.size.width)
        profileInformationTitleTextField.addConstraintLeft(leftOffset: 5, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
        
        
        editInformationTextField.addConstraintHeight(height: 20)
        editInformationTextField.addConstraintTop(topOffset: profileInformationHeaderBoxHeight/2 - editInformationTextField.frame.size.height / 2, toItem: headerProfileItemBox, firstAttribute: .top, secondAttribute: .top)
        editInformationTextField.addConstraintWidth(width: editInformationTextField.frame.size.width)
        editInformationTextField.addConstraintRight(rightOffset: -15, toItem: headerProfileItemBox)
        

       lastProfileBox = headerProfileItemBox
        
       return profileInformationItemBox
    
    }
    
    func createProfileInformation(parent: NSView){
        //create text name
        let profileInformationNameTextField = NSTextField()
        profileInformationNameTextField.stringValue = "Name: "
        profileInformationNameTextField.isEditable = false
        profileInformationNameTextField.drawsBackground = false
        profileInformationNameTextField.isBezeled = false
        profileInformationNameTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        profileInformationNameTextField.alignment = .right
        
        //create text account
        let profileInformationAccountTextField = NSTextField()
        profileInformationAccountTextField.stringValue = "Account: "
        profileInformationAccountTextField.isEditable = false
        profileInformationAccountTextField.drawsBackground = false
        profileInformationAccountTextField.isBezeled = false
        profileInformationAccountTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        profileInformationAccountTextField.alignment = .right
        
        //create text  delivery
        let profileInformationDeliveryTextField = NSTextField()
        profileInformationDeliveryTextField.stringValue = "Delivery: "
        profileInformationDeliveryTextField.isEditable = false
        profileInformationDeliveryTextField.drawsBackground = false
        profileInformationDeliveryTextField.isBezeled = false
        profileInformationDeliveryTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        profileInformationDeliveryTextField.alignment = .right
        
        //create text desc name value
        let profileInformationNameValueTextField = NSTextField()
        profileInformationNameValueTextField.stringValue = userInformation?.fullName ?? ""
        profileInformationNameValueTextField.isEditable = false
        profileInformationNameValueTextField.drawsBackground = false
        profileInformationNameValueTextField.isBezeled = false
        profileInformationNameValueTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
        //create text account value
        let profileInformationAccountValueTextField = NSTextField()
        var accountValue = ""
        if(userInformation?.gateway != nil && userInformation?.accountNumber != nil){
            accountValue = (userInformation?.gateway)! + "-" + (userInformation?.accountNumber)!
        }
        profileInformationAccountValueTextField.stringValue = accountValue
        profileInformationAccountValueTextField.isEditable = false
        profileInformationAccountValueTextField.drawsBackground = false
        profileInformationAccountValueTextField.isBezeled = false
        profileInformationAccountValueTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
        //create text delivery value
        let profileInformationDeliveryValueTextField = NSTextField()
        profileInformationDeliveryValueTextField.stringValue = ""
        profileInformationDeliveryValueTextField.isEditable = false
        profileInformationDeliveryValueTextField.drawsBackground = false
        profileInformationDeliveryValueTextField.isBezeled = false
        profileInformationDeliveryValueTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
        //addd views
        parent.addSubview(profileInformationNameTextField)
        parent.addSubview(profileInformationAccountTextField)
        parent.addSubview(profileInformationDeliveryTextField)
        parent.addSubview(profileInformationNameValueTextField)
        parent.addSubview(profileInformationAccountValueTextField)
        parent.addSubview(profileInformationDeliveryValueTextField)
        
        /** Constraint **/
        profileInformationNameTextField.addConstraintHeight(height: 14)
        profileInformationNameTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.40))
        profileInformationNameTextField.addConstraintLeft(leftOffset: 15, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        profileInformationNameTextField.addConstraintTop(topOffset: 8, toItem: lastProfileBox, firstAttribute: .top, secondAttribute: .bottom)
        
        profileInformationAccountTextField.addConstraintHeight(height: 14)
        profileInformationAccountTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.40))
        profileInformationAccountTextField.addConstraintLeft(leftOffset: 15, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        profileInformationAccountTextField.addConstraintTop(topOffset: 1, toItem: profileInformationNameTextField, firstAttribute: .top, secondAttribute: .bottom)
        
        /** values **/
        profileInformationNameValueTextField.addConstraintHeight(height: 14)
        profileInformationNameValueTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.48))
        profileInformationNameValueTextField.addConstraintTop(topOffset: 8, toItem: lastProfileBox, firstAttribute: .top, secondAttribute: .bottom)
        profileInformationNameValueTextField.addConstraintRight(rightOffset: -15, toItem: parent)
        
        profileInformationAccountValueTextField.addConstraintHeight(height: 14)
        profileInformationAccountValueTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.48))
        profileInformationAccountValueTextField.addConstraintTop(topOffset: 1, toItem: profileInformationNameValueTextField, firstAttribute: .top, secondAttribute: .bottom)
        profileInformationAccountValueTextField.addConstraintRight(rightOffset: -15, toItem: parent)
        
        lastProfileBox = parent
    }
    
    
    func createAddresInformation(parent: NSView){
        //create text name
        let addressTextField = NSTextField()
        addressTextField.stringValue = "Address: "
        addressTextField.isEditable = false
        addressTextField.drawsBackground = false
        addressTextField.isBezeled = false
        addressTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        addressTextField.alignment = .right
        
        //create text account
        let phoneTextField = NSTextField()
        phoneTextField.stringValue = "Phone: "
        phoneTextField.isEditable = false
        phoneTextField.drawsBackground = false
        phoneTextField.isBezeled = false
        phoneTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        phoneTextField.alignment = .right
      
        
        //create text desc name value
        let addressTextFieldValueTextField = NSTextField()
        var addressComplete = ""
        if(userInformation?.addressLine1 != nil && userInformation?.addressLine2 != nil){
            addressComplete = (userInformation?.addressLine1)! + " " + (userInformation?.addressLine2)!
         }
        addressTextFieldValueTextField.stringValue = addressComplete
        addressTextFieldValueTextField.isEditable = false
        addressTextFieldValueTextField.drawsBackground = false
        addressTextFieldValueTextField.isBezeled = false
        addressTextFieldValueTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
   
        
        //create text account value
        let phoneTextFieldValueTextField = NSTextField()
        phoneTextFieldValueTextField.stringValue = userInformation?.phone ?? ""
        phoneTextFieldValueTextField.isEditable = false
        phoneTextFieldValueTextField.drawsBackground = false
        phoneTextFieldValueTextField.isBezeled = false
        phoneTextFieldValueTextField.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        
       
        //addd views
        parent.addSubview(addressTextField)
        parent.addSubview(phoneTextField)
        parent.addSubview(addressTextFieldValueTextField)
        parent.addSubview(phoneTextFieldValueTextField)
        
        /** Constraint **/
        /** Constraint **/
        addressTextField.addConstraintHeight(height: 14)
        addressTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.40))
        addressTextField.addConstraintLeft(leftOffset: 15, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        addressTextField.addConstraintTop(topOffset: 8, toItem: lastProfileBox, firstAttribute: .top, secondAttribute: .bottom)
        
        phoneTextField.addConstraintHeight(height: 14)
        phoneTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.40))
        phoneTextField.addConstraintLeft(leftOffset: 15, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        phoneTextField.addConstraintTop(topOffset: 1, toItem: addressTextField, firstAttribute: .top, secondAttribute: .bottom)
        
        /** values **/
        addressTextFieldValueTextField.addConstraintHeight(height: 14)
        addressTextFieldValueTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.48))
        addressTextFieldValueTextField.addConstraintTop(topOffset: 8, toItem: lastProfileBox, firstAttribute: .top, secondAttribute: .bottom)
        addressTextFieldValueTextField.addConstraintRight(rightOffset: -15, toItem: parent)
        
        phoneTextFieldValueTextField.addConstraintHeight(height: 14)
        phoneTextFieldValueTextField.addConstraintWidth(width:   (parent.frame.size.width * 0.48))
        phoneTextFieldValueTextField.addConstraintTop(topOffset: 1, toItem: addressTextFieldValueTextField, firstAttribute: .top, secondAttribute: .bottom)
        phoneTextFieldValueTextField.addConstraintRight(rightOffset: -15, toItem: parent)
        
       
    }
}
