//
//  SafariExtensionViewController.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/2/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
