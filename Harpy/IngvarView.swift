//
//  IngvarView.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-03-31.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit

class IngvarView: UIView {

    @IBOutlet weak var ingvarImage: UIImageView!
   
    class func instanceFromNib() -> IngvarView? {
        let nibArray = Bundle.main.loadNibNamed("IngvarView", owner:nil, options:nil)
        if let instance = nibArray?[0] as? IngvarView {
            return instance;
        }
        return nil
    }
    
    func startAnimating(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            UIView.setAnimationRepeatCount(3)
            self.ingvarImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (completed) in
            UIView.animate(withDuration: 3, animations: {
                self.ingvarImage.frame = CGRect(origin: CGPoint(x: self.frame.width/2, y: 0), size: CGSize(width: 0, height: 0))
                self.ingvarImage.alpha = 0
                self.alpha = 0
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }
    
        
    }

}
