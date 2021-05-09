//
//  ListTableViewCell.swift
//  ReaddleTest
//
//  Created by Tech Gill on 06/05/21.
//

import UIKit

class RootListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillDetails(details: sheetDataModel){
        nameLabel.text = details.itemName
    }

}
