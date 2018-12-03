//
//  Countries.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/9/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//
import ObjectMapper
import Foundation
class CountriesModel: Mappable{

    var countries: [Country]?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        countries <- map["results.countries"]
    }
}

class Country: Mappable{
    var id: String?
    var gateway: String?
    var nameSpanish: String?
    var nameEnglish: String?
    var uiType: String?
    required init?(map: Map) {
    }
    
     func mapping(map: Map) {
        id <- map["id"]
        gateway <- map["gateway"]
        nameSpanish <- map["nameSpanish"]
        nameEnglish <- map["nameEnglish"]
        uiType <- map["uiType"]
    }
}
