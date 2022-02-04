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
    var player: Player = Player()
    var detailPlayerUsername: String = ""

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var refreshButton: BorderButton!
    @IBOutlet weak var filterByStackView: UIStackView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
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
        
        // Do any additional setup after loading the view.
    }

    func apiStuffHidden(bool: Bool) {
        self.table.isHidden = bool
        self.filterByStackView.isHidden = bool
    }
    
    func doAfterGetTrips(json: Dictionary<String, Any>) {
        self.tripsList = json["trips"]! as! [Dictionary<String, Any>]
        print(self.tripsList.count)
        DispatchQueue.main.async {
            self.table.reloadData()
            self.apiStuffHidden(bool: false)
        }
    }
    
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.viewDidLoad()
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
        } else if segue.destination is profileViewController {
            let lvc = segue.destination as? profileViewController
            lvc?.playerID = self.playerID
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
        let dateTime = self.tripsList[indexPath.row]["date"] as! String
        let date = String(dateTime.prefix(17))
        let time = String(dateTime.dropFirst(17))
        cell.configure(date: date, time: time)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tripsList.count
    }
    
}
