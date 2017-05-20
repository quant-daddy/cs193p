//
//  GraphView.swift
//  calculator
//
//  Created by Suraj Keshri on 5/20/17.
//  Copyright © 2017 Suraj Keshri. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var color: UIColor = UIColor(displayP3Red: 0, green: 0, blue: 1, alpha: 1)
    private var axesDrawer = AxesDrawer()
    
    private var pointsPerUnit = CGFloat(integerLiteral: 50)

    override func draw(_ rect: CGRect) {
        let origin = CGPoint(x: rect.midX, y: rect.midY)
        axesDrawer.drawAxes(in: rect, origin: origin, pointsPerUnit: pointsPerUnit)
    }

}
