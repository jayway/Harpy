//
//  CommentKPersonsTableViewCell.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit
import IBAnimatable
class CommentKPersonsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var commentLabel: AnimatableLabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var kPersons = [KPerson]()
    
    func setupCell(comment: String, kPersons: [KPerson]){
        self.kPersons = kPersons
        self.commentLabel.text = comment
        self.collectionView.reloadData()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kPersons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "KPerson", for: indexPath) as! KPersonCollectionViewCell
        let kPerson = kPersons[indexPath.row]
        cell.nameLabel.text = kPerson.name
        cell.officeLabel.text = kPerson.office
        return cell
    }

}
