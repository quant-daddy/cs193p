//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Suraj Keshri on 5/14/17.
//  Copyright © 2017 Suraj Keshri. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var internalProgram = PropertyList()
    
    private var internalVariables: Dictionary<String,Double>?
    
    private var nf: Formatter {
        let displayFormatter = NumberFormatter()
        displayFormatter.maximumFractionDigits = 6
        displayFormatter.minimumFractionDigits = 0
        return displayFormatter
    }
    
    /// accumulator.1 tracks the string representation of the operands and operations before a binary operation.
    func setOperand(to operand: Double) {
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(variable named: String) {
        internalProgram.append(named as AnyObject)
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) ->
        (result: Double?, isPending: Bool, description: String) {
            internalVariables = variables
            var accumulator = (value: 0.0, description: "")
            var pending: PendingBinaryOperationInfo?
            for op in internalProgram {
                if let operand = op as? Double {
                    accumulator.0 = operand
                    accumulator.1 = nf.string(for: NSNumber(value: operand))!
                } else if let operationOrVar = op as? String {
                    if let _ = operations[operationOrVar] {
                        performOperation(symbol: operationOrVar, pending: &pending, accumulator: &accumulator)
                    }
                    else {
                        accumulator.1 = String(operationOrVar)
                        if let variableValue = internalVariables?[operationOrVar] {
                            accumulator.0 = variableValue
                        } else {
                            accumulator.0 = 0
                        }
                    }
                }
            }
            let description: String
            if pending != nil {
                 description = pending!.pendingDescription + accumulator.1
            } else {
                 description = accumulator.1
            }
            
            return (result: accumulator.0, isPending: pending != nil, description: description)
    }
    
    
    private func performOperation(symbol: String, pending: inout PendingBinaryOperationInfo?, accumulator: inout (value: Double,description: String)) {
        if let constant = operations[symbol] {
            switch constant {
            case .Constant(let associatedConstant):
                accumulator.0 = associatedConstant
                accumulator.1 = symbol
            case .UnaryOperation(let foo):
                accumulator.1 = symbol + "(" + accumulator.1 + ")"
                accumulator.0 = foo(accumulator.0)
            case .BinaryOperation(let foo):
                accumulator.1 = accumulator.1 + symbol
                executePendingBinaryOperation(pending: &pending, accumulator: &accumulator)
                pending = PendingBinaryOperationInfo(binaryFunction: foo, firstOperand: accumulator.0, pendingDescription: accumulator.1)
                /// accumulator.1 become empty after a binary operation.
                accumulator.1 = ""
            case .Equals:
                executePendingBinaryOperation(pending: &pending, accumulator: &accumulator)
            }
        }
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
    }
    
    private func executePendingBinaryOperation( pending: inout PendingBinaryOperationInfo?, accumulator: inout (value: Double,description: String)) {
        if pending != nil {
            accumulator.0 = pending!.binaryFunction(pending!.firstOperand, accumulator.0)
            accumulator.1 = pending!.pendingDescription + accumulator.1
            pending = nil
        }
    }
    
    typealias PropertyList = [AnyObject]
    
    
    ///
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            reset()
            for op in newValue {
                if let operand = op as? Double {
                    setOperand(to: operand)
                } else if let operation = op as? String {
                    performOperation(symbol: operation)
                }
            }
            
        }
    }
    
    /// constructed getter method which tells if a result is pending for binary operation.
    var resultIsPending: Bool {
        get {
            let evaluateResult = evaluate(using: internalVariables)
            return evaluateResult.isPending
        }
    }
    
    /// pendingDescription saves description until the binary operation. This is concatenated with later description when an Equals operation is encountered.
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var pendingDescription: String
    }
    
    /// A collection of mapping of string representation of operation and the actual function that implements that operation
    ///
    /// - Dictionary key: string representation of operation in the calculator
    /// - Dictionary value: the corresponding Operation enum type
    private var operations: Dictionary<String,Operations> = [
        "π": Operations.Constant(M_PI),
        "e": Operations.Constant(M_E),
        "cos": Operations.UnaryOperation(cos),
        "√": Operations.UnaryOperation(sqrt),
        "×": Operations.BinaryOperation({$0 * $1}),
        "÷": Operations.BinaryOperation({$0 / $1}),
        "+": Operations.BinaryOperation({$0 + $1}),
        "−": Operations.BinaryOperation({$0 - $1}),
        "=": Operations.Equals,
        "sin": Operations.UnaryOperation(sin),
        "tan": Operations.UnaryOperation(tan),
        "log": Operations.UnaryOperation(log),
        "%" : Operations.BinaryOperation({$0.truncatingRemainder(dividingBy: $1)}),
        "±" : Operations.UnaryOperation({-$0})
        ]
    
    /// A collection of parametrized types of operation supported
    private enum Operations {
        case Constant(Double)
        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    /// resets all the instance properties to initial value
    func reset() {
        internalProgram.removeAll()
    }
    
    /// returns the current result as (value, description)
    var result: (Double, String) {
        get {
            let evaluateResult = evaluate(using: internalVariables)
            return (evaluateResult.result!, evaluateResult.description)
        }
    }
}
