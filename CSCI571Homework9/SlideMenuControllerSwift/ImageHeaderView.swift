//
//  ImageHeaderCell.swift
//  SlideMenuControllerSwift
//

import UIKit

class ImageHeaderView : UIView {
    
    @IBOutlet weak var backgroundImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(hex: "E0E0E0")
    }
}
