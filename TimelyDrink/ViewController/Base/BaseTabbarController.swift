//
//  BaseTabbarController.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class BaseTabbarController: UITabBarController {
    
    lazy var panGesture: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognize))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
}

extension BaseTabbarController {
    
    @objc func panGestureRecognize(pan: UIPanGestureRecognizer) {
        if transitionCoordinator != nil {
            return
        }
        
        if pan.state == .began || pan.state == .changed {
            beginInteractiveTransitionIfPossible(sender: pan)
        }
    }
    
    func beginInteractiveTransitionIfPossible(sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        if point.x > 0, selectedIndex > 0 {
            selectedIndex -= 1
        } else if point.x < 0, selectedIndex + 1 < (viewControllers?.count ?? 0) {
            selectedIndex += 1
        } else {
            if !CGPointEqualToPoint(point, .zero) {
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }
        transitionCoordinator?.animateAlongsideTransition(in: view, animation: { _ in
            
        }, completion: { ctx in
            if ctx.isCancelled, sender.state == .changed {
                self.beginInteractiveTransitionIfPossible(sender: sender)
            }
        })
    }
    
}

extension BaseTabbarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if panGesture.state == .began || panGesture.state == .changed {
            if (viewControllers?.firstIndex(of: toVC) ?? 0) > (viewControllers?.firstIndex(of: fromVC) ?? 0) {
                return TabBarTransitionAnimation(targetEdge: .left)
            } else {
                return TabBarTransitionAnimation(targetEdge: .right)
            }
        }
        return nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if panGesture.state == .began || panGesture.state == .changed {
            return TabBarTransitionController(gestureRecognizer: panGesture)
        }
        return nil
    }
    
}

class TabBarTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var targetEdge: UIRectEdge
    
    init(targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from) else {return}
        guard let toVC = transitionContext.viewController(forKey: .to) else {return}
        guard let fromView = transitionContext.view(forKey: .from) else {return }
        guard let toView = transitionContext.view(forKey: .to) else {return}
        let fromFrame = transitionContext.initialFrame(for: fromVC)
        let toFrame = transitionContext.finalFrame(for: toVC)
        var offset: CGVector = .zero
        if targetEdge == .left {
            offset = CGVectorMake(-1.0, 0.0)
        } else if targetEdge == .right {
            offset = CGVector(dx: 1.0, dy: 0.0)
        } else {
            assert(false, "targetEdge must be one of UIRectEdgeLeft, or UIRectEdgeRight.")
        }
        
        fromView.frame = fromFrame
        toView.frame = CGRectOffset(toFrame, toFrame.size.width * offset.dx * -1, toFrame.size.height * offset.dy * -1)
        transitionContext.containerView.addSubview(toView)
        let transitionDuration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: transitionDuration) {
            fromView.frame = CGRectOffset(fromFrame, fromFrame.size.width * offset.dx, fromFrame.size.height * offset.dy)
            toView.frame = toFrame
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}

class TabBarTransitionController: UIPercentDrivenInteractiveTransition {
    
    var gestureRecognizer: UIPanGestureRecognizer
    
    var transitionContext: UIViewControllerContextTransitioning? = nil
    
    var initialTranslationInContainerView: CGPoint = .zero
    
    init(gestureRecognizer: UIPanGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
        super.init()
        self.gestureRecognizer.addTarget(self, action: #selector(gestureRecognizeDidUpdate))
    }
    
    deinit {
        self.gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext;
        self.initialTranslationInContainerView = self.gestureRecognizer.translation(in: transitionContext.containerView)
        super.startInteractiveTransition(transitionContext)
    }
     
    func percentForGesture(gesture: UIPanGestureRecognizer) -> CGFloat {
        guard let transitionContainerView = transitionContext?.containerView else {return 0.0}
        let translation = gesture.translation(in: gesture.view?.superview)
        if (translation.x > 0.0 && initialTranslationInContainerView.x < 0.0) || (translation.x < 0 && initialTranslationInContainerView.x > 0.0) {
            return -1.0
        }
        return abs(translation.x)/CGRectGetWidth(transitionContainerView.bounds)
    }
    
    @objc func gestureRecognizeDidUpdate(gestureRecognizer :UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            break;
        case .changed:
            if self.percentForGesture(gesture: gestureRecognizer) < 0.0 {
                cancel()
                self.gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate))
            } else {
                update(self.percentForGesture(gesture: gestureRecognizer))
            }
        case .ended:
            if self.percentForGesture(gesture: gestureRecognizer) > 0.4 {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }
    
}
