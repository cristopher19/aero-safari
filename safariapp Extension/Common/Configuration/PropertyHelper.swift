//
//  PropertyHelper.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 12/6/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
struct PropertyHelper {
    static let PROP_FIRST_RUN =                           "aero.first.run"
    static let PROP_COLORBOX_FIRST_RUN_PREFIX =           "aero.colorbox.first.run."
    static let PROP_COLORBOX_FIRST_RUN_AMAZON =           "aero.colorbox.first.run.amazon"
    static let PROP_COLORBOX_FIRST_RUN_AMAZON_DETAILS =   "aero.colorbox.first.run.amazonDetails"
    static let PROP_COLORBOX_FIRST_RUN_EBAY =             "aero.colorbox.first.run.ebay"
    static let PROP_COLORBOX_FIRST_RUN_EBAY_DETAILS =     "aero.colorbox.first.run.ebayDetails"
    static let PROP_COLORBOX_FIRST_RUN_RAKUTEN =          "aero.colorbox.first.run.rakuten"
    static let PROP_COLORBOX_FIRST_RUN_AEROPOSTALE =         "aero.colorbox.first.run.aeropostale"
    static let PROP_COLORBOX_FIRST_RUN_AEROPOSTALE_DETAILS = "aero.colorbox.first.run.aeropostaleDetails"
    static let PROP_COLORBOX_FIRST_RUN_FOREVER21 =        "aero.colorbox.first.run.forever21"
    static let PROP_COLORBOX_FIRST_RUN_FOREVER21_DETAILS = "aero.colorbox.first.run.forever21Details"
    static let PROP_CLIENT_ID =                           "aero.client.id"
    static let PROP_SCHEMA_VERSION =                      "aero.schema.version"
    static let PROP_CLIENT_ALLOWED =                      "aero.client.allowed"
    static let PROP_TRACKED_INSTALL =                     "aero.tracked.install"
    static let PROP_FIRST_PREALERT =                      "aero.first.prealert"
    static let PROP_EXTENSION_VERSION =                   "aero.extension.version"
    static let PROP_CHECK_RECIPIENT =                     "aero.check.recipient"
    static let PROP_SIGNIN_REMEMBER =                     "aero.signin.remember"
    static let PROP_RESTRICT_JPG_INVOICE_UPLOAD =         "aero.restrict.jpg.invoice.upload"
    static let PROP_JPG_INVOICE_RESTRICTION_COUNTRIES =   "aero.jpg.invoice.restriction.countries"
    
    struct DEFAULT_PROPERTIES {
        static let PROP_FIRST_RUN =                            true
        static let PROP_COLORBOX_FIRST_RUN_AMAZON =            true
        static let PROP_COLORBOX_FIRST_RUN_AMAZON_DETAILS =    true
        static let PROP_COLORBOX_FIRST_RUN_EBAY =              true
        static let PROP_COLORBOX_FIRST_RUN_EBAY_DETAILS =      true
        static let PROP_COLORBOX_FIRST_RUN_RAKUTEN =           true
        static let PROP_COLORBOX_FIRST_RUN_AEROPOSTALE =       true
        static let PROP_COLORBOX_FIRST_RUN_AEROPOSTALE_DETAILS = true
        static let PROP_COLORBOX_FIRST_RUN_FOREVER21 =         true
        static let PROP_COLORBOX_FIRST_RUN_FOREVER21_DETAILS = true
        static let PROP_SCHEMA_VERSION =                       0
        static let PROP_CLIENT_ALLOWED =                       true
        static let PROP_TRACKED_INSTALL =                      false
        static let PROP_FIRST_PREALERT =                       true
        static let PROP_CHECK_RECIPIENT =                      true
        static let PROP_SIGNIN_REMEMBER =                      false
        static let PROP_RESTRICT_JPG_INVOICE_UPLOAD =          true
        static let PROP_JPG_INVOICE_RESTRICTION_COUNTRIES =    "EIS"
    }
}
