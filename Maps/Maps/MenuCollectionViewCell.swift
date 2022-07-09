//
//  MenuCollectionViewCell.swift
//  Maps
//
//  Created by Ganesh Galla on 28/12/21.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var menuButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        menuButton.layer.shadowColor = CGColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        menuButton.layer.shadowOpacity = 1
        menuButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        menuButton.layer.shadowRadius = 3
        menuButton.layer.cornerRadius = 8
    }

}
