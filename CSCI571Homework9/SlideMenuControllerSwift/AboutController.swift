//
//  AboutController.swift
//  SlideMenuControllerSwift
//

import UIKit



class AboutController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLegNavigationBarItem()
        self.title = "About"
    }
}
