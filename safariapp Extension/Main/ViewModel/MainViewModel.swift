//
//  MainViewModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/12/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
import SwiftyJSON
class MainViewModel{
    private var dataService: MainDataManager?
    
    var error: Error? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    var didFinishFetch: (() -> ())?
    
    var preAlertList: [PreAlert]?
    var trackingList: [PackageOrderView]?
    var cartObject: CartModel?
    var prealertStatusList: [PrealertStatus]?
    var packagePrealertResult: PreAlertResponseModel?
    var addCartResult: BasciRsponseModel?
    var itemLoockUpResult: JSON?
    init() {
        dataService = MainDataManager.shared
    }
    
    // MARK: - Properties
    private var addTocartProp: BasciRsponseModel? {
        didSet {
            guard let p = addTocartProp else { return }
            self.setupAddToCart(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var itemLookUp: JSON? {
        didSet {
            guard let p = itemLookUp else { return }
            self.setupItemLookUp(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var packagePrealert: PreAlertResponseModel? {
        didSet {
            guard let p = packagePrealert else { return }
            self.setupPackagePrealert(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var prealert: PreAlertModel? {
        didSet {
            guard let p = prealert else { return }
            self.setupPrealertList(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var prealertStatus: PrealertStatusModel? {
        didSet {
            guard let p = prealertStatus else { return }
            self.setupPrealertStatusList(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var tracking: TrackModel? {
        didSet {
            guard let p = tracking else { return }
            self.setupTrackingList(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var cart: CartModel? {
        didSet {
            guard let p = cart else { return }
            self.setupCart(with: p)
            self.didFinishFetch?()
        }
    }
    
    func getItemLoockUp(userInfo: [String:Any], sourceType: String){
   
        self.dataService?.itemLookUp(productId: userInfo["productASIN"] as! String, sourceType: sourceType, variantLookup: true, completionHandler: { (itemLoockUpResult, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            let colorReq = userInfo["color"] as? String != nil ?  userInfo["color"] as! String : ""
            let sizeReq = userInfo["size"] as? String != nil ?  userInfo["size"] as! String : ""
            var variantKey = ""
            if let lookUpItem = itemLoockUpResult {
                var firstItem = lookUpItem["results"][0]
                variantKey =  sizeReq.lowercased().replacingOccurrences(of: "", with: "")
                variantKey += colorReq.lowercased()
                
                print("item color = \(colorReq) item size= \(sizeReq)")
                
                let val = firstItem["itemVariations"].dictionaryValue
                if let variant = val[variantKey]{
                    firstItem["price"] = variant["price"]
                    firstItem["color"]  = variant["color"]
                    firstItem["selectedVariation"] = variant
                }else{
                    firstItem["selectedVariation"] = ""
                }
                
                self.itemLookUp = firstItem
            }else{
                self.itemLookUp = nil
            }
            self.error = nil
            self.isLoading = false
            
        })
    }
    
    func addToCart(userInfo: [String:Any]){
        
        self.dataService?.addToCart(product: userInfo, completionHandler: { (addCartResult, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.addTocartProp = addCartResult
        })
    }
    
    
    func packagePrealert(prealertDictionary: [String:Any]){
        self.dataService?.createPrealert(prealertDictionary: prealertDictionary, completionHandler: { (prealertStatus, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.packagePrealert = prealertStatus
        })
    }
    
    func getPrealertStatusByTracking(trackingList: [[String:Any]]){
        self.isLoading = true
        self.dataService?.getPrealertStatusByTracking(trackingList: trackingList, completionHandler: { (prealertStatus, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.prealertStatus = prealertStatus
        })
    }
    
    func getOrderPackagesList(){
        self.isLoading = true
        self.dataService?.retrievePackageTrackingList(completionHandler: { (tracking, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.tracking = tracking
        })
    }
    
    func getPrealertList(){
        self.isLoading = true
        self.dataService?.retrievePrealertList(completionHandler: { (prealerts, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.prealert = prealerts
        })
    }
    func getCart(){
        self.isLoading = true
        self.dataService?.retrieveCart(completionHandler: { (cart, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.cart = cart
        })
    }
    
    func deleteCartItem(productId: String){
        self.dataService?.deleteCartItem(productId: productId, completionHandler: { (cart, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.cart = cart
        })
    }
    
    func userLogOut(completionHandler: (_ result: Bool) -> Void){
        UserDefaults.standard.removeObject(forKey: "cartID")
        UserDefaults.standard.removeObject(forKey: "userInformation")
        UserDefaults.standard.synchronize()
        completionHandler(true) // return data & close
    }
    
    
    // MARK: - UI Logic
    private func setupPrealertList(with prealert: PreAlertModel) {
        self.preAlertList = prealert.prealerts
    }
    // MARK: - UI Logic
    private func setupTrackingList(with track: TrackModel) {
        var trackingOrderList = [PackageOrderView]()
        if let tracklist = track.orderPackagesList{
            for trackItem in tracklist {
                if let trackDetailList =  trackItem.orderPackageDetails{
                    for trackItemDetail in trackDetailList{
                        var orderView = PackageOrderView()
                        orderView.packageOrderDate = trackItem.orderDate
                        orderView.packageOrderDescripcion = trackItemDetail.description
                        orderView.packageOrderNum = trackItem.orderNum
                        orderView.packageOrderStatus = trackItemDetail.itemStatus
                        orderView.packageOrderType = trackItem.type
                        orderView.packageImageUrl = trackItemDetail.imageUrl
                        trackingOrderList.append(orderView)
                    }
                }
            }
        }
        self.trackingList = trackingOrderList
    }
    
    private func setupPrealertStatusList(with prealertStatus: PrealertStatusModel){
        self.prealertStatusList = prealertStatus.trackingList
    }
    
    private func setupCart(with cart: CartModel) {
        self.cartObject = cart
    }
    
    private func setupPackagePrealert(with packagePrealert: PreAlertResponseModel){
        self.packagePrealertResult = packagePrealert
    }
    
    private func setupItemLookUp(with item: JSON){
        itemLoockUpResult = item
    }
    
    private func setupAddToCart(with item: BasciRsponseModel){
        if(item.status == 201){
            item.descriptionTitle = "addtocart_congratulations_title".localized()
            item.description = "addtocart_congratulations_msg".localized()
        }else{
            item.descriptionTitle = "addtocart_error_title".localized()
            item.description = "addtocart_error_msg".localized()
        }
        addCartResult = item
    }
}
class FlippedView: NSView {
    override var isFlipped:Bool {
        get {
            return true
        }
    }
}
