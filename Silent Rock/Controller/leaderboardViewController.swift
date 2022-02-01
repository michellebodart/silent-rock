//
//  leaderboardViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/1/22.
//

import UIKit
import SwiftUI

class leaderboardViewController: UIViewController {

    @IBOutlet weak var leaderboardTableView: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var sortByButton: UIButton!
    
    let player: Player = Player()
    var playerList = [PlayerForLB]()
    var playerID: Int? = nil
    var season: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.getPlayerDataForLeaderboard(vc: self, sortBasis: "trips", completion: {json in
            self.doAfterGetPlayerData(json: json)
        })
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        
        sortByButton.showsMenuAsPrimaryAction = true
        sortByButton.changesSelectionAsPrimaryAction = true
        
        // Do any additional setup after loading the view.
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
        if self.season != nil {
            numTrips = String(((self.playerList[indexPath.row].trips).filter { $0?.season == self.season}).count)
        } else {
            numTrips = String(self.playerList[indexPath.row].trips.count)
        }
        
        cell.detailTextLabel?.text = numTrips
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerList.count
    }
    
}
