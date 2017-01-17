//
//  ViewController.swift
//  SlideMenuControllerSwift
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import SDWebImage

class LegViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tabBar: UITabBar!
    
    var legislatorsURL = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=leg&id=0&chamber=all"
    var legislatorsURL1 = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=leg&id=0&chamber=house"
    var legislatorsURL2 = "http://charlieusc.us-west-2.elasticbeanstalk.com/W7y32hzsffewh387SFD/Homework8/Homework9.php?q=leg&id=0&chamber=senate"
    //states
    var states = ["All",
                  "Alaska",
                  "Alabama",
                  "Arkansas",
                  "American Samoa",
                  "Arizona",
                  "California",
                  "Colorado",
                  "Connecticut",
                  "District of Columbia",
                  "Delaware",
                  "Florida",
                  "Georgia",
                  "Guam",
                  "Hawaii",
                  "Iowa",
                  "Idaho",
                  "Illinois",
                  "Indiana",
                  "Kansas",
                  "Kentucky",
                  "Louisiana",
                  "Massachusetts",
                  "Maryland",
                  "Maine",
                  "Michigan",
                  "Minnesota",
                  "Missouri",
                  "Mississippi",
                  "Montana",
                  "North Carolina",
                  " North Dakota",
                  "Nebraska",
                  "New Hampshire",
                  "New Jersey",
                  "New Mexico",
                  "Nevada",
                  "New York",
                  "Ohio",
                  "Oklahoma",
                  "Oregon",
                  "Pennsylvania",
                  "Puerto Rico",
                  "Rhode Island",
                  "South Carolina",
                  "South Dakota",
                  "Tennessee",
                  "Texas",
                  "Utah",
                  "Virginia",
                  "Virgin Islands",
                  "Vermont",
                  "Washington",
                  "Wisconsin",
                  "West Virginia",
                  "Wyoming",
                  ]
    
    var selectedStates = "All"
    var legislators = [String : [[String : String]]]()
    var activeLegislators = [String : [[String : String]]]()
    var legislatorSectionTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var legislatorActiveSectionTitles = [String]()
    let searchBar = UISearchBar()
    var shoudShowSearchResults = false
    var searchFiledText = ""
    
    typealias JSONStandard = [String : AnyObject]


    
    
    func callAlamo(url: String) {
        SwiftSpinner.show("Fetching Data...")
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            //print(response.debugDescription)
            self.parseData(JSONData: response.data!)
        })
        
    }
    
    func parseData(JSONData : Data) {
        initializeLegislators()
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            //print(readableJSON["results"])
            var legislatorsJSON = readableJSON["results"] as! NSMutableArray
            for i in 0..<legislatorsJSON.count {
                let legJSON = legislatorsJSON[i] as! JSONStandard
                var leg = [String : String]()
                leg["First Name"] = legJSON["first_name"] as? String
                leg["Last Name"] = legJSON["last_name"] as? String
                leg["State"] = legJSON["state_name"] as? String
                
                leg["Birth date"] = (legJSON["birthday"] as? String)?.formatDate()
                leg["Gender"] = legJSON["gender"] as? String == "M" ? "Male" : "Female"
                leg["Chamber"] = (legJSON["chamber"] as? String)?.capitalizingFirstLetter()
                leg["Fax No."] = legJSON["fax"] as? String
                leg["Twitter"] = legJSON["twitter_id"] as? String
                leg["Website"] = legJSON["website"] as? String
                leg["Office No."] = legJSON["office"] as? String
                leg["Term ends on"] = (legJSON["term_end"] as? String)?.formatDate()
                leg["bioguide_id"] = legJSON["bioguide_id"] as? String
                
                let firstName = leg["First Name"]!
                let startIndex = firstName.index(firstName.startIndex, offsetBy: 0)
                let endIndex = firstName.index(firstName.startIndex, offsetBy: 0)
                let firstNameLetter = firstName[startIndex...endIndex]
                
                legislators[firstNameLetter]!.append(leg)
            }
            //sort legislators by lastname in legislators grouped by firstname
            for legsByGroup in legislators {
                legislators[legsByGroup.key] = legsByGroup.value.sorted(by: { $0["Last Name"]! < $1["Last Name"]!})
                //print(legsByGroup)
            }
            
            
            
            
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
        initializeLegislators()
        callAlamo(url: legislatorsURL)
        updateActiveLegislators()
        self.title = "Legislators"
        self.pickerView.isHidden = true
        
    }
    func initializeLegislators() {
        for group in legislatorSectionTitles {
            var legislatorbyGroup = [[String : String]]()
            legislators[group] = legislatorbyGroup
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLegNavigationBarItem()
        //print("leg view appear")
        selectedStates = "All"
        let selectedTag = self.tabBar.selectedItem?.tag
        if (selectedTag == 1) {
            callAlamo(url: legislatorsURL1)
            setRightNavButton("else")
        } else  if (selectedTag == 2){
            callAlamo(url: legislatorsURL2)
            setRightNavButton("else")
        } else {
            callAlamo(url: legislatorsURL)
            setRightNavButton("state")
        }
        updateActiveLegislators()
    }
    public func setRightNavButton(_ type: String) {
        if type == "state" {
            let rightButton: UIBarButtonItem = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.done, target: self, action: #selector(stateFilter))
            navigationItem.rightBarButtonItem = rightButton
        } else {
            let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named : "Search"), style: UIBarButtonItemStyle.done, target: self, action: #selector(creatSearchBar))
            navigationItem.rightBarButtonItem = rightButton
        }
        navigationItem.titleView = nil
        searchFiledText = ""
        updateActiveLegislators()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateActiveLegislators()
        if (segue.identifier == "LegDetail") {
            var DestViewController: LegDetailViewController = segue.destination as! LegDetailViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let sectionTitle = legislatorActiveSectionTitles[indexPath.section]
                DestViewController.legislator = activeLegislators[sectionTitle]![indexPath.row]
            }
            
        }
        searchBar.endEditing(true)
    }
    func updateActiveLegislators(){
        var activeLegislatorsTemp = [String : [[String : String]]]()
        if (tabBar.selectedItem?.tag == 0) {
            if selectedStates == "All" {
                activeLegislators = legislators
            } else {
                for group in legislatorSectionTitles {
                    var legislatorbyGroup = [[String : String]]()
                    for legislator in legislators[group]! {
                        if (legislator["State"] == selectedStates) {
                            legislatorbyGroup.append(legislator)
                        }
                    }
                    activeLegislatorsTemp[group] = legislatorbyGroup
                }
                activeLegislators = activeLegislatorsTemp
            }
        } else {
            //handle search bar search
            if (searchFiledText == "") {
                activeLegislators = legislators
            } else {
                for group in legislatorSectionTitles {
                    activeLegislatorsTemp[group] = legislators[group]!.filter({(legislator : [String : String]) -> Bool in return (legislator["First Name"]?.lowercased().range(of: searchFiledText.lowercased()) != nil) || (legislator["Last Name"]?.lowercased().range(of: searchFiledText.lowercased()) != nil) })
                }
                activeLegislators = activeLegislatorsTemp
            }
    }
        
        
        var legislatorActiveSectionTitlesTemp = [String]()
        for sectionTitle in legislatorSectionTitles {
            if (activeLegislators[sectionTitle]?.count != 0) {
                legislatorActiveSectionTitlesTemp.append(sectionTitle)
            }
        }
        legislatorActiveSectionTitles = legislatorActiveSectionTitlesTemp
    }
    
    public func stateFilter(barButtonItem: UIBarButtonItem) {
        self.pickerView.isHidden = false
        print("Filter Has been Preased")
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

extension LegViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

extension LegViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFiledText = searchText
        updateActiveLegislators()
        self.tableView.reloadData()
    }
}

extension LegViewController : UIPickerViewDelegate {

}

extension LegViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStates = states[row]
        updateActiveLegislators()
        self.tableView.reloadData()
        self.pickerView.isHidden = true
        print(selectedStates)
    }
}

extension LegViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        updateActiveLegislators()
        return legislatorActiveSectionTitles.count
        
    }
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        updateActiveLegislators()
        /*
        if (tabBar.selectedItem?.tag != 0) {
            return 0.0
        }
         */
        return 10
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        updateActiveLegislators()
        /*
        if (tabBar.selectedItem?.tag != 0) {
            return nil
        }
         */
        return legislatorActiveSectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        updateActiveLegislators()
        /*
        if (tabBar.selectedItem?.tag != 0) {
            return nil
        }
        */
        return legislatorActiveSectionTitles
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateActiveLegislators()
        let sectionTitle = legislatorActiveSectionTitles[section]
        let sectionLegislators = activeLegislators[sectionTitle]
        return sectionLegislators!.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateActiveLegislators()
        let sectionTitle = legislatorActiveSectionTitles[indexPath.section]
        let leg = activeLegislators[sectionTitle]![indexPath.row]
        
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
    }
}

extension LegViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LegViewController : SlideMenuControllerDelegate {
    
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

extension LegViewController : UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (tabBar.selectedItem?.tag == 0) {
            print ("0")
            setRightNavButton("state")
            searchFiledText = ""
            callAlamo(url: legislatorsURL)
            updateActiveLegislators()
        } else if (tabBar.selectedItem?.tag == 1) {
            print ("1")
            selectedStates = "All"
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: legislatorsURL1)
            updateActiveLegislators()
        } else if (tabBar.selectedItem?.tag == 2) {
            print ("2")
            selectedStates = "All"
            searchFiledText = ""
            setRightAsSearchButton()
            callAlamo(url: legislatorsURL2)
            updateActiveLegislators()
        } else {
            print ("haven't selected yet")
        }
        
    }
    
}
