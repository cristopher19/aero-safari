//
//  BasicResponseModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 1/7/19.
//  Copyright © 2019 Centauro-mac. All rights reserved.
//

import Foundation
import ObjectMapper

class BasciRsponseModel: Mappable{
    
    var status: Int?
    var descriptionTitle: String?
    var description: String?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        status <- map["status"]
       
    }
}
