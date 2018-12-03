//
//  MainViewController.swift
//  aero
//
//  Created by Juan Manuel Rodriguez Alvarado on 10/10/18.
//  Copyright © 2018 Aeropost. All rights reserved.
//

import SafariServices

class MainViewController: SFSafariExtensionViewController, XMLParserDelegate {
    
    //var sfWindow: SFSafariWindow?
    let sfPage: SFSafariPage? = nil
    
    static let shared = getInstance()
    
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:String = ""
    
   
    @IBOutlet weak var customHeaderView: NSView!
    @IBOutlet weak var trackingTabLabel: NSTextField!
    @IBOutlet weak var boxCart: NSBox!
    @IBOutlet weak var boxTrack: NSBox!
    @IBOutlet weak var contentBox: NSBox!
    @IBOutlet weak var userNameLabel: NSTextField!
    @IBOutlet weak var userAccountLabel: NSTextField!
    @IBOutlet weak var userImage: NSImageView!
    var trackContentBox: NSView? 
    var lastTrackBox: NSView?
    var lastPrealertBox: NSView?
    var lastProfileBox: NSView?
    var lastCartBox: NSView?
    let viewModel = MainViewModel()
    var userInformation: UserView?
    override func viewDidLoad() {
        // THIS IS ABSOLUTELY CRICITAL FOR THE POPUP TO ACTUALLY SHOW UP
        // WITHOUT IT, YOU SEE A SMALLER (EMPTY) POPUP
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        self.view.wantsLayer = true
        self.showTrackingView()
        userInformation = getUserInformationInStorage()
        customHeaderView.wantsLayer = true
        customHeaderView.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override func viewWillAppear() {
        let account: String = getUserInformationInStorage()?.accountNumber ?? ""
        let gateway: String = getUserInformationInStorage()?.gateway ?? ""
    
        userNameLabel.stringValue = getUserInformationInStorage()?.fullName ?? ""
        userAccountLabel.stringValue = gateway + "-" + account
        trackingTabLabel.isEditable = false
        trackingTabLabel.drawsBackground = false
        trackingTabLabel.isBezeled = false
        trackingTabLabel.textColor = NSColor.white
    }

    
    static func getInstance() -> MainViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "MainViewController") as! MainViewController
    }
    
    @objc func logOutPressed(){
        viewModel.userLogOut(){ result in
            let loginView = LoginViewController.getInstance()
            self.present(loginView, animator: ModalAnimator())
        }
       
    }
    @IBAction func btnShowProfileSectionAction(_ sender: Any) {
        self.showProfileView()
    }
    
    @IBAction func trackingBtnAction(_ sender: Any) {
        
        self.showTrackingView()
    }
    
    @IBAction func cartBtnAction(_ sender: Any) {
        self.showCartView()
    }
    
    @objc func openUrlInWeb(_ sender: Any){
        var tagItem:Int = UrlPages.aero.idPage
        if let item = sender as? NSButton {
           tagItem = item.tag
        }else{
            if let item = sender as? NSTextField {
                tagItem = item.tag
            }
        }
        let urlResult = tagItem.checkUrl
        
        if let url = URL(string: urlResult),
            NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
}


