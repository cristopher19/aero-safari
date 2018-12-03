//
//  MainViewModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/12/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
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
    init() {
        dataService = MainDataManager.shared
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
    
    func getOrderPackagesList(){
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
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
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
    
    private func setupCart(with cart: CartModel) {
        self.cartObject = cart
    }
}
