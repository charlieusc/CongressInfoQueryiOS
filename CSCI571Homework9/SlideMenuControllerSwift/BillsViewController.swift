//
//  BillsViewController.swift
//  SlideMenuControllerSwift
//



import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import SDWebImage

class BillsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tabBar: UITabBar!
    var billsActiveURL = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=activebills&id=0&chamber=all"
    var billsNewURL = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=newbills&id=0&chamber=all"
    
    var bills = [[String : String]]()
    var activeBills = [[String : String]]()
    let searchBar = UISearchBar()
    var shoudShowSearchResults = false
    var searchFiledText = ""
    
    typealias JSONStandard = [String : AnyObject]
    
    
    
    
    func callAlamo(url: String) {
        SwiftSpinner.show("Fetching Data...")
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            //print(response.debugDescription)
            self.bills = [[String : String]]()
            self.parseData(JSONData: response.data!)
        })
        
    }
    
    func parseData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            //print(readableJSON["results"])
            var billsJSON = readableJSON["results"] as! NSMutableArray
            for i in 0..<billsJSON.count {
                let billJSON = billsJSON[i] as! JSONStandard
                var bill = [String : String]()
                bill["Official Title"] = billJSON["official_title"] as? String
                bill["Bill ID"] = billJSON["bill_id"] as? String
                bill["Bill Type"] = (billJSON["bill_type"] as? String)?.uppercased()
                
                let sponsor = billJSON["sponsor"] as! JSONStandard
                let sponsor_title = sponsor["title"] as? String
                let sponsor_first_name = sponsor["first_name"] as? String
                let sponsor_last_name = sponsor["last_name"] as? String
                let sponsorText = sponsor_title! + " " + sponsor_first_name! + " " + sponsor_last_name!
                bill["Sponsor"] = sponsorText
                
                bill["Chamber"] = (billJSON["chamber"] as? String)?.capitalizingFirstLetter()
                bill["Last Action"] = (billJSON["last_action_at"] as? String)?.formatDate()
                
                let lastVersion = billJSON["last_version"] as! JSONStandard
                let urls = lastVersion["urls"] as! JSONStandard
                bill["PDF"] = urls["pdf"] as? String
                bill["Last Vote"] = (billJSON["last_vote_at"] as? String)?.formatDate()
                let history = billJSON["history"] as!JSONStandard
                bill["Status"] = history["active"] as? Bool == true ? "Active" : "New"
                //bill["Introduced On"] = billJSON["introduced_on"] as? String
                
                bills.append(bill)
            }
            bills = bills.sorted(by: { $0["Official Title"]! < $1["Official Title"]!})

            //print (bills)
            self.tableView.reloadData()
 
        }
        catch {
            print(error)
        }
        SwiftSpinner.hide()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 24)!, NSForegroundColorAttributeName: UIColor.lightGray]
        let attributes2: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 24)!, NSForegroundColorAttributeName: UIColor.blue]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes(attributes2, for: .selected)
        self.tabBar.selectedItem = self.tabBar.items?[0]
        callAlamo(url: billsActiveURL)
        updateActiveBills()
        self.title = "Bills"
        self.tableView.rowHeight = 100
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLegNavigationBarItem()
        
        let selectedTag = self.tabBar.selectedItem?.tag
        if (selectedTag == 1) {
            callAlamo(url: billsNewURL)
        } else {
            callAlamo(url: billsActiveURL)
        }
        updateActiveBills()
        setRightNavButton("all")
        
    }
    public func setRightNavButton(_ type: String) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Search"), style: UIBarButtonItemStyle.done, target: self, action: #selector(creatSearchBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.titleView = nil
        searchFiledText = ""
        updateActiveBills()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateActiveBills()
        if (segue.identifier == "BillDetail") {
            var DestViewController: BillsDetailViewController = segue.destination as! BillsDetailViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                DestViewController.bill = activeBills[indexPath.row]
            }
            searchBar.endEditing(true)
            
        }
    }
    func updateActiveBills(){
        var activeBillsTemp = [[String : String]]()
        
            //handle search bar search
            if (searchFiledText == "") {
                activeBills = bills
            } else {
                activeBillsTemp = bills.filter({(bill : [String : String]) -> Bool in return (bill["Official Title"]?.lowercased().range(of: searchFiledText.lowercased()) != nil)})
                activeBills = activeBillsTemp
            }
    }
    
    public func creatSearchBar () {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Cancel"), style: UIBarButtonItemStyle.done, target: self, action: #selector(setRightAsSearchButton))
        navigationItem.rightBarButtonItem = rightButton
        
        searchBar.showsScopeBar = false
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    public func setRightAsSearchButton() {
        setRightNavButton("else")
        self.navigationItem.titleView = nil
    }
}


extension BillsViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

extension BillsViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFiledText = searchText
        updateActiveBills()
        self.tableView.reloadData()
    }
}

extension BillsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateActiveBills()
        return activeBills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateActiveBills()
        let bill = activeBills[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath)
        let cellTextLabel = cell.textLabel
        cellTextLabel?.text = bill["Official Title"]
        cellTextLabel?.numberOfLines = 5
        
        return cell
    }
}

extension BillsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BillsViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}

extension BillsViewController : UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (tabBar.selectedItem?.tag == 0) {
            print ("0")
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: billsActiveURL)
            updateActiveBills()
        } else {
            print ("1")
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: billsNewURL)
            updateActiveBills()
        }        
    }
    
}

