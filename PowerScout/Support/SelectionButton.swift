//
//  SelectionButton.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/5/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

@IBDesignable
class SelectionButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var selectedColor = UIColor.orange
    
    override var isSelected : Bool {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor.black
                //self.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
                //self.setTitleColor(UIColor(red: 1.0, green: 0.35, blue: 0, alpha: 1.0), forState: .Normal)
                self.setTitleColor(selectedColor, for: .selected)
                self.setTitleColor(UIColor.darkGray, for: .disabled)
            } else {
                self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                //self.titleLabel?.font = UIFont.systemFontOfSize(18.0)
                self.setTitleColor(UIColor.white, for: UIControlState())
                self.setTitleColor(UIColor.darkGray, for: .disabled)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initLayers()
    }
    
    override func awakeFromNib() {
        self.initLayers()
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.setTitleColor(UIColor.darkGray, for: .disabled)
    }
    
    func initLayers() {
        self.tintColor = UIColor.clear
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).cgColor
        self.selectedColor = self.titleColor(for: UIControlState())!
    }
    
    

}
