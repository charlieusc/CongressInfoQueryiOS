//
//  CommitteeViewController.swift
//  SlideMenuControllerSwift
//



import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import SDWebImage

class CommitteeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    var comsHouseURL = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=com&id=0&chamber=house"
    var comsSenateURL = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=com&id=0&chamber=senate"
    var comsJointURL = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=com&id=0&chamber=all"
    
    var coms = [[String : String]]()
    var activeComs = [[String : String]]()
    let searchBar = UISearchBar()
    var shoudShowSearchResults = false
    var searchFiledText = ""
    
    typealias JSONStandard = [String : AnyObject]
    
    
    
    
    func callAlamo(url: String) {
        SwiftSpinner.show("Fetching Data...")
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            //print(response.debugDescription)
            self.coms = [[String : String]]()
            self.parseData(JSONData: response.data!)
        })
        
    }
    
    func parseData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            //print(readableJSON["results"])
            var comsJSON = readableJSON["results"] as! NSMutableArray
            for i in 0..<comsJSON.count {
                let comJSON = comsJSON[i] as! JSONStandard
                var com = [String : String]()
                com["Name"] = comJSON["name"] as? String
                com["ID"] = comJSON["committee_id"] as? String
                com["Parent ID"] = comJSON["parent_committee_id"] as? String
                com["Chamber"] = (comJSON["chamber"] as? String)?.capitalizingFirstLetter()
                com["Office"] = comJSON["office"] as? String
                com["Contact"] = comJSON["phone"] as? String
                coms.append(com)
            }
            coms = coms.sorted(by: { $0["Name"]! < $1["Name"]!})
            print (coms)
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
        self.title = "Committees"
        //self.tableView.rowHeight = 100
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLegNavigationBarItem()
        let selectedTag = self.tabBar.selectedItem?.tag
        if (selectedTag == 1) {
            callAlamo(url: comsSenateURL)
        } else  if (selectedTag == 2){
            callAlamo(url: comsJointURL)
        } else {
            callAlamo(url: comsHouseURL)
        }
        updateActiveComs()
        setRightNavButton("all")
        
    }
    public func setRightNavButton(_ type: String) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Search"), style: UIBarButtonItemStyle.done, target: self, action: #selector(creatSearchBar))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.titleView = nil
        searchFiledText = ""
        updateActiveComs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateActiveComs()
        if (segue.identifier == "ComDetail") {
            var DestViewController: CommitteeDetailViewController = segue.destination as! CommitteeDetailViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                DestViewController.com = activeComs[indexPath.row]
            }
            searchBar.endEditing(true)
            
        }
    }
    func updateActiveComs(){
        var activeComsTemp = [[String : String]]()
        
        //handle search bar search
        if (searchFiledText == "") {
            activeComs = coms
        } else {
            activeComsTemp = coms.filter({(com : [String : String]) -> Bool in return (com["Name"]?.lowercased().range(of: searchFiledText.lowercased()) != nil)})
            activeComs = activeComsTemp
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


extension CommitteeViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

extension CommitteeViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFiledText = searchText
        updateActiveComs()
        self.tableView.reloadData()
    }
}

extension CommitteeViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateActiveComs()
        return activeComs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateActiveComs()
        let com = activeComs[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ComCell", for: indexPath)
        let cellTextLabel = cell.textLabel
        cellTextLabel?.text = com["Name"]
        cell.detailTextLabel?.text = com["ID"]
        //cellTextLabel?.numberOfLines = 5
        
        return cell
    }
}

extension CommitteeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CommitteeViewController : SlideMenuControllerDelegate {
    
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

extension CommitteeViewController : UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (tabBar.selectedItem?.tag == 0) {
            print ("0")
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: comsHouseURL)
            updateActiveComs()
        } else if (tabBar.selectedItem?.tag == 1){
            print ("1")
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: comsSenateURL)
            updateActiveComs()
        } else {
            print ("2")
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: comsJointURL)
            updateActiveComs()
        }

    }
    
}

