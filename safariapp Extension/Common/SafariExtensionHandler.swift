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
    let viewModel = MainViewModel()
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
        if let data = userInfo {
            switch messageName {
            case "processPage":
                processPageAction(from: page, userInfo: data)
            case "checkPreAlert":
                checkPreAlertAction(from: page, userInfo: data)
            case "reportError":
                print(data["error"] ?? "")
                break;
            case "preAlertCanceled":
                print("report analytics")
                break;
            case "processInvoiceHtml":
                print("save invoice service")
                break;
            case "viewPackage":
                if let url = data["aeroTrackUrl"]{
                    (url as! String).openUrlInWebWithUrlString
                }
                break;
            case "stopShowingGuide":
                print("property helper")
                break;
            case "preAlert":
                preAlertAction(from: page, userInfo: data)
                break;
            default:
                print("")
            }
        }
    }
    /*
     * logic for processPage message
     */
    private func processPageAction(from page: SFSafariPage, userInfo: [String : Any]?){
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
    
    /*
     * logic for checkPreAlert message
     */
    private func checkPreAlertAction(from page: SFSafariPage, userInfo: [String : Any]?){
        //pasa el mensaje al script
        if (userInfo != nil && userInfo!["courierNumber"] != nil){
            var trackingList  = [[String: Any]]()
            var trackingObject = [String:Any]()
            trackingObject["trackingNumber"] = userInfo!["courierNumber"]
            trackingObject["address"] = userInfo!["shippingAddress"]
            trackingList.append(trackingObject)
            
            viewModel.getPrealertStatusByTracking(trackingList: trackingList)
            viewModel.didFinishFetch = {
                
                var statusResponse = [String:Any]()
                statusResponse["courierNumber"] = userInfo!["courierNumber"]
                statusResponse["preAlerted"] = !(self.viewModel.prealertStatusList?.first?.isPrealertable)!
                statusResponse["mia"] = self.viewModel.prealertStatusList?.first?.mia
                statusResponse["delivered"] = userInfo!["delivered"]
                statusResponse["storedInvoice"] = ""
                statusResponse["invoiceUrl"] = userInfo!["invoiceUrl"]
                statusResponse["firstItemDescription"] = userInfo!["firstItemDescription"]
                statusResponse["shipper"] = userInfo!["shipper"]
                statusResponse["generateInvoice"] = userInfo!["generateInvoice"]
                statusResponse["orderIndex"] = userInfo!["orderIndex"]
                
                page.dispatchMessageToScript(withName: "checkedPreAlert", userInfo: statusResponse)
            }
        }
    }
    
    /*
     * prealert package
     */
    private func preAlertAction(from page: SFSafariPage, userInfo: [String : Any]?){
        //pasa el mensaje al script
        
        let gateway = getUserInformationInStorage()?.gateway ?? ""
        var prealertDictionary = [String:Any]()
        prealertDictionary["courierNumber"] = userInfo!["courierNumber"]
        prealertDictionary["shipperName"] = userInfo!["shipperName"]
        prealertDictionary["courierName"] = userInfo!["courierName"]
        prealertDictionary["value"] = userInfo!["value"]
        prealertDictionary["packageDescription"] = userInfo!["packageDescription"]
        prealertDictionary["descriptions"] = userInfo!["descriptions"]
        prealertDictionary["invoiceData"] = userInfo!["invoiceData"]
        
        if (gateway.lowercased() == "bog") {
            prealertDictionary["value"] = userInfo!["subTotalCost"]
        }
        viewModel.packagePrealert(prealertDictionary: prealertDictionary)
        viewModel.didFinishFetch = {
            if(nil != self.viewModel.packagePrealertResult && self.viewModel.packagePrealertResult?.errorCodes != nil && self.viewModel.packagePrealertResult?.errorCodes?.first  == "0013") {
                var notification = NotificationObject(id:userInfo!["courierNumber"] as! String)
                notification.type = "basic"
                notification.point = ""
                notification.title = "extension.prealert.error.title"
                notification.msg = "extension.prealert.exists.msg"
                page.dispatchMessageToScript(withName: "showNotification", userInfo: notification.dictionary)
            }else{
                if((nil != self.viewModel.packagePrealertResult && self.viewModel.packagePrealertResult?.errorCodes != nil && (self.viewModel.packagePrealertResult?.errorCodes?.count)! > 0) ||
                    (self.viewModel.packagePrealertResult?.status != nil && self.viewModel.packagePrealertResult?.status != 200)){
                    var notification = NotificationObject(id:userInfo!["courierNumber"] as! String)
                    notification.type = "basic"
                    notification.point = ""
                    notification.title = "extension.prealert.error.title"
                    notification.msg = "extension.prealert.error.msg"
                    page.dispatchMessageToScript(withName: "showNotification", userInfo: notification.dictionary)
                }
                else{
                    var notification = NotificationObject(id:userInfo!["courierNumber"] as! String)
                    notification.type = "basic"
                    notification.point = ""
                    notification.title = "extension.prealert.congratulations.title"
                    notification.msg = "extension.prealert.congratulations.msg"
                    page.dispatchMessageToScript(withName: "showNotification", userInfo: notification.dictionary)
                }
                
            }
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
        
        return LoginViewController.shared
        
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        NSLog("VAMOS A ABRIR")
        
    }
    
    override func popoverDidClose(in window: SFSafariWindow) {
        NSLog("VAMOS A CERRAR")
    }
    
}
