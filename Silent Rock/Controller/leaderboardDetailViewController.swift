//
//  leaderboardDetailViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/3/22.
//

import UIKit

class leaderboardDetailViewController: UIViewController {
    
    var playerID: Int? = 29 // REVISIT THIS -MB
    var tripsList = [Dictionary<String, Any>]()
    var player: Player = Player()

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var refreshButton: BorderButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // table setup
        table.delegate = self
        table.dataSource = self
        table.register(StatsTableViewCell.nib(), forCellReuseIdentifier: "StatsTableViewCell")
        
        // get trips
        player.getTrips(playerID: self.playerID!, vc: self, completion: doAfterGetTrips(json:))
        
        
        // Do any additional setup after loading the view.
    }

    func doAfterGetTrips(json: Dictionary<String, Any>) {
        self.tripsList = json["trips"]! as! [Dictionary<String, Any>]
        print(self.tripsList.count)
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
}


extension leaderboardDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected a row")
//        let cell = tableView(table, cellForRowAt: indexPath.row) as StatsTableViewCell
        let cell = self.table.cellForRow(at: indexPath) as! StatsTableViewCell
        print(cell.playerId!)
        
        // REVISIT THIS -MB
    }
}

extension leaderboardDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "StatsTableViewCell", for: indexPath) as! StatsTableViewCell
        let dateTime = self.tripsList[indexPath.row]["date"] as! String
        let date = String(dateTime.prefix(17))
        let time = String(dateTime.dropFirst(17))
        cell.configure(date: date, time: time, id: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tripsList.count
    }
    
}
