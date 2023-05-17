//
//  BaseNavigationController.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    var rootViewController: UIViewController? = nil
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.rootViewController = rootViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var swipeBackManager: SwipeBackManager = {
        let manager = SwipeBackManager(controller: self)
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPanGes()
    }
    
    func addPanGes() {
        interactivePopGestureRecognizer?.delegate = self.swipeBackManager
    }

}

class SwipeBackManager: NSObject, UIGestureRecognizerDelegate {
    
    weak var controller: UINavigationController?
    
    init(controller: UINavigationController?) {
        self.controller = controller
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let controller = self.controller else { return false }
        if gestureRecognizer == controller.interactivePopGestureRecognizer {
            return controller.viewControllers.count > 1
        }
        return true
    }
}
