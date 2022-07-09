//
//  PlacesCollectionViewCell.swift
//  Maps
//
//  Created by Ganesh Galla on 28/12/21.
//

import UIKit

class PlacesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var blurView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        placeImageView.layer.cornerRadius = 15
    }

}
