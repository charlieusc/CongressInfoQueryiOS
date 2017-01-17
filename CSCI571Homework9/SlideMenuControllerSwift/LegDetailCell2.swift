//
//  LegDetailCell2.swift
//  LegBillCom
//
//  Created by YangJialin on 11/25/16.
//  Copyright © 2016 YangJialin. All rights reserved.
//

import UIKit

class LegDetailCell2: UITableViewCell {
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DetailButton: UIButton!
    var url = String()
    @IBAction func DetailButtonClicked(_ sender: AnyObject){
        print(url)
        UIApplication.shared.openURL(NSURL(string: url)! as URL)
    }
}

