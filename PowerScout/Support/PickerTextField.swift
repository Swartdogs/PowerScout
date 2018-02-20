//
//  PickerTextField.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 2/20/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import UIKit

class PickerTextField: UITextField {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
