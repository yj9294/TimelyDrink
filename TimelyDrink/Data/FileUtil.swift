//
//  FileUtil.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UserNotifications

class FileUtil: NSObject {
    
    static let shared = FileUtil()
    
    private var recordDrinks: [DrinkModel] = UserDefaults.standard.getObject([DrinkModel].self, forKey: .drinks) ?? []
    
    private var totalDrinks: DrinkTotalModel = UserDefaults.standard.getObject(DrinkTotalModel.self, forKey: .totalDrinks) ?? .default

    private var reminderList: [String] = UserDefaults.standard.getObject([String].self, forKey: .reminder) ?? []
}

extension FileUtil {
    
    func addDrinks(model: DrinkModel) {
        recordDrinks.append(model)
        UserDefaults.standard.setObject(recordDrinks, forKey: .drinks)
        NotificationCenter.default.post(name: .drinks, object: nil)
    }
    
    func getDrinks() -> [DrinkModel] {
        return recordDrinks
    }
    
    func setTotalML(ml: Int) {
        let model = DrinkTotalModel(day: Date().day, ml: ml)
        totalDrinks = model
        UserDefaults.standard.setObject(model, forKey: .totalDrinks)
    }
    
    func getTotalML() -> Int {
        if totalDrinks.day == Date().day {
            return totalDrinks.ml
        } else {
            return 0
        }
    }
    
    func getReminderList() -> [String] {
        return reminderList
    }
    
    func deleteReminder(_ reminder: String?) {
        reminderList = reminderList.filter({ it in
            return it != reminder
        })
        UserDefaults.standard.setObject(reminderList, forKey: "reminder")
    }
    
    func appendReminder(_ reminder: String) {
        if let index = reminderList.firstIndex(of: reminder) {
            reminderList[index] = reminder
        } else {
            reminderList.append(reminder)
        }
        UserDefaults.standard.setObject(reminderList, forKey: "reminder")
    }

}

extension FileUtil {
    
    func getTodayDrinks() -> Int {
        recordDrinks.filter { model in
            model.day == Date().day
        }.map({
            $0.ml
        }).reduce(0, +)
    }
    
    // 06:00 12:00 18:00 24:00
    func getTimeTotalDrinks(time: String) -> Int {
        recordDrinks.filter { model in
            let modelTime = model.time.components(separatedBy: ":").first ?? "00"
            let nowTime = time.components(separatedBy: ":").first ?? "00"
            return Date().day == model.day && (Int(modelTime)! >= Int(nowTime)! - 6) && (Int(modelTime)! < Int(nowTime)!)
        }.map({
            $0.ml
        }).reduce(0, +)
    }
    
    // weeks contains: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    func getWeekTotalDrinks(weeks: String) -> Int {
        // 当前搜索目的周几
        let week = ChartModel.Item.allCases.filter {
            $0 == .week
        }.first?.unit.firstIndex(of: weeks) ?? 0
        
        // 当前日期 用于确定当前周
        let weekDay = Calendar.current.component(.weekday, from: Date())
        let firstCalendar = Calendar.current.date(byAdding: .day, value: 1-weekDay, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
                
        // 目标日期
        let target = Calendar.current.date(byAdding: .day, value: week, to: firstCalendar) ?? Date()
        let targetString = dateFormatter.string(from: target)
        
        return recordDrinks.filter { model in
            model.day == targetString
        }.map({
            $0.ml
        }).reduce(0, +)
    }
    
    // day eg: 04/14 04/15 .... 05/12 05/13
    func getMonthTotalDrinks(date: String) -> Int {
        let year = Calendar.current.component(.year, from: Date())
        
        let month = date.components(separatedBy: "/").first ?? "01"
        let day = date.components(separatedBy: "/").last ?? "01"
        
        let ret = recordDrinks.filter { model in
            return model.day == "\(year)-\(month)-\(day)"
        }.map({
            $0.ml
        }).reduce(0, +)
        
        return ret
    }
    
    // month eg: 06/2022 07/2022 08/2022 .... 04/2022 05/2022
    func getYearTotalDrinks(date: String) -> Int {
        
        let month = date.components(separatedBy: "/").first ?? "01"
        let year = date.components(separatedBy: "/").last ?? "01"
        
        let ret = recordDrinks.filter { model in
            let dateArray = model.day.components(separatedBy: "-")
            return "\(dateArray[0])-\(dateArray[1])" == "20\(year)-\(month)"
        }.map({
            $0.ml
        }).reduce(0, +)
        
        return ret
    }
    
}

extension Notification.Name {
    static let drinks = Notification.Name(rawValue: "drinks")
}

extension String {
    static let reminder = "reminder"
    static let totalDrinks = "drinks.total"
    static let drinks = "drinks"
}
