//
//  leaderboardViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/1/22.
//

import UIKit

class leaderboardViewController: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    let player: Player = Player()
    
    var playerList = [PlayerForLB]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.getPlayerDataFromLeaderboard(vc: self, completion: {json in
            self.doAfterGetPlayerData(json: json)
        })

        // Do any additional setup after loading the view.
    }
    
    func doAfterGetPlayerData(json: Array<Any>) {
        self.playerList = []
        for eachPlayer in json {
            let player = eachPlayer as! [String: Any]
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
        print(self.playerList)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
