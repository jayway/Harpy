//
//  BankIDActionTableViewCell.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-03-30.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit

protocol BankIDActionDelegate{
    func openBankID()
}

class BankIDActionTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    var delegate: BankIDActionDelegate!
    @IBAction func didPressOpenBankID(_ sender: Any) {
        delegate.openBankID()
        button.backgroundColor = UIColor(hexString: "F0F4F4")
        self.didTouchCancel(button)
    }
    
    @IBAction func didTouchDown(_ sender: Any) {
        button.backgroundColor = UIColor(hexString: "34353A").withAlphaComponent(0.6)
    }
    
    @IBAction func didTouchCancel(_ sender: Any) {
        button.backgroundColor = UIColor(hexString: "F0F4F4")
    }

}
