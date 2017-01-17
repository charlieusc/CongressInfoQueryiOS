//
//  BillsDetailViewController.swift
//  SlideMenuControllerSwift
//
//  Created by YangJialin on 11/28/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit

class BillsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var TextField: UITextView!
    
    @IBOutlet weak var DetailTable: UITableView!
    
    var bill = [String : String]()
    var keys = ["Bill ID", "Bill Type", "Sponsor", "Last Action", "PDF", "Chamber", "Last Vote", "Status"]
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        TextField.text = bill["Official Title"]
        setRightNavButton("save")
    }
    
    override func viewDidLoad() {
        self.title = "Bill Details"
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.keys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = keys[indexPath.row]
        var detail = bill[title]
    
        if detail == nil {
            detail = "N.A"
        }
        if ((title == "PDF") && detail != "N.A") {
    
            var cell = Bundle.main.loadNibNamed("LegDetailCell2", owner: self, options: nil)?.first as! LegDetailCell2
            var urlString = detail
            cell.TitleLabel?.text = title
            cell.DetailButton?.setTitle( title + " Link" , for: .normal )
            cell.url = urlString!
            cell.setNeedsLayout() //invalidate current layout
            cell.layoutIfNeeded() //update immediately
            return cell
        } else {
            var cell = Bundle.main.loadNibNamed("LegDetailCell", owner: self, options: nil)?.first as! LegDetailCell
            cell.DetailLabel?.text = detail
            cell.TitleLabel?.text = title
            cell.setNeedsLayout() //invalidate current layout
            cell.layoutIfNeeded() //update immediately
            return cell
        }
    }
    
    public func setRightNavButton(_ type: String) {
        var bills = defaults.array(forKey: "bills") as? [[String : String]]
        var found = false
        if (bills?.count)! >= 1 {
            for i in 0...(bills?.count)!-1 {
                if (bills?[i]["Bill ID"] == bill["Bill ID"]) {
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
        var bills = defaults.array(forKey: "bills") as? [[String : String]]
        var found = false
        if (bills?.count)! >= 1 {
            for i in 0...(bills?.count)!-1 {
                if (bills?[i]["Bill ID"] == bill["Bill ID"]) {
                    found = true
                }
            }
        }
        if (found == false) {
            bills?.append(bill)
        }
        defaults.set(bills, forKey: "bills")
        setRightNavButton("delete")
        print ("saved to local")
        print (bills)
        
    }
    func deleteFromLocal() {
        
        var bills = defaults.array(forKey: "bills") as? [[String : String]]
        if (bills?.count)! >= 1 {
            for i in 0...(bills?.count)!-1 {
                if (bills?[i]["Bill ID"] == bill["Bill ID"]) {
                    bills?.remove(at: i)
                    break
                }
            }
        }
        defaults.set(bills, forKey: "bills")
        setRightNavButton("save")
        print ("deleted from local")
        print (bills)
    }
    
    
    
    
}
