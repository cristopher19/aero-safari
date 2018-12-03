//
//  LoginDataManager.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/5/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import Alamofire
import XMLMapper
import CryptoSwift
import AlamofireObjectMapper
struct LoginDataManager{
    // MARK: - Singleton
    static let shared = LoginDataManager()
    let sessionManager = SessionManager.default
    func retrieveCountries(completionHandler: @escaping (_ Result:CountriesModel?, _ Error:NSError?) -> Void) {
        let headerParameters  = ["Content-Type":"application/json; charset=utf-8"]
        var params = [String:Any]()
        params["token"] = ""
        params["pageIndex"] = 0
        params["pageSize"] = 6
        params["ip"] = "0.0.0.0"
        sessionManager.request(Endpoints.Posts.getCountries.url, parameters:params, headers:headerParameters)
            .validate().responseObject(completionHandler: {(response: DataResponse<CountriesModel>) in
                switch response.result {
                case .success(let posts):
                   completionHandler(posts, nil)
                case .failure( let error):
                    print("Request failed with error:\(error)")
                    completionHandler(nil, error as NSError?)
                    
                }
            })
    }

    
    /*
     * MARK: - Auth user
    * retrieve user information
    * @SOAP message
    * @params -> Account number, Gateway, Password
    */
    func retrieveUserSoap(_ accountNumber: String, _ password: String, _ gateWay: String, completionHandler: @escaping (_ Result:UserModel?, _ Error:NSError?) -> Void) {
        let soapMessage = String(format: "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:AuthenticateMyAeroUser><tem:MyAeroGateway>%@</tem:MyAeroGateway><tem:MyAeroAccount>%@</tem:MyAeroAccount><tem:MyAeroPasswordMD5>%@</tem:MyAeroPasswordMD5><tem:remember>true</tem:remember><tem:DeviceID>02e114e7-b206-e3b9-e9d7-1640f9b6d313</tem:DeviceID><tem:MobileType>8</tem:MobileType><tem:OperatingSystemName>Mac</tem:OperatingSystemName><tem:OperatingSystemVersion>10.13</tem:OperatingSystemVersion><tem:DeviceBrand>Chrome</tem:DeviceBrand><tem:DeviceModel>71</tem:DeviceModel><tem:AppName>Aeropost Plug-in</tem:AppName><tem:AppVersion>2.2.3</tem:AppVersion><tem:WebServiceSecurity_User>MyAeroChromeBeta</tem:WebServiceSecurity_User><tem:WebServiceSecurity_Password>Pmc#0Mqc!4ZaV</tem:WebServiceSecurity_Password></tem:AuthenticateMyAeroUser></soapenv:Body></soapenv:Envelope>", gateWay, accountNumber, password.md5())
        
        let msgLength = soapMessage.count
        let urlString = "https://www2.myaeropost.com/WS_MyAero/Services.svc"
        let soapAction = "http://tempuri.org/IServices/AuthenticateMyAeroUser"
        
        let url = URL(string: urlString)!
        var requestSoap = URLRequest(url: url)
        requestSoap.setValue(soapAction, forHTTPHeaderField: "SOAPAction")
        requestSoap.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        requestSoap.setValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        requestSoap.httpMethod = "POST"
        requestSoap.httpBody = soapMessage.data(using: .utf8)
        
        sessionManager.request(requestSoap)
            .validate()
            .responseXMLObject(completionHandler: {(response: DataResponse<UserModel>) in
                switch response.result {
                case .success(let posts):
                    completionHandler(posts, nil)
                case .failure( let error):
                    completionHandler(nil, error as NSError?)
                }
            })
    }
}


