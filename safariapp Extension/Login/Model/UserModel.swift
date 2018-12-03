//
//  UserModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/5/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import XMLMapper

class UserModel: XMLMappable{
    var nodeName: String!
    
    var body: BodyXML?
    
    
    required init?(map: XMLMap) {
    }
    func mapping(map: XMLMap) {
        body    <- map["s:Body"]
    }
}

class BodyXML: XMLMappable {
    var nodeName: String!
    
    // var errorDescriptions: String?
    // var errorCodes: String?
    var authenticateMyAeroUserResponse: AuthenticateMyAeroUserResponse?
    
    required init(map: XMLMap) {
        
    }
    
    func mapping(map: XMLMap) {
        authenticateMyAeroUserResponse <- map["AuthenticateMyAeroUserResponse"]
        
    }
}

class AuthenticateMyAeroUserResponse: XMLMappable {
    var nodeName: String!
    
    // var errorDescriptions: String?
    // var errorCodes: String?
    var authenticateMyAeroUserResult: AuthenticateMyAeroUserResult?
    
    required init(map: XMLMap) {
        
    }
    
    func mapping(map: XMLMap) {
        authenticateMyAeroUserResult <- map["AuthenticateMyAeroUserResult"]
        
    }
}

class AuthenticateMyAeroUserResult: XMLMappable {
    var nodeName: String!
    
    // var errorDescriptions: String?
    // var errorCodes: String?
    var token: String?
    var fullName: String?
    var accountEmail: String?
    var accountNumber: String?
    var gateway: String?
    var phone: String?
    var address: String?
    var address2: String?
    required init(map: XMLMap) {
        
    }
    
    func mapping(map: XMLMap) {
        token <- map["a:Token"]
        fullName  <- map["a:FullName"]
        accountEmail <- map["a:AccountEmail"]
        accountNumber <- map["a:Account"]
        gateway <- map["a:Gateway"]
        phone <- map["a:Packages_Phone"]
        address <- map["a:Packages_AddressLine1"]
        address2 <- map ["a:Packages_AddressLine2"]
    }
}










