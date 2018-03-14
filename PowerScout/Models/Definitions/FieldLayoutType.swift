//
//  FieldLayoutType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation
import UIKit

enum FieldLayoutType: Int {
    case blueRed = 0, redBlue
    
    mutating func reverse() {
        self = self == .blueRed ? .redBlue : .blueRed
    }
    
    func getImage() -> UIImage {
        return self == .blueRed ? UIImage(named: "fieldLayoutBlueRed")! : UIImage(named: "fieldLayoutRedBlue")!
    }
}
