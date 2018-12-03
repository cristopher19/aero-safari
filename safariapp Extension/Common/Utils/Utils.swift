//
//  Utils.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/12/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
struct UtilsAeropost {
    
}
extension Int{
    var checkUrl: String{
        switch self {
        case UrlPages.checkOut.idPage:
            return UrlPages.checkOut.url
        case UrlPages.cart.idPage:
            return UrlPages.checkOut.url
        case UrlPages.profile.idPage:
            return UrlPages.checkOut.url
        case UrlPages.editProfile.idPage:
            return UrlPages.checkOut.url
        default:
            return ""
        }
    }
}
//validate empty field
extension String {
    var fieldTextBlank: Bool{
        if(self == ""){
            return true
        }
        return false
    }
    //formatea las fechas a formato que utiliza aeropost
    var formatStringAeroDate:String {
        var result = "00.00.0000"
        if(self != ""){
            let index = self.index(self.startIndex, offsetBy: 10)
            let stringFormat = self.substring(to: index)
            
            let arraDate = stringFormat.split(separator: "-")
            if(arraDate.indices.contains(2) && arraDate.indices.contains(1) && arraDate.indices.contains(0)){
                result = arraDate[2] + "." + arraDate[1] + "." + arraDate[0]
            }
            
            //result =  stringFormat.replacingOccurrences(of: "-", with: ".")
        }
        
        return result
    }
}
//validate empty field with optional
extension Optional where Wrapped == String {
    var isBlank: Bool {
        return self?.isEmpty ?? true
    }
}
extension NSColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

func getUserInformationInStorage() -> UserView?{
    var resultView:UserView?
    if let data = UserDefaults.standard.value(forKey:"userInformation") as? Data {
        let user = try? PropertyListDecoder().decode(UserView.self, from: data)
        resultView = user 
    }
    return resultView
}
