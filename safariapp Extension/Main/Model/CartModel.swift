//
//  CartModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/28/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import ObjectMapper

class CartModel: Mappable{
    
    var cartId: String?
    var sessionID: String?
    var subtotal: CGFloat?
    var administrativeFee: CGFloat?
    var taxes: CGFloat?
    var shippingCost: CGFloat?
    var discountMultipleItems: CGFloat?
    var totalPrice: CGFloat?
    var cartItemList: [ShoppingCartProducts]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        cartId <- map["results.cartId"]
        sessionID <- map["results.sessionId"]
        subtotal <- map["results.subtotal"]
        administrativeFee <- map["results.administrativeFee"]
        taxes <- map["results.taxes"]
        shippingCost <- map["results.shipping"]
        discountMultipleItems <- map["results.multipleItemsShippingDiscount"]
        totalPrice <- map["results.totalPrice"]
        cartItemList <- map["results.shoppingCartProducts"]
    }
}

class ShoppingCartProducts: Mappable{
    var image: String?
    var title: String?
    var price: CGFloat?
    var productId: String?
    var quantity: Int?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        image <- map["image"]
        title <- map["title"]
        price <- map["price"]
        productId <- map["productId"]
        quantity <- map["quantity"]
    }
}
