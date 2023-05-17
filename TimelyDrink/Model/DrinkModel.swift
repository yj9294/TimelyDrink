//
//  DrinkModel.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

struct DrinkModel: Codable {
    var day: String // yyyy-MM-dd
    var time: String // HH:mm
    var item: Item // 列别
    var name: String
    var ml: Int // 毫升
}

extension DrinkModel {
    
    enum Item: String, Codable, CaseIterable {
        case water, drinks, milk, coffee, tea, customization
        
        var title: String {
            self.rawValue.capitalized
        }
        
        var icon: UIImage {
            UIImage(named: "drink_\(self.rawValue)") ?? UIImage()
        }
    }
    
}

struct DrinkTotalModel: Codable {
    var day: String // yyyy-MM-dd
    var ml: Int // 毫升
    static let `default` = DrinkTotalModel(day: Date().day, ml: 0)
}

