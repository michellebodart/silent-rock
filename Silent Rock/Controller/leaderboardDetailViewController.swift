//
//  leaderboardDetailViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/3/22.
//

import UIKit

class leaderboardDetailViewController: UIViewController {
    
    var detailPlayerID: Int? = nil
    var playerID: Int? = nil
    var tripsList = [Dictionary<String, Any>]()
    var filteredTripsList = [Dictionary<String, Any>]()
    var player: Player = Player()
    var detailPlayerUsername: String = ""
    var season: String = "all"
    var returnTo: String? = nil
    var addedPlayerIDs: Array<Int?> = []

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var refreshButton: BorderButton!
    @IBOutlet weak var filterByStackView: UIStackView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var filterByButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // table setup
        table.delegate = self
        table.dataSource = self
        table.register(StatsTableViewCell.nib(), forCellReuseIdentifier: "StatsTableViewCell")
        usernameLabel.text = detailPlayerUsername
        
        // get trips
        player.getTrips(playerID: self.detailPlayerID!, vc: self, completion: doAfterGetTrips(json:))
        
        // hide everything till api call loads
        apiStuffHidden(bool: true)
        refreshButton.isHidden = true
        errorMessageLabel.text = ""
        
        // set up filter by button
        self.setUpFilterByMenu()
        
        // Do any additional setup after loading the view.
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    func setUpFilterByMenu() {
        
        var result = [
            UIAction(title: "All time", image: nil, handler: { (_) in
                self.season = "all"
                self.filteredTripsList = self.tripsList
                self.table.reloadData()
            })]
        
        for season in Season().getSeasons() {
            let newSeason = UIAction(title: season, image: nil, handler: { (_) in
                self.season = season
                self.filteredTripsList = self.tripsList.filter { $0["season"] as! String == self.season}
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
        self.filteredTripsList = self.tripsList
        DispatchQueue.main.async {
            self.table.reloadData()
            self.apiStuffHidden(bool: false)
        }
    }
    
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.viewDidLoad()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if self.returnTo == "leaderboard" {
            self.performSegue(withIdentifier: "leaderboardView", sender: self)
        } else if self.returnTo == "profile" {
            self.performSegue(withIdentifier: "profileView", sender: self)
        }
    }
    
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        if self.detailPlayerID != nil {
            self.performSegue(withIdentifier: "profileView", sender: self)
        } else {
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.playerID = self.playerID
            vc?.addedPlayerIDs = self.addedPlayerIDs
        } else if segue.destination is profileViewController {
            let pvc = segue.destination as? profileViewController
            pvc?.playerID = self.playerID
            pvc?.addedPlayerIDs = self.addedPlayerIDs
        } else if segue.destination is leaderboardViewController {
            let lvc = segue.destination as? leaderboardViewController
            lvc?.playerID = self.playerID
            lvc?.addedPlayerIDs = self.addedPlayerIDs
        }
    }
    
    
}


extension leaderboardDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.table.cellForRow(at: indexPath) as! StatsTableViewCell
        
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
