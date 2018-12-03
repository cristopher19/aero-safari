//
//  TrackModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/12/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import ObjectMapper

class TrackModel: Mappable{
    
    var orderPackagesList: [OrderPackages]?
    var message: Int?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        orderPackagesList <- map["results.orderResponses"]
        message <- map["results.pagination.totalRows"]
    }
}

class OrderPackages: Mappable{
    var orderNum: String?
    var orderDate: String?
    var type: Int?
    var orderPackageDetails: [OrderPackageDetails]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        orderNum <- map["order.orderNum"]
        orderDate <- map["order.orderDate"]
        type <- map["order.typeId"]
        orderPackageDetails <- map["order.orderDetails"]
       
    }
}


class OrderPackageDetails: Mappable{
    var description: String?
    var itemStatus: String?
    var imageUrl: String?
    var orderPackageDetails: [OrderPackageDetails]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        description <- map["description"]
        itemStatus <- map["itemStatus.name.eng"]
        imageUrl <- map["imageUrl"]
    }
}
