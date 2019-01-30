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
    @IBOutlet weak var boxContentData: NSBox!
    

    @IBOutlet weak var signInBtn: NSButton!
  
    @IBOutlet weak var pluginVersionLabel: NSTextField!
    
    @IBOutlet weak var messagesLoginLabel: NSTextField!
    @IBOutlet weak var countryComboBox: NSComboBox!
    @IBOutlet weak var customLoginBox: NSBox!
    @IBOutlet weak var passwordText: NSSecureTextField!
    @IBOutlet weak var forgotButton: NSButton!
    
    let viewModel = LoginViewModel()
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:String = ""
    var countryArray = [String]()
    var gifView: NSView? = nil
    override func viewDidLoad() {
        // THIS IS ABSOLUTELY CRICITAL FOR THE POPUP TO ACTUALLY SHOW UP
        // WITHOUT IT, YOU SEE A SMALLER (EMPTY) POPUP
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        country.drawsBackground = false

        country.stringValue = "login_country".localized()
        accountNumberLabel.stringValue = "login_account_number".localized()
        passwordLabel.stringValue = "login_password".localized()
        signInDescription.stringValue = "login_description".localized()
   
        forgotButton.title = "login_forgot_password".localized()
        pluginVersionLabel.stringValue = "login_plugin_version".localized()
        
        signInBtn.wantsLayer = true
        signInBtn.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgDarkBlue).cgColor
        signInBtn.isBordered = false
        signInBtn.layer?.cornerRadius = 4
        signInBtn.frame.size.height = 40
        signInBtn.title = "login_sign_in".localized()
        
        customLoginBox.wantsLayer = true
        customLoginBox.fillColor = NSColor(hex: ColorPalette.BackgroundColor.bgLightGray2)
        
        passwordText.wantsLayer = true
        passwordText.layer?.borderWidth = 0.5
        passwordText.layer?.borderColor = NSColor(hex:ColorPalette.BorderColor.bgMidGray).cgColor
        passwordText.layer?.cornerRadius = 4
        
        accountNumberText.wantsLayer = true
        accountNumberText.layer?.borderWidth = 0.5
        accountNumberText.layer?.borderColor = NSColor(hex:ColorPalette.BorderColor.bgMidGray).cgColor
        accountNumberText.layer?.cornerRadius = 4
     
        //generate UUID and storage
        if(UserDefaults.standard.string(forKey: "clientId") == "" || UserDefaults.standard.string(forKey: "clientId") == nil){
            UserDefaults.standard.set(NSUUID().uuidString, forKey: "clientId")
        }
        
        self.countryComboBox.dataSource = self
        viewModel.getCountries()
        viewModel.updateLoadingStatus = {
            let _ = self.viewModel.isLoading ? self.activityIndicatorStart() : self.activityIndicatorStop()
        }
        viewModel.didFinishFetch = {
            for country in self.viewModel.countryArray!{
                self.countryComboBox.addItem(withObjectValue: country)
            }
            self.countryComboBox.reloadData()
            self.countryComboBox.selectItem(at: 0)
            
        }
       
    }
    
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        UrlPages.forgotPasswrod.url.openUrlInWebWithUrlString
    }
    override func viewWillAppear() {
        
        
        if(getUserInformationInStorage() != nil && getUserInformationInStorage()?.token != nil){
            let mainView = MainViewController.getInstance()
            self.present(mainView, animator: ModalAnimator())
        }else{
                let loginView = LoginViewController.getInstance()
                self.present(loginView, animator: ModalAnimator())
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
        let country: Country = countryComboBox!.objectValueOfSelectedItem as! Country
        
        if((country.gateway.isBlank || self.accountNumberText.stringValue.isEmpty || self.passwordText.stringValue.isEmpty)){
        //if(false){
            messagesLoginLabel.stringValue = "Campos en blanco"
            messagesLoginLabel.isHidden = false
        }else{
         
            viewModel.userAuth(self.accountNumberText.stringValue,self.passwordText.stringValue,country.gateway!)
         
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
        self.gifView = NSView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        self.gifView!.wantsLayer = true
        self.gifView!.layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "spinner", withExtension: "gif")!)
        let jeremyGif = NSImage.sd_animatedGIF(with: imageData)
        let imageView = NSImageView(image: jeremyGif!)
        imageView.tag = 666
        imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - 40, y: (self.view.frame.size.height / 2) - 40, width: 80, height: 80)
        self.gifView!.addSubview(imageView)
        view.addSubview(self.gifView!)
    }
    
    private func activityIndicatorStop() {
        // Code for stop activity indicator view
        // ...
        
        print("stop loading")
        if(self.gifView != nil){
            self.gifView!.removeFromSuperview()
        }
        
    }
}




