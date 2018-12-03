//
//  ConfigurationFile.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/5/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
struct API {
    static let baseUrl = "https://marketplace-api.aeropost.com/api"
}

protocol Endpoint {
    var path: String { get }
    var url: String { get }
}

enum Endpoints {
    
    enum Posts: Endpoint {
        
        case getCountries
        case getPrealerts
        case getTracking
        case getCart
        case deleteItemCart
        public var path: String {
            switch self {
            case .getCountries: return "/country/GetCountries?ip=&lang="
            case .getPrealerts: return "/PackagePrealert/GetAccountPrealerts"
            case .getTracking: return "/order/GetNewOrdersPackagesByAccount"
            case .getCart: return "/shoppingcart/GetShoppingCart?"
            case .deleteItemCart: return "/shoppingcart/deleteshoppingcartproduct?"
            }
        }
        
        public var url: String {
            switch self {
            case .getCountries:return "\(API.baseUrl)\(path)"
            case .getPrealerts:return "\(API.baseUrl)\(path)"
            case .getTracking:return "\(API.baseUrl)\(path)"
            case .getCart:return "\(API.baseUrl)\(path)"
            case .deleteItemCart:return "\(API.baseUrl)\(path)"
            }
        }
    }
}
protocol UrlPage {
    var urlPages: Int { get }
}
enum UrlPages{
    case checkOut
    case cart
    case profile
    case editProfile
    case editProfileAddress
    case aero
    public var idPage: Int{
        switch self {
        case .aero:
            return 1001
        case .checkOut:
            return 1002
        case .cart:
            return 1003
        case .profile:
            return 1004
        case .editProfile:
            return 1005
        case .editProfileAddress:
            return 1006
        }
    }
    public var url: String {
        switch self {
        case .aero:
            return " https://aeropost.com/site/en"
        case .checkOut:
            return "https://aeropost.com/site/en"
        case .cart:
            return "https://aeropost.com/site/en"
        case .profile:
            return "https://aeropost.com/site/en"
        case .editProfile:
            return "https://aeropost.com/site/en"
        case .editProfileAddress:
            return "https://aeropost.com/site/en"
        }
    }
}


