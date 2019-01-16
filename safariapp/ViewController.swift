//
//  ViewController.swift
//  safariapp
//
//  Created by Centauro-mac on 11/2/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet var appNameLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appNameLabel.stringValue = "aeropost extension";
       
     
    }
    
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.aeropost.safari.extension") { error in
            if let _ = error {
                // Insert code to inform the user that something went wrong.

            }
        }
    }
    
    override func viewDidAppear() {
       self.view.window?.delegate = self
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool{
        NSApplication.shared.terminate(self)
    return true
    }

}
