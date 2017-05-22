//
//  GraphUIViewController.swift
//  calculator
//
//  Created by Suraj Keshri on 5/20/17.
//  Copyright © 2017 Suraj Keshri. All rights reserved.
//

import UIKit

@IBDesignable
class GraphUIViewController: UIViewController {
    
    public var functionToDraw: ((Double)->Double) = sin {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet private weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.changeScale(recognizer:))))
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: graphView, action: #selector(graphView.handlePan(recognizer:)))
            panGestureRecognizer.maximumNumberOfTouches = 1
            panGestureRecognizer.minimumNumberOfTouches = 1
            graphView.addGestureRecognizer(panGestureRecognizer)
            
            let tapGestureRcognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.handleTap(recognizer:)))
            tapGestureRcognizer.numberOfTapsRequired = 2
            tapGestureRcognizer.numberOfTouchesRequired = 1
            graphView.addGestureRecognizer(tapGestureRcognizer)
            
            updateUI()
        }
    }
    
    private func updateUI() {
        graphView.getYUnit = functionToDraw
    }
    
}
