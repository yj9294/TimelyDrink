//
//  FirebaseUtil.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import Firebase

class FirebaseUtil: NSObject {
    
    enum Property: String {
        case local = "qw"
        var first: Bool {
            return true
        }
    }
    
    enum Event: String {
        case open = "qw"
        case openCold = "qe"
        case openHot = "qr"
        case drinkSettin = "qu"
        case drinkRecord = "qi"
        case recordBack = "qp"
        case recordConfirm = "we"
        case historyRecord = "wr"
        case newReminder = "wmm"
        case reminderCancel = "wt"
        case reminderConfirm = "wy"
        
        var first: Bool {
            if self == .open {
                return true
            }
            return false
        }
    }
    
    class func log(event: Event, params: [String: Any]? = nil) {
        var params = params
        if event.first {
            if UserDefaults.standard.string(forKey: event.rawValue) != nil {
                params = ["counry": UserDefaults.standard.string(forKey: event.rawValue)!]
                return
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: event.rawValue)
                params = ["country": Locale.current.regionCode ?? "us"]
            }
        }
        #if DEBUG
        #else
        Analytics.logEvent(event.rawValue, parameters: params)
        #endif
        
        NSLog("[Event] \(event.rawValue) \(params ?? [:])")
    }
    
    class func log(property: Property, value: String? = nil) {
        var value = value
        if property.first {
            if UserDefaults.standard.string(forKey: property.rawValue) != nil {
                value = UserDefaults.standard.string(forKey: property.rawValue)!
                return
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: property.rawValue)
                value = Locale.current.regionCode ?? "us"
            }
        }
#if DEBUG
#else
        Analytics.setUserProperty(value, forName: property.rawValue)
#endif
        NSLog("[Property] \(property.rawValue) \(value ?? "")")
    }
}
