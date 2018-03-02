//
//  Stack.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct Stack<Element> {
    fileprivate var items = [Element]()
    fileprivate var limit:Int
    
    init(limit:Int) {
        self.limit = limit
    }
    
    mutating func push(_ item:Element) {
        if items.count == limit {
            items.removeFirst()
        }
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    func peek() -> Element? {
        return items.last
    }
    
    func size() -> Int {
        return items.count
    }
    
    mutating func clearAll() {
        items.removeAll()
    }
}
