//
//  leaderboardDetailViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/3/22.
//

import UIKit

class leaderboardDetailViewController: UIViewController {
    
    var detailPlayerID: Int? = nil
    var tripsList = [Dictionary<String, Any>]()
    var filteredTripsList = [Dictionary<String, Any>]()
    var player: Player = Player()
    var detailPlayerUsername: String = ""
    var season: String = "all"
    
    //for pull to refresh
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var refreshButton: BorderButton!
    @IBOutlet weak var filterByStackView: UIStackView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var totalTripsStackView: UIStackView!
    @IBOutlet weak var filterByButton: UIButton!
    @IBOutlet weak var totalTripsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // table setup
        table.delegate = self
        table.dataSource = self
        table.register(StatsTableViewCell.nib(), forCellReuseIdentifier: "StatsTableViewCell")
        usernameLabel.text = detailPlayerUsername
        // set up refresh control
        table.refreshControl = refreshControl
        refreshControl.tintColor = #colorLiteral(red: 0.7536441684, green: 0.07891514152, blue: 0.2141970098, alpha: 1)
        // configure refresh control
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
        // get trips
        player.getTrips(playerID: self.detailPlayerID!, vc: self, completion: doAfterGetTrips(json:))
        
        // hide everything till api call loads
        self.errorMessageLabel.text = "loading..."
        apiStuffHidden(bool: true)
        refreshButton.isHidden = true
        
        // set up filter by button
        self.setUpFilterByMenu()
        
        // customize navigation bar
        self.navigationItem.rightBarButtonItem = nil
        
        // Do any additional setup after loading the view.
    }
    
    // Set up pull down to refresh
    @objc private func refreshTable(_ sender: Any) {
        player.getTrips(playerID: self.detailPlayerID!, vc: self, completion: doAfterGetTrips(json:))
        self.refreshControl.endRefreshing()
    }
    
    func setUpFilterByMenu() {
        
        var result = [
            UIAction(title: "All time", image: nil, handler: { (_) in
                self.season = "all"
                self.filteredTripsList = self.tripsList
                self.totalTripsLabel.text = String(self.filteredTripsList.count)
                self.table.reloadData()
            })]
        
        for season in Season().getSeasons() {
            let newSeason = UIAction(title: season, image: nil, handler: { (_) in
                self.season = season
                self.filteredTripsList = self.tripsList.filter { $0["season"] as! String == self.season}
                self.totalTripsLabel.text = String(self.filteredTripsList.count)
                self.table.reloadData()
            })
            result.append(newSeason)
        }
        
        var menuItems: [UIAction] {
            return result
        }
        var filterByMenu: UIMenu {
            return UIMenu(title: "Season:", image: nil, identifier: nil, options: [], children: menuItems)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: nil, primaryAction: nil, menu: filterByMenu)
        filterByButton.showsMenuAsPrimaryAction = true
        filterByButton.changesSelectionAsPrimaryAction = true
        filterByButton.menu = filterByMenu
    }
    
    func apiStuffHidden(bool: Bool) {
        self.table.isHidden = bool
        self.filterByStackView.isHidden = bool
    }
    
    func doAfterGetTrips(json: Dictionary<String, Any>) {
        self.tripsList = json["trips"]! as! [Dictionary<String, Any>]
        self.tripsList.sort { ($0["id"] as! Int) > ($1["id"] as! Int)}
        if self.season == "all" {
            self.filteredTripsList = self.tripsList
        } else {
            self.filteredTripsList = self.tripsList.filter { $0["season"] as! String == self.season}
        }
        DispatchQueue.main.async {
            self.table.reloadData()
            self.totalTripsLabel.text = String(self.filteredTripsList.count)
            self.totalTripsStackView.isHidden = false
            self.apiStuffHidden(bool: false)
            self.errorMessageLabel.text = ""
        }
    }
    
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.viewDidLoad()
    }
    
}


extension leaderboardDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension leaderboardDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as! StatsTableViewCell
        let dateTime = (self.filteredTripsList[indexPath.row]["date"] as! String).split(separator: "!")
        let date = String(dateTime[0])
        let time = String(dateTime[1])
        cell.configure(date: date, time: time)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTripsList.count
    }
    
}
