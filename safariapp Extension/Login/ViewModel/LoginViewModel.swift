//
//  UserViewModel.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/5/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
class LoginViewModel{
    private var dataService: LoginDataManager?
    
    var userView = UserView()
    var countryArray: [Country]?
    var userObject: UserModel?
    init() {
        dataService = LoginDataManager.shared
    }
    
    // MARK: - Properties
    private var user: UserModel? {
        didSet {
            guard let p = user else { return }
            self.setupText(with: p)
            self.didFinishFetch?()
        }
    }
    
    // MARK: - Properties
    private var countries: CountriesModel? {
        didSet {
            guard let p = countries else { return }
            self.setupArray(with: p)
            self.didFinishFetch?()
        }
    }
    
    var error: Error? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    var didFinishFetch: (() -> ())?
    
    func userAuth(_ accountNumber: String, _ password: String, _ gateWay: String){
        
        self.dataService?.retrieveUserSoap(accountNumber,password,gateWay, completionHandler: { (user, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.user = user
        })
    }
    
    
    // MARK: - UI Logic
    private func setupText(with user: UserModel) {
        
        
        if let token = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.token {
            userView.token = token
            userView.fullName = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.fullName
            userView.emailAccount = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.accountEmail
            userView.accountNumber = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.accountNumber
            userView.gateway = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.gateway
            userView.phone = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.phone
            userView.addressLine1 = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.address
            userView.addressLine2 = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.address2
            userView.mailLine1 = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.mailLine1
            userView.mailLine2 = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.mailLine2
            userView.mailLine3 = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.mailLine3
            userView.accountStatus = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.accountStatus
            userView.csymbol = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.csymbol
            userView.currencyISO = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.currencyISO
            userView.isValid = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.isValid
            userView.packageState = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.packageState
            userView.packageZipCode = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.packageZipCode
            userView.personId = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.personId
            userView.lang = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.lang
            userView.owner = user.body?.authenticateMyAeroUserResponse?.authenticateMyAeroUserResult?.owner
        }
        
    }
    
    func getCountries(){
        self.dataService?.retrieveCountries(completionHandler: { (countries, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.countries = countries
        })
    }
    
    // MARK: - UI Logic
    private func setupArray(with user: CountriesModel) {
        self.countryArray = user.countries
    }
}
