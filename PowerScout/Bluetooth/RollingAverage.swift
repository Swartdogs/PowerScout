//
//  RollingAverage.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 2/14/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

public struct RollingAverage {
    public let size: Int
    private var values: [Double]
    
    public var average:Double {
        var sum = 0.0
        for v in values {
            sum += v
        }
        return sum / Double(min(size, values.count))
    }
    
    public init(withSize size: Int) {
       self.size = size
       self.values = []
    }
    
    public mutating func addValue(_ value: Double) {
        self.values.append(value)
        if values.count > size {
            values.remove(at: 0)
        }
    }
    
    public mutating func reset() {
        self.values.removeAll()
    }
}
