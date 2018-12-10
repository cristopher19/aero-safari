//
//  LoginView.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/22/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
struct UserView:Codable{
    var token: String?
    var fullName: String?
    var emailAccount: String?
    var gateway: String?
    var accountNumber: String?
    var phone: String?
    var addressLine1: String?
    var addressLine2: String?
    var mailLine1: String?
    var mailLine2: String?
    var mailLine3: String?
    var accountStatus: String?
    var personId: String?
    var csymbol: String?
    var currencyISO: String?
    var packageState: String?
    var packageZipCode: String?
    var isValid: Bool?
    var lang: Int?
    var owner: Bool?
}
