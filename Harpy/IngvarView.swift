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
        let bigScale: CGFloat = 0.4
        let bubbleDuration: TimeInterval = 0.4
        let ingvarRemoveDuration: TimeInterval = 0.5
        let removeDuration: TimeInterval = 0.5

        UIView.animate(withDuration: bubbleDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.ingvarImage.transform = CGAffineTransform(scaleX: bigScale, y: bigScale)
        }) { (completed) in
            UIView.animate(withDuration: bubbleDuration, delay: 0, options: [.curveEaseInOut], animations: {
                self.ingvarImage.transform = CGAffineTransform.identity
            }) { (completed) in
                UIView.animate(withDuration: bubbleDuration, delay: 0, options: [.curveEaseInOut], animations: {
                    self.ingvarImage.transform = CGAffineTransform(scaleX: bigScale, y: bigScale)
                }) { (completed) in
                    UIView.animate(withDuration: bubbleDuration, delay: 0, options: [.curveEaseInOut], animations: {
                        self.ingvarImage.transform = CGAffineTransform.identity
                    }) { (completed) in
                        UIView.animate(withDuration: ingvarRemoveDuration, delay: 0, options: [.curveEaseOut], animations: {
                            self.ingvarImage.frame = CGRect(origin: CGPoint(x: self.frame.width/2, y: -self.ingvarImage.frame.size.height), size: CGSize(width: 0, height: 0))
                            self.ingvarImage.alpha = 0
                        }, completion: nil)
                        UIView.animate(withDuration: removeDuration, delay: 0.5, options: [.curveEaseOut], animations: {
                            self.alpha = 0
                        }, completion: { (completed) in
                            self.removeFromSuperview()
                        })
                    }
                }
            }
        }
    
        
    }

}
