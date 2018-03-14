//
//  PropertyListReadable.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

protocol PropertyListReadable {
    func propertyListRepresentation() -> NSDictionary
    init?(propertyListRepresentation:NSDictionary?)
}
