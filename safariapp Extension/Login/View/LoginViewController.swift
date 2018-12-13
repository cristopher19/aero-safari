//
//  LoginViewController.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/2/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Cocoa
import SafariServices

class LoginViewController: SFSafariExtensionViewController, NSURLConnectionDelegate, XMLParserDelegate, NSComboBoxDataSource {
    static let shared = getInstance()
    @IBOutlet weak var aeroLogo: NSImageView!
    @IBOutlet weak var signInDescription: NSTextField!
    @IBOutlet weak var country: NSTextField!
    @IBOutlet weak var accountNumberLabel: NSTextField!
    @IBOutlet weak var accountNumberText: NSTextField!
    @IBOutlet weak var passwordLabel: NSTextField!
    @IBOutlet weak var passwordText: NSTextField!
    @IBOutlet weak var checkRememberMe: NSButton!
    @IBOutlet weak var signInBtn: NSButton!
    @IBOutlet weak var forgotPasswordLabel: NSTextField!
    @IBOutlet weak var pluginVersionLabel: NSTextField!
    
    @IBOutlet weak var messagesLoginLabel: NSTextField!
    @IBOutlet weak var countryComboBox: NSComboBox!
    @IBOutlet weak var customLoginBox: NSBox!
    
    let viewModel = LoginViewModel()
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:String = ""
    var countryArray = [String]()
    override func viewDidLoad() {
        // THIS IS ABSOLUTELY CRICITAL FOR THE POPUP TO ACTUALLY SHOW UP
        // WITHOUT IT, YOU SEE A SMALLER (EMPTY) POPUP
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        country.drawsBackground = false

        self.countryComboBox.dataSource = self
        viewModel.getCountries()
        viewModel.didFinishFetch = {
            for country in self.viewModel.countryArray!{
                self.countryComboBox.addItem(withObjectValue: country)
            }
            self.countryComboBox.reloadData()
            self.countryComboBox.selectItem(at: 0)
            
        }
    }
    
    override func viewWillAppear() {
        if(getUserInformationInStorage() != nil && getUserInformationInStorage()?.token != nil){
            let mainView = MainViewController.getInstance()
            self.present(mainView, animator: ModalAnimator())
        }
        messagesLoginLabel.isHidden = true
    }
    
    static func getInstance() -> LoginViewController {
        let storyboard = NSStoryboard(name: "LoginStoryboard", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return self.viewModel.countryArray![index].nameSpanish
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        
        
        return  self.viewModel.countryArray == nil ? 0 : self.viewModel.countryArray!.count
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        //let country: Country = countryComboBox!.objectValueOfSelectedItem as! Country
        
       // if((country.gateway.isBlank || self.accountNumberText.stringValue.isEmpty || self.passwordText.stringValue.isEmpty)){
        if(false){
            messagesLoginLabel.stringValue = "Campos en blanco"
            messagesLoginLabel.isHidden = false
        }else{
            //viewModel.userAuth(self.accountNumberText.stringValue,self.passwordText.stringValue,country.gateway!)
            viewModel.userAuth("9","aeropost","SJO")
            viewModel.updateLoadingStatus = {
                let _ = self.viewModel.isLoading ? self.activityIndicatorStart() : self.activityIndicatorStop()
            }
            viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    self.messagesLoginLabel.stringValue = "error servicio \(error.localizedDescription)"
                    self.messagesLoginLabel.isHidden = false
                }
            }
            viewModel.didFinishFetch = {
                //go to main screen
                if self.viewModel.userView.token != nil{
                    self.saveUserInformationInStorage(user: self.viewModel.userView)
                    let mainView = MainViewController.getInstance()
                    self.present(mainView, animator: ModalAnimator())
                }else{
                    self.messagesLoginLabel.stringValue = "error login"
                    self.messagesLoginLabel.isHidden = false
                }
                
            }
        }
        
        
    }
    private func saveUserInformationInStorage(user: UserView){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey:"userInformation")
    }
    
    // MARK: - UI Setup
    private func activityIndicatorStart() {
        // Code for show activity indicator view
        // ...
        print("start loading")
    }
    
    private func activityIndicatorStop() {
        // Code for stop activity indicator view
        // ...
        print("stop loading")
    }
    
    
}



