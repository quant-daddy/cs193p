//
//  ViewController.swift
//  calculator
//
//  Created by Suraj Keshri on 5/13/17.
//  Copyright © 2017 Suraj Keshri. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var info: UILabel!
    
    @IBOutlet weak var mDisplay: UILabel!
    
    public var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
    private var nf: Formatter {
        let displayFormatter = NumberFormatter()
        displayFormatter.maximumFractionDigits = 6
        displayFormatter.minimumFractionDigits = 0
        return displayFormatter
    }
    
    var savedProgram = CalculatorBrain.PropertyList()
    
    var variables = Dictionary<String,Double>()
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set{
            display.text = nf.string(for: NSNumber(value: newValue))
        }
    }
    
    private func updateDisplayUsing(output: (result: Double?, isPending: Bool,description: String)) {
        
        if output.isPending {
            info.text = output.description + "..."
        } else {
            info.text = output.description + "="
        }
        
        displayValue = output.result ?? 0.0
        
        if variables["M"] != nil {
            mDisplay.text = String(describing: variables["M"]!)
        } else {
            mDisplay.text = " "
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!;
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        print("touched \(digit)")
    }
    
    @IBAction func save() {
        savedProgram = brain.program
        print("touched save")
    }
    
    @IBAction func restore() {
        brain.program = savedProgram
        updateDisplayUsing(output: brain.evaluate(using: variables))
        print("touched restore")
    }
    
    @IBAction func rand() {
        let randnum = Double(arc4random())/Double(UInt32.max)
        display.text = nf.string(for: NSNumber(value: randnum))
        userIsInTheMiddleOfTyping = true
        print("touched rand")
    }
    @IBAction func evaluateWithM() {
        variables["M"] = displayValue
        updateDisplayUsing(output: brain.evaluate(using: variables))
        userIsInTheMiddleOfTyping = false
        print("touched ->M")
    }
    
    @IBAction func setVariable() {
        brain.setOperand(variable: "M")
        updateDisplayUsing(output: brain.evaluate(using: variables))
        userIsInTheMiddleOfTyping = false
        print("touched M")
    }
    
    @IBAction func backspace() {
        var textCurrentlyInDisplay = display.text!
        if textCurrentlyInDisplay != " " {
            textCurrentlyInDisplay.remove(at: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
            if textCurrentlyInDisplay.isEmpty {
                display.text = " "
                userIsInTheMiddleOfTyping = false
            } else {
                display.text = textCurrentlyInDisplay
            }
        } else {
            savedProgram = brain.program
            print("\(savedProgram)")
            if savedProgram.count > 0 {
                savedProgram.remove(at: savedProgram.index(before: savedProgram.endIndex))
                brain.program = savedProgram
                updateDisplayUsing(output: brain.evaluate(using: variables))
            }
        }
        print("touched backspace")
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        let digit = sender.currentTitle!
        print("touched \(digit)")
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(to: displayValue)
        }
        
        userIsInTheMiddleOfTyping = false
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        updateDisplayUsing(output: brain.evaluate(using: variables))
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain.reset()
        info.text = " "
        userIsInTheMiddleOfTyping = false
        display.text = " "
        variables = [:]
        mDisplay.text = " "
        print("touched reset")
    }
}
