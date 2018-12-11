//
//  NotificationObject.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 12/11/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
struct  NotificationObject: Codable{
    var id = ""
    var type = ""
    var point = ""
    var title = ""
    var msg = ""
    
    init(id: String) {
        self.id = id
    }
}
