//
//  CommitteeDetailViewController.swift
//  SlideMenuControllerSwift
//
//  Created by YangJialin on 11/28/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit

class CommitteeDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var TextField: UITextView!
    
    @IBOutlet weak var DetailTable: UITableView!
    
    var com = [String : String]()
    var keys = ["ID", "Parent ID", "Chamber", "Office", "Contact"]
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        TextField.text = com["Name"]
        setRightNavButton("save")
    }
    
    override func viewDidLoad() {
        self.title = "Committee Details"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = keys[indexPath.row]
        var detail = com[title]
        
        if detail == nil {
            detail = "N.A"
        }
        var cell = Bundle.main.loadNibNamed("LegDetailCell", owner: self, options: nil)?.first as! LegDetailCell
        cell.DetailLabel?.text = detail
        cell.TitleLabel?.text = title
        cell.setNeedsLayout() //invalidate current layout
        cell.layoutIfNeeded() //update immediately
        return cell
    }
    
    public func setRightNavButton(_ type: String) {
        var coms = defaults.array(forKey: "coms") as? [[String : String]]
        var found = false
        if (coms?.count)! >= 1 {
            for i in 0...(coms?.count)!-1 {
                if (coms?[i]["ID"] == com["ID"]) {
                    found = true
                }
            }
        }
        
        if(type == "save" && found == false) {
            let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Star"), style: UIBarButtonItemStyle.done, target: self, action: #selector(saveToLocal))
            navigationItem.rightBarButtonItem = rightButton
        } else {
            let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Star_Filled"), style: UIBarButtonItemStyle.done, target: self, action: #selector(deleteFromLocal))
            navigationItem.rightBarButtonItem = rightButton
        }
        
        
    }
    func saveToLocal() {
        var coms = defaults.array(forKey: "coms") as? [[String : String]]
        var found = false
        if (coms?.count)! >= 1 {
            for i in 0...(coms?.count)!-1 {
                if (coms?[i]["ID"] == com["ID"]) {
                    found = true
                }
            }
        }
        if (found == false) {
            coms?.append(com)
        }
        defaults.set(coms, forKey: "coms")
        setRightNavButton("delete")
        print ("saved to local")
        print (coms)
        
    }
    func deleteFromLocal() {
        
        var coms = defaults.array(forKey: "coms") as? [[String : String]]
        if (coms?.count)! >= 1 {
            for i in 0...(coms?.count)!-1 {
                if (coms?[i]["ID"] == com["ID"]) {
                    coms?.remove(at: i)
                    break
                }
            }
        }
        defaults.set(coms, forKey: "coms")
        setRightNavButton("save")
        print ("deleted from local")
        print (coms)
    }

}
