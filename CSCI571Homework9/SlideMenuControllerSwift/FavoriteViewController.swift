//
//  FavoriteViewController.swift
//  SlideMenuControllerSwift
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import SDWebImage

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tabBar: UITabBar!
    var legs = [[String : String]]()
    var bills = [[String : String]]()
    var coms = [[String : String]]()
    var activeLegs = [[String : String]]()
    var activeBills = [[String : String]]()
    var activeComs = [[String : String]]()
    let searchBar = UISearchBar()
    var shoudShowSearchResults = false
    var searchFiledText = ""
    var inSection = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 24)!, NSForegroundColorAttributeName: UIColor.lightGray]
        let attributes2: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 24)!, NSForegroundColorAttributeName: UIColor.blue]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes(attributes2, for: .selected)
        self.tabBar.selectedItem = self.tabBar.items?[0]
        setTableContents()
    }
    func setTableContents() {
        legs = (defaults.array(forKey: "legislators") as? [[String : String]])!
        bills = (defaults.array(forKey: "bills") as? [[String : String]])!
        coms = (defaults.array(forKey: "coms") as? [[String : String]])!
        legs = legs.sorted(by: { $0["Last Name"]! < $1["Last Name"]!})
        bills = bills.sorted(by: { $0["Official Title"]! < $1["Official Title"]!})
        coms = coms.sorted(by: { $0["Name"]! < $1["Name"]!})
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setTableContents()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLegNavigationBarItem()
        
        let selectedTag = self.tabBar.selectedItem?.tag
        updateActiveContents()
        setRightNavButton("all")
        self.title = "Favorite"
        
    }
    public func setRightNavButton(_ type: String) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Search"), style: UIBarButtonItemStyle.done, target: self, action: #selector(creatSearchBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.titleView = nil
        searchFiledText = ""
        updateActiveContents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LegDetailF") {
            var DestViewController: LegDetailViewController = segue.destination as! LegDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                DestViewController.legislator = activeLegs[indexPath.row]
            }
            searchBar.endEditing(true)
        } else if (segue.identifier == "BillDetailF") {
            var DestViewController: BillsDetailViewController = segue.destination as! BillsDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                DestViewController.bill = activeBills[indexPath.row]
            }
            searchBar.endEditing(true)
        } else if (segue.identifier == "ComDetailF") {
            var DestViewController: CommitteeDetailViewController = segue.destination as! CommitteeDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                DestViewController.com = activeComs[indexPath.row]
            }
            searchBar.endEditing(true)
        }

    }
    func updateActiveContents() {
        setTableContents()
        if inSection == 0 {
            var activeLegsTemp = [[String : String]]()
            
            //handle search bar search
            if (searchFiledText == "") {
                activeLegs = legs
            } else {
                activeLegsTemp = legs.filter({(legislator : [String : String]) -> Bool in return (legislator["First Name"]?.lowercased().range(of: searchFiledText.lowercased()) != nil) || (legislator["Last Name"]?.lowercased().range(of: searchFiledText.lowercased()) != nil) })
                activeLegs = activeLegsTemp
            }
            //activeBills = [[String: String]]()
            //activeComs = [[String: String]]()
        } else if inSection == 1 {
            var activeBillsTemp = [[String : String]]()
            
            //handle search bar search
            if (searchFiledText == "") {
                activeBills = bills
            } else {
                activeBillsTemp = bills.filter({(bill : [String : String]) -> Bool in return (bill["Official Title"]?.lowercased().range(of: searchFiledText.lowercased()) != nil)})
                activeBills = activeBillsTemp
            }
            //activeLegs = [[String: String]]()
            //activeComs = [[String: String]]()
        } else if inSection == 2 {
            var activeComsTemp = [[String : String]]()
            
            //handle search bar search
            if (searchFiledText == "") {
                activeComs = coms
            } else {
                activeComsTemp = coms.filter({(com : [String : String]) -> Bool in return (com["Name"]?.lowercased().range(of: searchFiledText.lowercased()) != nil)})
                activeComs = activeComsTemp
            }
            //activeBills = [[String: String]]()
            //activeLegs = [[String: String]]()
        }
        self.tableView.reloadData()
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


extension FavoriteViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

extension FavoriteViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFiledText = searchText
        updateActiveContents()
    }
}

extension FavoriteViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSection == 0 {
            if section == 0 {
                return activeLegs.count
            } else {
                return 0
            }
        } else if inSection == 1{
            if section == 1 {
                return activeBills.count
            } else {
                return 0
            }
        } else {
            if section == 2 {
                return activeComs.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let leg = activeLegs[indexPath.row]
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "LegCell", for: indexPath)
            cell.textLabel?.text = leg["First Name"]! + " " + leg["Last Name"]!
            cell.detailTextLabel?.text = leg["State"]!
            var imgURL  = "https://theunitedstates.io/images/congress/225x275/" + leg["bioguide_id"]! + ".jpg"
            let url = URL(string: imgURL)!
            cell.imageView?.sd_setImage(with: url) {(image, error, imageCacheType, imageUrl) in
                cell.setNeedsLayout() //invalidate current layout
                cell.layoutIfNeeded() //update immediately
            }
            return cell

        } else if indexPath.section == 1 {
            let bill = activeBills[indexPath.row]
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath)
            let cellTextLabel = cell.textLabel
            cellTextLabel?.text = bill["Official Title"]
            cellTextLabel?.numberOfLines = 5
            return cell
        } else {
            let com = activeComs[indexPath.row]
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ComCell", for: indexPath)
            let cellTextLabel = cell.textLabel
            cellTextLabel?.text = com["Name"]
            cell.detailTextLabel?.text = com["ID"]
            return cell
        }
        
    }
}

extension FavoriteViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 100
        } else {
            return 45
        }
    }
}

extension FavoriteViewController : SlideMenuControllerDelegate {
    
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

extension FavoriteViewController : UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (tabBar.selectedItem?.tag == 2) {
            print ("2")
            searchFiledText = ""
            setRightAsSearchButton()
            inSection = 2
            
        } else if (tabBar.selectedItem?.tag == 1) {
            print ("1")
            searchFiledText = ""
            setRightAsSearchButton()
            inSection = 1
            
        } else {
            print ("0")
            searchFiledText = ""
            setRightAsSearchButton()
            inSection = 0
        }
        updateActiveContents()
    }
    
}

