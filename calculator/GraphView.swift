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

    var color: UIColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1)
    
    @IBInspectable
    var pointsPerUnit = CGFloat(integerLiteral: 50) { didSet{setNeedsDisplay()} }
    
    
    private var axesDrawer: AxesDrawer { return AxesDrawer(color: color, contentScaleFactor: contentScaleFactor)
    }
    
    private var originTranslation = CGPoint()
    
    private var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    private var defaultOrigin: CGPoint {
        get {
            return CGPoint(x: self.bounds.origin.x+self.bounds.width/2, y: self.bounds.origin.y+self.bounds.height/2)
        }

    }
    
    var getYUnit: ((Double)->Double)! { didSet {setNeedsDisplay()} }
    
    override func draw(_ rect: CGRect) {
        
        axesDrawer.drawAxes(in: rect, origin: origin ?? defaultOrigin, pointsPerUnit: pointsPerUnit)
        
        if getYUnit != nil {
            
            func evaluateFuncAt(_ xValue: CGFloat, withOrigin origin: CGPoint) -> CGFloat {
                let xUnit = Double((xValue - origin.x)/pointsPerUnit)
                let yUnit = getYUnit(xUnit)
                return origin.y - CGFloat(yUnit*Double(pointsPerUnit))
            }
            
            let path = UIBezierPath()
            var xValue = rect.minX
            var moveFlag = true
            while xValue.isLess(than: rect.maxX) {
                let yValue = evaluateFuncAt(xValue, withOrigin: origin ?? defaultOrigin)
                if let pointToPlotAligned = CGPoint(x: xValue, y: yValue).aligned(inside: rect, usingScaleFactor: contentScaleFactor) {
                    if moveFlag {
                        path.move(to: pointToPlotAligned)
                    } else {
                        path.addLine(to: pointToPlotAligned)
                    }
                    moveFlag = false
                } else {
                    moveFlag = true
                }
                xValue = xValue + CGFloat(1)/contentScaleFactor
            }
            path.stroke()
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            pointsPerUnit *= recognizer.scale
            recognizer.scale = 1
        default:
            break
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state{
        case .changed, .ended:
            originTranslation = originTranslation.added(to: recognizer.translation(in: self))
            origin = defaultOrigin.added(to: originTranslation)
            recognizer.setTranslation(CGPoint(), in: self)
        default:
            break
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            origin = recognizer.location(in: self)
        default:
            break
        }
    }
}

private extension CGPoint
{
    func aligned(inside bounds: CGRect? = nil, usingScaleFactor scaleFactor: CGFloat = 1.0) -> CGPoint?
    {
        func align(_ coordinate: CGFloat) -> CGFloat {
            return round(coordinate * scaleFactor) / scaleFactor
        }
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = bounds, !permissibleBounds.contains(point) {
            return nil
        }
        return point
    }
    func added(to point: CGPoint)->CGPoint {
        var newPoint = CGPoint()
        newPoint.x = self.x + point.x
        newPoint.y = self.y + point.y
        return newPoint
    }
}
