//
//  WaitingTableViewCell.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-03-30.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit

class WaitingTableViewCell: UITableViewCell {
    @IBOutlet weak var pageControl: UIPageControl!
    var timer: Timer?
    var currentPage = 0
    func setup(){
        currentPage = 0
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = 3
        self.startAnimation()
    }
    
    private func startAnimation(){
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (timer) in
            self.currentPage += 1
            if self.currentPage == 3{
                self.currentPage = 0
            }
            self.pageControl.currentPage = self.currentPage
        })
    }

}
