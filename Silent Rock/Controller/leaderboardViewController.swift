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
    
    let player: Player = Player()
    var playerList = [PlayerForLB]()
    var playerID: Int? = nil
    var season: String = "all"
    var sortBy: String = "trips"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: self.season, completion: {json in
            self.doAfterGetPlayerData(json: json)
        })
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        
        setUpSortByMenu()
        setUpFilterByMenu()
        
        // Do any additional setup after loading the view.
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
        var menuItems: [UIAction] {
            return [
                // REVISIT THIS TO MAKE IT DYNAMIC -MB
                UIAction(title: "All time", image: nil, handler: { (_) in
                    self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: "all", completion: {json in
                        self.doAfterGetPlayerData(json: json)
                        self.season = "all"
                    })
                }),
                UIAction(title: "2021-2022", image: nil, handler: { (_) in
                    self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: "2021-2022", completion: {json in
                        self.doAfterGetPlayerData(json: json)
                        self.season = "2021-2022"
                    })
                }),
                UIAction(title: "2020-2021", image: nil, handler: { (_) in
                    self.player.getPlayerDataForLeaderboard(vc: self, sortBasis: self.sortBy, filterBy: "2020-2021", completion: {json in
                        self.doAfterGetPlayerData(json: json)
                        self.season = "2020-2021"
                    })
                })
            ]
        }
        var filterByMenu: UIMenu {
            return UIMenu(title: "Filter by:", image: nil, identifier: nil, options: [], children: menuItems)
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
        print(self.playerList)
        DispatchQueue.main.async {
            self.leaderboardTableView.reloadData()
        }
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
        }
    }
    
}

extension leaderboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected a row")
        // REVISIT THIS -MB
    }
}

extension leaderboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.playerList[indexPath.row].username
        
        var numTrips = ""
        if self.season == "all" {
            numTrips = String(self.playerList[indexPath.row].trips.count)
        } else {
            numTrips = String((self.playerList[indexPath.row].trips.filter { $0?.season == self.season}).count)
        }
        
        cell.detailTextLabel?.text = numTrips
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerList.count
    }
    
}

