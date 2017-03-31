//
//  AnswerButton.swift
//  Harpy
//
//  Created by Pär Majholm on 2017-03-31.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit

class AnswerButton: UIControl {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 15
        layer.borderWidth = 2
        self.tintColorDidChange()
    }
    
    override func tintColorDidChange() {
        layer.borderColor = tintColor.cgColor
        label.textColor = tintColor
    }
    
    class func instanceFromNib() -> AnswerButton? {
        let nibArray = Bundle.main.loadNibNamed("AnswerButton", owner:nil, options:nil)
        if let instance = nibArray?[0] as? AnswerButton {
            return instance;
        }
        return nil
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.borderColor = UIColor.purple.cgColor
            }
            else {
                layer.borderColor = tintColor.cgColor
            }
        }
    }
}
