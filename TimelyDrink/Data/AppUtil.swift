//
//  AppUtil.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

extension String {
    func width(with font: UIFont) -> CGFloat {
        let attribute = [NSAttributedString.Key.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let str = NSAttributedString(string: self, attributes: attribute)
        let rect = str.boundingRect(with: CGSize(width: .zero, height: 20), options: option, context: nil)
        return rect.width
    }
}

extension UIViewController {
    func alert(_ message: String) {
        let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        present(vc, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            vc.dismiss(animated: true)
        }
    }
}


extension Date {
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
}

extension UserDefaults {
    
    func setObject<T: Codable>(_ object: T?, forKey key: String) {
        let encoder = JSONEncoder()
        guard let object = object else {
            self.removeObject(forKey: key)
            return
        }
        
        guard let encoded = try? encoder.encode(object) else {
            return
        }
        
        self.setValue(encoded, forKey: key)
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        guard let object = try? decoder.decode(type, from: data) else {
            debugPrint("Counld'n find key")
            return nil
        }
        return object
    }
    
}
