//
//  BaseVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit
import SnapKit

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        addApplicationNotification()
    }

}

extension BaseVC {
    
    func addApplicationNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.willEnterForground()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self]_ in
            self?.didEnterBackground()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.keyboardWillHidden()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: .main) {[weak self] _ in
            self?.keyboardWillShow()
        }
    }
    
}



extension BaseVC {
    
    @objc func back() {
        guard let navigationController = navigationController, navigationController.viewControllers.count != 1 else {
            dismiss(animated: true)
            return
        }
        navigationController.popViewController(animated: true)
    }
    
    @objc func setupUI() {
        view.backgroundColor = .white
    }
    
    @objc func setupNavigation() {
        if (navigationController?.viewControllers.count ?? 1) > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "common_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        }
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
    }
    
    @objc func willEnterForground() {
    }
    
    @objc func didEnterBackground() {
    }
    
    @objc func keyboardWillShow() {
    }
    
    @objc func keyboardWillHidden() {
    }
    
    @objc func removeTabbarGesture() {
        tabBarController?.view.gestureRecognizers?.forEach({
            tabBarController?.view.removeGestureRecognizer($0)
        })
    }
    
    @objc func addTabbarGesture() {
        if let tabController = tabBarController as? BaseTabbarController {
            tabController.view.gestureRecognizers?.forEach({
                tabController.view.removeGestureRecognizer($0)
            })
            tabController.view.addGestureRecognizer(tabController.panGesture)
        }
    }
    
}
