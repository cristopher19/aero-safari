//
//  PrealertStatusModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 12/7/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import ObjectMapper

class PrealertStatusModel: Mappable{

    var trackingList: [PrealertStatus]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        trackingList <- map["results.trackingList"]
    }
}

class PrealertStatus: Mappable{
    var isPrealertable: Bool?
    var errorDescriptionEn: String?
    var errorCode: String?
    var errorDescriptionEs: String?
    var mia: String?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        isPrealertable <- map["isPrealertable"]
        errorCode <- map["errorCode"]
        errorDescriptionEn <- map["errorDescriptionEn"]
        errorDescriptionEs <- map["errorDescriptionEs"]
        mia <- map["mia"]
    }
}
