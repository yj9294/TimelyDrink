//
//  HomeVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import AppTrackingTransparency
import UIKit

class HomeVC: BaseTabbarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .white
        viewControllers = [setupNavigationController(.drink), setupNavigationController(.chart), setupNavigationController(.reminder)]
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            ATTrackingManager.requestTrackingAuthorization { _ in
            }
        }
    }
    
}

extension HomeVC {
    
    func setupNavigationController(_ index: HomeItem) -> UINavigationController {
        let vc = index.controller
        let navigation = BaseNavigationController(rootViewController: vc)
        navigation.tabBarItem = UITabBarItem(title: nil, image: index.image, selectedImage: index.selectedImage)
        navigation.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        return navigation
    }
    
}

enum HomeItem: String {
    case drink, chart, reminder
    
    var controller: UIViewController {
        switch self {
        case .drink:
            return DrinkVC()
        case .chart:
            return ChartVC()
        case .reminder:
            return ReminderVC()
        }
    }
    
    var image: UIImage? {
        return UIImage(named: "home_\(self.rawValue)")?.withRenderingMode(.alwaysOriginal)
    }
    
    var selectedImage: UIImage? {
        return UIImage(named: "home_\(self.rawValue)_selected")?.withRenderingMode(.alwaysOriginal)
    }
}
