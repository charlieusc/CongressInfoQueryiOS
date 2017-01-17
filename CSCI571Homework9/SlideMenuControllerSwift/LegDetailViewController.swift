//
//  LegDetailViewController.swift
//  LegBillCom
//
//  Created by YangJialin on 11/24/16.
//  Copyright © 2016 YangJialin. All rights reserved.
//

import UIKit

class LegDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var LegImage: UIImageView!
    @IBOutlet weak var DetailTable: UITableView!
    
    var legislator = [String : String]()
    var keys = ["First Name", "Last Name", "State", "Birth date", "Gender", "Chamber", "Fax No.", "Twitter", "Website", "Office No.", "Term ends on"]
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        var imgURL  = "https://theunitedstates.io/images/congress/original/" + legislator["bioguide_id"]! + ".jpg"
        let url = URL(string: imgURL)!
        LegImage?.sd_setImage(with: url) {(image, error, imageCacheType, imageUrl) in
            self.LegImage.setNeedsLayout() //invalidate current layout
            self.LegImage.layoutIfNeeded() //update immediately
        }
        setRightNavButton("save")

    }
    override func viewDidLoad() {
        self.title = "Legislator Detail"
    }
    
    public func setRightNavButton(_ type: String) {
        var legislators = defaults.array(forKey: "legislators") as? [[String : String]]
        var found = false
        if (legislators?.count)! >= 1 {
            for i in 0...(legislators?.count)!-1 {
                if (legislators?[i]["bioguide_id"] == legislator["bioguide_id"]) {
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
        var legislators = defaults.array(forKey: "legislators") as? [[String : String]]
        var found = false
        if (legislators?.count)! >= 1 {
            for i in 0...(legislators?.count)!-1 {
                if (legislators?[i]["bioguide_id"] == legislator["bioguide_id"]) {
                    found = true
                }
            }
        }
        if (found == false) {
            legislators?.append(legislator)
        }
        defaults.set(legislators, forKey: "legislators")
        setRightNavButton("delete")
        print ("saved to local")
        print (legislators)
        
    }
    func deleteFromLocal() {
        
        var legislators = defaults.array(forKey: "legislators") as? [[String : String]]
        if (legislators?.count)! >= 1 {
            for i in 0...(legislators?.count)!-1 {
                if (legislators?[i]["bioguide_id"] == legislator["bioguide_id"]) {
                    legislators?.remove(at: i)
                    break
                }
            }
        }
        defaults.set(legislators, forKey: "legislators")
        setRightNavButton("save")
        print ("deleted from local")
        print (legislators)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = keys[indexPath.row]
        var detail = legislator[title]
        //let cell = self.DetailTable.dequeueReusableCell(withIdentifier: "LegDetailCell", for: indexPath)
        
        if detail == nil {
            detail = "N.A"
        }
        if ((title == "Twitter" || title == "Website") && detail != "N.A") {
            
            var cell = Bundle.main.loadNibNamed("LegDetailCell2", owner: self, options: nil)?.first as! LegDetailCell2
            var urlString = detail
            if (title == "Twitter") {
                urlString = "https://www.twitter.com/" + urlString!
            }
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
    
    
    
    
}
