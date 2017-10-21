//
//  ProductTableViewCell.swift
//  LuanaRodrigo
//
//  Created by Rodrigo Luiz Cocate on 12/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var lbValue: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbState: UILabel!
    @IBOutlet weak var ivProductPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
