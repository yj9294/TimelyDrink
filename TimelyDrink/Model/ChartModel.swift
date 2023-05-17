//
//  ChartModel.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation

struct ChartModel: Codable {
    var displayProgerss: CGFloat = 0.0
    var progress: CGFloat
    var totalML: Int
    var unit: String // 描述 类似 9:00 或者 Mon  或者03/01 或者 Jan
}


extension ChartModel {
    
    enum Item: String, CaseIterable, Codable {
        case day, week, month, year
        
        var unit: [String] {
            switch self {
            case .day:
                return ["6:00", "12:00", "18:00", "24:00"]
            case .week:
                return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            case .month:
                var days: [String] = []
                for index in 0..<30 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd"
                    let date = Date(timeIntervalSinceNow: TimeInterval(index * 24 * 60 * 60 * -1))
                    let day = formatter.string(from: date)
                    days.insert(day, at: 0)
                }
                return days
            case .year:
                var months: [String] = []
                for index in 0..<12 {
                    
                    let d = Calendar.current.date(byAdding: .month, value: -index, to: Date()) ?? Date()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/yy"
                    let day = formatter.string(from: d)
                    months.insert(day, at: 0)
                }
                return months
            }
        }
    }
    
}
