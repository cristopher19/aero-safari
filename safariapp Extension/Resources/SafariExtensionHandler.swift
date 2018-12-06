//
//  SafariExtensionHandler.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/2/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import SafariServices
import SwiftyJSON
class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
        if (messageName == "processPage") {
            //pasa el mensaje al script
            var firstRunColorboxArray = [String]()
            firstRunColorboxArray.append(PropertyHelper.PROP_COLORBOX_FIRST_RUN_AMAZON)
           
            
            var processPageMessage = [String:Any]()
            processPageMessage["signedIn"] = getUserInformationInStorage().dictionary
            processPageMessage["clientAllowed"] = true
            processPageMessage["checkRecipient"] = false
            processPageMessage["firstRunColorboxArray"] = firstRunColorboxArray
            
            page.dispatchMessageToScript(withName: "processPage", userInfo: processPageMessage)
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
        
        // this only works if the toolbar button is configured to send a Command and not a popup
        /*window.getToolbarItem { (toolbarItem) in
         toolbarItem?.setBadgeText("3")
         }*/
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        var viewResult: SFSafariExtensionViewController = LoginViewController.shared
        
        if(getUserInformationInStorage() != nil && getUserInformationInStorage()?.token != nil){
            viewResult = MainViewController.shared
        }
        
        return viewResult
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        NSLog("VAMOS A ABRIR")
        
    }
    
    override func popoverDidClose(in window: SFSafariWindow) {
        NSLog("VAMOS A CERRAR")
    }
    
}
