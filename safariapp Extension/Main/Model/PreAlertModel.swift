//
//  PreAlertModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/12/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import ObjectMapper

class PreAlertModel: Mappable{
    
    var prealerts: [PreAlert]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        prealerts <- map["results.notesDetailList"]
    }
}

class PreAlert: Mappable{
    var description: String?
    var courierName: String?
    var courierTracking: String?
   
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        description <- map["description"]
        courierName <- map["courierName"]
        courierTracking <- map["courierTracking"]
        
    }
}
