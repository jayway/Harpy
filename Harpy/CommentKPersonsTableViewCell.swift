//
//  CommentKPersonsTableViewCell.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit
import IBAnimatable
class CommentKPersonsTableViewCell: UITableViewCell {
    @IBOutlet weak var commentLabel: AnimatableLabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var kPersons = [KPerson]()
    
    func setupCell(comment: String, kPersons: [KPerson]){
        self.kPersons = kPersons
        self.commentLabel.text = comment
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
