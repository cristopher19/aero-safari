//
//  MainDataManager.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/12/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftyJSON
struct MainDataManager{
    // MARK: - Singleton
    static let shared = MainDataManager()
    let sessionManager = SessionManager.default
    /*
     * MARK: - Prealert list
     * retrieve prealert list
     * @params ->
     */
    func retrievePrealertList(completionHandler: @escaping (_ Result:PreAlertModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        var parametersBody = [ String : Any]()
        parametersBody["token"] = getUserInformationInStorage()?.token ?? ""
        parametersBody["pageIndex"] = 0
        parametersBody["pageSize"] = 10
        parametersBody["ip"] = "0.0.0.0"
        sessionManager.request(Endpoints.Posts.getPrealerts.url,method: .post, parameters:parametersBody,encoding: JSONEncoding.default, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<PreAlertModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
            })
    }
    /*
     * MARK: - Prealert list
     * retrieve prealert list
     * @params ->
     */
    func retrievePackageTrackingList(completionHandler: @escaping (_ Result:TrackModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        var parametersBody = [ String : Any]()
        var parametersBodyFilter = [ String : Any]()
        parametersBodyFilter["onlyPendingPayment"] = false
        parametersBodyFilter["onlyCancelled"] = false
        parametersBodyFilter["onlyOpen"] = false
        parametersBodyFilter["account"] = getUserInformationInStorage()?.accountNumber ?? ""
        parametersBodyFilter["gateway"] = getUserInformationInStorage()?.gateway ?? ""
        parametersBodyFilter["rowsPerPage"] = 6
        parametersBodyFilter["pageNumber"] = 1
        //parametersBodyFilter["DateRange"] = "Between"
        parametersBodyFilter["sortIsDescending"] = true
        parametersBodyFilter["isGraphicView"] = false
        parametersBodyFilter["fillPackagesCharges"] = false
        parametersBodyFilter["includePreAlerts"] = false
        parametersBodyFilter["filterByStatus"] = "inTransit"
        parametersBodyFilter["searchText"] = ""
        parametersBodyFilter["lang"] = "en"
        parametersBody["token"] = getUserInformationInStorage()?.token ?? ""
        parametersBody["pageIndex"] = 1
        parametersBody["pageSize"] = 1
        parametersBody["filters"] = parametersBodyFilter
        
        sessionManager.request(Endpoints.Posts.getTracking.url,method: .post, parameters:parametersBody,encoding: JSONEncoding.default, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<TrackModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
                
            }) 
    }
    
    
    /*
     * MARK: - Prealert list
     * retrieve prealert list
     * @params ->
     */
    func addToCart(completionHandler: @escaping (_ Result:TrackModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        var parametersBody = [ String : Any]()
        var parametersBodyFilter = [ String : Any]()
        parametersBodyFilter["lang"] = "en"
        parametersBodyFilter["sessionId"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["account"] = getUserInformationInStorage()?.accountNumber ?? ""
        parametersBodyFilter["gateway"] = getUserInformationInStorage()?.gateway ?? ""
        parametersBodyFilter["gateway"] = getUserInformationInStorage()?.gateway ?? ""
        
        parametersBodyFilter["amazonTax"] = 6
        parametersBodyFilter["shipping"] = 1
        parametersBodyFilter["shippingRate"] = true
        
        parametersBodyFilter["subtotal"] = false
        parametersBodyFilter["taxes"] = false
        parametersBodyFilter["totalPrice"] = false
        
        parametersBodyFilter["hcCode"] = "inTransit"
        parametersBodyFilter["image"] = ""
        parametersBodyFilter["productUrl"] = "en"
        
        parametersBodyFilter["quantity"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["administrativeFee"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["declaredValue"] = getUserInformationInStorage()?.token ?? ""
        
        
        parametersBodyFilter["price"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["category"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["title"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["weight"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["amazonTax"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["sku"] = getUserInformationInStorage()?.token ?? ""
        parametersBodyFilter["productJson"] = getUserInformationInStorage()?.token ?? ""
        
        
        
        sessionManager.request(Endpoints.Posts.getTracking.url,method: .post, parameters:parametersBody,encoding: JSONEncoding.default, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<TrackModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
                
            })
    }
    
   
    /*
     * MARK: - Prealert list
     * retrieve prealert list
     * @params ->
     */
    func retrieveCart(completionHandler: @escaping (_ Result:CartModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        
        let endpoint = Endpoints.Posts.getCart.url + "sessionId=\(getUserInformationInStorage()?.token ?? "")&account=\(getUserInformationInStorage()?.accountNumber ?? "")&gateway=\(getUserInformationInStorage()?.gateway ?? "")"
        sessionManager.request(endpoint,method: .get, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<CartModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
            })
    }
    
    /*
     * MARK: - Prealert list
     * item look up
     * @params ->
     */
    func itemLookUp(productId:String,sourceType:String,variantLookup:Bool, completionHandler: @escaping (_ Result:JSON?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        
        let userGateway = getUserInformationInStorage()?.gateway ?? ""
        let userLanguage = getUserInformationInStorage()?.lang ?? 1
        let sessionId = getUserInformationInStorage()?.token ?? ""
        let showLocalCurrency = false
        
        let urlParams = "productid=\(productId)&gateway=\(userGateway)&lang=\(userLanguage)&sourcetype=\(sourceType)&quantity=1&cartTotal=0&sessionId=\(sessionId)&showLocalCurrency=\(showLocalCurrency)&variantLookup=\(variantLookup)"
        
        let endpoint = Endpoints.Posts.itemLookUp.url + urlParams
        
        sessionManager.request(endpoint,method: .get, headers:headerParameters)
            .validate().responseJSON { response in
                switch response.result {
                case .success(let posts):
                    completionHandler(JSON(posts), nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
            }
    }
    
    /*
     * MARK: - item lookup
     * delete item from cart
     * @params ->
     */
    func deleteCartItem(productId:String, completionHandler: @escaping (_ Result:CartModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        
        let endpoint = Endpoints.Posts.deleteItemCart.url + "cartId=\(UserDefaults.standard.string(forKey: "cartID") ?? "")&productId=\(productId)&sessionId=\(getUserInformationInStorage()?.token ?? "")"
        sessionManager.request(endpoint,method: .delete, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<CartModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
            })
    }
    
    
    /*
     * MARK: - Prealert list
     * retrieve prealert list
     * @params ->
     */
    func getPrealertStatusByTracking(trackingList: [[String:Any]],completionHandler: @escaping (_ Result:PrealertStatusModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
     
        var parametersBody = [ String : Any]()
        var parametersClientInformation = [ String : Any]()
        parametersClientInformation["gateway"] = getUserInformationInStorage()?.gateway ?? ""
        parametersClientInformation["account"] = getUserInformationInStorage()?.accountNumber ?? ""
        parametersClientInformation["lang"] =  "en"
        parametersClientInformation["showOnlyLocalAmount"] = false
        
        parametersBody["clientInformation"] = parametersClientInformation
        parametersBody["trackingList"] = trackingList
        parametersBody["token"] = getUserInformationInStorage()?.token ?? ""
        
        sessionManager.request(Endpoints.Posts.getPrealerStatus.url,method: .post, parameters:parametersBody,encoding: JSONEncoding.default, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<PrealertStatusModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
                
            })
    }
    
    /*
     * MARK: - Prealert list
     * retrieve prealert list
     * @params ->
     */
    func createPrealert(prealertDictionary: [String:Any],completionHandler: @escaping (_ Result:PreAlertResponseModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        var endPoint: String = Endpoints.Posts.prealertPackageAmazon.url
        if(prealertDictionary["shipperName"] as! String != "amazon"){
            endPoint = Endpoints.Posts.prealertPackageEbay.url
        }
        var parametersBody = [ String : Any]()
        //info user
        parametersBody["Token"] = getUserInformationInStorage()?.token ?? ""
        parametersBody["gateway"] = getUserInformationInStorage()?.gateway ?? ""
        parametersBody["accountId"] = getUserInformationInStorage()?.accountNumber ?? ""
        parametersBody["clientFullName"] = getUserInformationInStorage()?.fullName ?? ""
        parametersBody["clientEmail"] = getUserInformationInStorage()?.emailAccount ?? ""
        parametersBody["lang"] = getUserInformationInStorage()?.lang ?? ""
        parametersBody["owner"] = getUserInformationInStorage()?.owner ?? ""
        
        //info prealert
        parametersBody["courierNumber"] = prealertDictionary["courierNumber"]
        parametersBody["courierName"] = prealertDictionary["courierName"]
        parametersBody["shipperName"] = prealertDictionary["shipperName"]
        parametersBody["invoiceData"] = prealertDictionary["invoiceData"]
        parametersBody["value"] = prealertDictionary["value"]
        parametersBody["consignee"] = getUserInformationInStorage()?.fullName ?? ""
        parametersBody["descriptions"] = prealertDictionary["descriptions"]
        parametersBody["taxDescription"] = ""
        parametersBody["taxCode"] = ""
        parametersBody["exonerate"] = false
        parametersBody["intranetUserEmail"] = "browser-extensions@aeropost.com"
        parametersBody["aeroShopOrderNumber"] = "-1"
        parametersBody["ip"] = "0"
        
        sessionManager.request(endPoint,method: .post, parameters:parametersBody,encoding: JSONEncoding.default, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<PreAlertResponseModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
            })
    }
}
