//
//  ButtonsView.swift
//  VKApp
//
//  Created by Maxim Safronov on 14.07.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit

class IncreaseButtonView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        path.lineWidth = 2.0
        path.move(to: CGPoint(x: 4, y: 11.5))
        path.addLine(to: CGPoint(x: 20, y: 11.5))
        
        path.move(to: CGPoint(x: 11.5, y: 4))
        path.addLine(to: CGPoint(x: 11.5, y: 20))
        
        path.close()
        UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7).setStroke()
        path.stroke()
    }
}
class DecreaseButtonView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        path.lineWidth = 2.0
        path.move(to: CGPoint(x: 4, y: 11.5))
        path.addLine(to: CGPoint(x: 20, y: 11.5))
        
        path.close()
        UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7).setStroke()
        path.stroke()
    }
}
