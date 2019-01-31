//
//  DrinkCell.swift
//  DetailList
//
//  Created by StanislavPM on 24/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

import UIKit

class DrinkCell: UITableViewCell {
    @IBOutlet weak var imageDrink: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var sugar: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
