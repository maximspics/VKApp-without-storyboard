//
//  UIBezierPath+Ext.swift
//  VKApp
//
//  Created by Maxim Safronov on 14.07.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
    }
}
