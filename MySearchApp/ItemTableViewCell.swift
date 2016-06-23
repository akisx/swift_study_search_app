//
//  ItemTableViewCell.swift
//  MySearchApp
//
//  Created by inoue on 2016/06/22.
//  Copyright © 2016年 inoue. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLable: UILabel!
    
    var itemUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        itemImageView.image = nil
    }
    
}
