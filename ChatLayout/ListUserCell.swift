//
//  ListUserCell.swift
//  ChatLayout
//
//  Created by haipt on 11/8/16.
//  Copyright © 2016 haipt. All rights reserved.
//

import UIKit

class ListUserCell: UITableViewCell {
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var numOfMsgLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func loadData(userData: UserMsgModel) {
        userNameLbl.text = userData.name
        numOfMsgLbl.text = "\(userData.numOfMsg)"
    }

}
