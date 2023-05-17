//
//  RecordModel.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation

struct RecordModel: Codable {
    var date: String // "yyyy-MM-dd HH:ss"
    var items: [DrinkModel]
}


let defaultReminder = ["08:00", "10:00", "12:00", "14:00", "16:00", "18:00", "20:00"]
