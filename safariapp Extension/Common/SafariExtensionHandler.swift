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
            case "quoteMoreProducts":
                quoteMoreProductsAction(from: page, userInfo: data)
                break;
            case "quoteProduct":
                quoteProductAction(from: page, userInfo: data)
                break;
            case "addToCart":
                addToCartAction(from: page, userInfo: data)
                break;
            case "SearchURL":
                
                var url = "http://aeropost.com/site/%S1/search?q=%S2&gtw=%S3&lang=%S4";
                url = url.replacingOccurrences(of: "%S1", with: "en")
                url = url.replacingOccurrences(of: "%S2", with: data["url"] as? String ?? "")
                url = url.replacingOccurrences(of: "%S3", with: getUserInformationInStorage()?.gateway ?? "")
                url = url.replacingOccurrences(of: "%S4", with: String(getUserInformationInStorage()?.lang ?? 1))
          
                url.openUrlInWebWithUrlString
                break;
            default:
                print("")
            }
        }
    }
    /*
     * logic for addCart message
     */
    private func addToCartAction(from page: SFSafariPage, userInfo: [String : Any]?){
        var addToCartResult = [String:Any]()
        if let info = userInfo{
            let product = info["productInfo"] as? [String : Any]
            if(product != nil){
                viewModel.addToCart(userInfo: product!)
                viewModel.didFinishFetch = {
                    addToCartResult["title"] = self.viewModel.addCartResult?.descriptionTitle
                    addToCartResult["msg"] = self.viewModel.addCartResult?.description
                    page.dispatchMessageToScript(withName: "showQuoteAgain", userInfo: addToCartResult)
                }
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
    private func quoteMoreProductsAction(from page: SFSafariPage, userInfo: [String : Any]?){
        //pasa el mensaje al script
        if (userInfo != nil){
            
            var itemDescriptions: String  = userInfo!["itemsDescription"] as! String
            itemDescriptions = itemDescriptions.replacingOccurrences(of: "&", with: "and", options: .literal, range: nil)
            var products = [EbayProductObject()]
            
            let countDescription =  itemDescriptions.components(separatedBy: "|%|")
            
            for (index, _) in  countDescription.enumerated(){
                
                var productObj = EbayProductObject()
                productObj.description = countDescription[index]
                productObj.quantity = 1;
                products.append(productObj)
                var description = ""
                //Se ordena los articulos repetidos
                orderProducts(aProducts: &products)
                
                //Se ordena en relacion a la cantidad de producto
                while (0 < products.count) {
                    let prodObj = getMajor(aProducts: &products);
                    description = description + prodObj.description
                    if(0 < products.count){
                        description = description + ","
                    }
                }
            }
            var trackingDescription = [String:Any]()
            trackingDescription["description"] = userInfo!["itemsDescription"]
            trackingDescription["courierNumber"] = userInfo!["courierNumber"]
            trackingDescription["orderIndex"] = userInfo!["orderIndex"]
             page.dispatchMessageToScript(withName: "changeTrackingDescription", userInfo: trackingDescription)
            
        }
    }
    
    private func orderProducts(aProducts: inout [EbayProductObject]){
        for (index, _) in aProducts.enumerated() {
            let obj = aProducts[index];
            for(indexY, _) in aProducts.enumerated(){
                var xCount = indexY
                let obj2 = aProducts[xCount + 1];
                if(obj.description == obj2.description){
                    aProducts[index].quantity = aProducts[index].quantity + 1
                    aProducts.splice(range: xCount...1)
                    xCount = xCount - 1
                }
            }
        }
    }
    
    private func getMajor(aProducts: inout [EbayProductObject]) -> EbayProductObject{
        var obj = EbayProductObject();
        obj.quantity = 0;
        var position = 0;
        for (index, _) in aProducts.enumerated() {
            if(obj.quantity < aProducts[index].quantity){
                obj = aProducts[index];
                position = index;
            }
        }
        
         aProducts.splice(range: position...1)
        return obj;
    }
    /*
     * logic for processPage message
     */
    private func quoteProductAction(from page: SFSafariPage, userInfo: [String : Any]?){
       var calculatePriceDictionary = [String:Any]()
        viewModel.getItemLoockUp(userInfo: userInfo ?? [String:Any](), sourceType: "amz")
        viewModel.didFinishFetch = {
            calculatePriceDictionary["product"] = self.viewModel.itemLoockUpResult.dictionary
             page.dispatchMessageToScript(withName: "showQuoteData", userInfo: calculatePriceDictionary)
        }
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
                    page.dispatchMessageToScript(withName: "reloadCurrentPage", userInfo:nil)
                    
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
