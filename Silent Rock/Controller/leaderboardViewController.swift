//
//  leaderboardViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/1/22.
//

import UIKit
import SwiftUI

class leaderboardViewController: UIViewController {

    @IBOutlet weak var sortFilterStackView: UIStackView!
    @IBOutlet weak var leaderboardTableView: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var filterByButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tripsLabel: UILabel!
    @IBOutlet weak var refreshButton: BorderButton!
    
    let player: Player = Player()
    var playerList = [PlayerForLB]()
    var playerID: Int? = nil
    var season: String = "all"
    var sortBy: String = "trips"
    var detailPlayerID: Int? = nil
    var detailPlayerUsername: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always start by sorting by trips, season is all time
        self.season = "all"
        self.sortBy = "trips"
        
        // hide everything till API call works
        self.tableIsHidden(bool: true)
        self.refreshButton.isHidden = true
        self.errorMessageLabel.text = ""
        
        // get leaderboard information and set the labels
        player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: self.season, completion: {json in
            self.doAfterGetPlayerData(json: json)
        })
        
        // tableview set up stuff
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        leaderboardTableView.register(LeaderboardTableViewCell.nib(), forCellReuseIdentifier: "LeaderboardTableViewCell")
        
        // set up the sort by and filter by buttons
        setUpSortByMenu()
        setUpFilterByMenu()
        
        // Do any additional setup after loading the view.
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.viewDidLoad()
    }
    
    
    func setUpSortByMenu() {
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Trips", image: nil, handler: { (_) in
                    self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: "trips", filterBy: self.season, completion: {json in
                        self.doAfterGetPlayerData(json: json)
                        self.sortBy = "trips"
                    })
                }),
                UIAction(title: "Username", image: nil, handler: { (_) in
                    self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: "username", filterBy: "all", completion: {json in
                        self.doAfterGetPlayerData(json: json)
                        self.sortBy = "username"
                    })
                })
            ]
        }
        var sortByMenu: UIMenu {
            return UIMenu(title: "Sort by:", image: nil, identifier: nil, options: [], children: menuItems)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: nil, primaryAction: nil, menu: sortByMenu)
        sortByButton.showsMenuAsPrimaryAction = true
        sortByButton.changesSelectionAsPrimaryAction = true
        sortByButton.menu = sortByMenu
    }
    
    func setUpFilterByMenu() {
        
        var result = [
            UIAction(title: "All time", image: nil, handler: { (_) in
                self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: "all", completion: {json in
                    self.doAfterGetPlayerData(json: json)
                    self.season = "all"
                })
            })]
        
        for season in Season().getSeasons() {
            let newSeason = UIAction(title: season, image: nil, handler: { (_) in
                self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: season, completion: {json in
                    self.doAfterGetPlayerData(json: json)
                    self.season = season
                })
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
    
    
    func doAfterGetPlayerData(json: Array<Any>) {
        self.playerList = []
        for eachPlayer in json {
            let player = eachPlayer as! [String: Any]
            if player["visible_on_leaderboard"] as! Bool {
                let id = player["id"] as! Int
                let username = player["username"] as! String
                var trips = [Trip?]()
                if (player["trips"] as! Array<Trip>).count > 0 {
                    for eachTrip in (player["trips"] as! Array<Any>) {
                        let trip = eachTrip as! [String: Any]
                        let id = trip["id"] as! Int
                        let season = trip["season"] as! String
                        let date = trip["date"] as! String
                        trips.append(Trip(date: date, season: season, id: id))
                    }
                }
                self.playerList.append(PlayerForLB(username: username, id: id, trips: trips))
            }
        }
        DispatchQueue.main.async {
            self.leaderboardTableView.reloadData()
            self.tableIsHidden(bool: false)
        }
    }

    func tableIsHidden(bool: Bool) {
        self.sortFilterStackView.isHidden = bool
        self.usernameLabel.isHidden = bool
        self.tripsLabel.isHidden = bool
        self.leaderboardTableView.isHidden = bool
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        if self.playerID == nil {
            self.performSegue(withIdentifier: "loginView", sender: self)
        } else {
            self.performSegue(withIdentifier: "profileView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.playerID = self.playerID
        } else if segue.destination is profileViewController {
            let lvc = segue.destination as? profileViewController
            lvc?.playerID = self.playerID
        } else if segue.destination is leaderboardDetailViewController {
            let ldvc = segue.destination as? leaderboardDetailViewController
            ldvc?.detailPlayerID = self.detailPlayerID
            ldvc?.playerID = self.playerID
            ldvc?.detailPlayerUsername = self.detailPlayerUsername ?? ""
            ldvc?.returnTo = "leaderboard"
        }
    }
    
}


// Setting up table view
extension leaderboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LeaderboardTableViewCell
        self.detailPlayerID = cell.playerID
        self.detailPlayerUsername = cell.usernameLabel.text!
        self.performSegue(withIdentifier: "leaderboardDetailView", sender: self)
    }
}

extension leaderboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var numTrips = 0
        if self.season == "all" {
            numTrips = self.playerList[indexPath.row].trips.count
        } else {
            numTrips = (self.playerList[indexPath.row].trips.filter { $0?.season == self.season}).count
        }
        
        let username = self.playerList[indexPath.row].username
        let id = self.playerList[indexPath.row].id

        
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: "LeaderboardTableViewCell", for: indexPath) as! LeaderboardTableViewCell
        cell.configure(id: id, username: username, trips: numTrips)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerList.count
    }
    
}

