//
//  ProgressView.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class CircleProgressView: UIView {
    var staticLayer: CAShapeLayer!
    var arcLayer: CAShapeLayer!
    
    var progress = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: Int) {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if staticLayer == nil {
            staticLayer = createLayer(1000, UIColor(named: "#C9B5D1")!)
        }
        self.layer.addSublayer(staticLayer)
        if arcLayer != nil {
            arcLayer.removeFromSuperlayer()
        }
        arcLayer = createLayer(self.progress, UIColor(named: "#9062FF")!)
        self.layer.addSublayer(arcLayer)
    }
    
    private func createLayer(_ progress: Int, _ color: UIColor) -> CAShapeLayer {
        let endAngle = (CGFloat.pi * 1.5) * CGFloat(progress) / 1000 + CGFloat.pi / 2.0 + CGFloat.pi / 4.0
        let layer = CAShapeLayer()
        layer.lineWidth = 6
        layer.strokeColor = color.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        let radius = self.bounds.width / 2 - layer.lineWidth
        let path = UIBezierPath.init(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: radius, startAngle: CGFloat.pi / 2.0 + CGFloat.pi / 4.0, endAngle: endAngle, clockwise: true)
        layer.path = path.cgPath
        return layer
    }

}

