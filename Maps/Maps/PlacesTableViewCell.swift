//
//  PlacesTableViewCell.swift
//  Maps
//
//  Created by Ganesh Galla on 28/12/21.
//

import UIKit
import Gemini

class customCell:GeminiCell {
    
}

class PlacesTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var placesCollectionView: UICollectionView!
    var imageArray = [ #imageLiteral(resourceName: "NonVeg"),#imageLiteral(resourceName: "Veg"),#imageLiteral(resourceName: "IceCream"),#imageLiteral(resourceName: "Internet"),#imageLiteral(resourceName: "Recording"),#imageLiteral(resourceName: "Taj"),#imageLiteral(resourceName: "parks1"),#imageLiteral(resourceName: "Shopping mall")]
    var labelArray = ["NON-Veg restuarent","Vegetarian restuarent","Icecream Shops","Internet Cafes","Recording Studios","Historical Landmarks","Parks","Shopping Malls"]
    override func awakeFromNib() {
        super.awakeFromNib()
        placesCollectionView.register(UINib(nibName: "PlacesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PlacesCollectionViewCell")
        placesCollectionView.delegate = self
        placesCollectionView.dataSource = self
    }
    func configureAnimation()
    {
        collectionView.Gemini
            .scaleAnimation()
            .scale(0.75)
            .scaleEffect(.scaleUp)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        placesCollectionView.animateVisibleCells()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            self.placesCollectionView.animateCell(cell)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = placesCollectionView.dequeueReusableCell(withReuseIdentifier: "PlacesCollectionViewCell", for: indexPath) as! PlacesCollectionViewCell
        cell.placeImageView.image = imageArray[indexPath.row]
        cell.placeName.text = labelArray[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
           return CGSize(width: 100.0, height: 100.0)
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
