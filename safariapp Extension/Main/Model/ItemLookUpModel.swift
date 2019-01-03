//
//  ItemLookUpModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 12/20/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import ObjectMapper
import SafariServices
class ItemLookUpModel: Mappable{
    
    var itemLookUp: [ItemLookUp]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        itemLookUp <- map["results"]
    }
}

class ItemLookUp: Mappable{
    var price: Double?
    var priceTotal: Double?
    //var itemVariations: Array<T> = Array<T>()
    var itemVariations: [String: Dictionary<String, Any>]?
    var size: String?
    var color: String?
    var selectedVariation: Dictionary<String, Any>?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        price <- map["price"]
        size <- map["size"]
        color <- map["color"]
        priceTotal <- map["priceBreakdown.total"]
        itemVariations <- map["itemVariations"]
        selectedVariation <- map["selectedVariation"]
    }
}

class ItemVariations: Mappable{
    var price: Double?
    var size: String?
    var color: String?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        price <- map["price"]
        size <- map["size"]
        color <- map["color"]
    }
}
