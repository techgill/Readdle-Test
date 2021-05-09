//
//  ChildListCollectionViewCell.swift
//  ReaddleTest
//
//  Created by Tech Gill on 08/05/21.
//

import UIKit

class ChildListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellBgView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func fillDetails(details: sheetDataModel){
        cellBgView.layer.cornerRadius = 6
        cellBgView.layer.borderWidth = 1.1
        cellBgView.layer.borderColor = UIColor.lightGray.cgColor
        nameLabel.text = details.itemName
        cellImageView.image = details.itemType == "d" ? UIImage(systemName: "folder") : UIImage(systemName: "newspaper")
    }
}
