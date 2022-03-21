//
//  ViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 11/10/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var playerID: Int? = nil
    var playerUsername: String? = nil
    var addedPlayerIDs: Array<Int?> = []
    var playerUsernamesIDs: Array<Dictionary<String, Any>> = []
    var locationManager: CLLocationManager? = CLLocationManager()
    var inRegion: Bool = false
    let player: Player = Player()
    
    //    Acutal silent rock coordinates
    let targetLat:Double = 45.306558
    let targetLon:Double = -121.830166
    let span:Double = 0.005
    
//    For testing near my house
//    let targetLat:Double = 47.654151
//    let targetLon:Double = -122.348564
//    let span:Double = 0.0002
//
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var addFriendsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up variables that won't change from tab bar controller
        self.playerID = (self.tabBarController! as! TabBarController).playerID
        self.playerUsername = (self.tabBarController! as! TabBarController).playerUsername
        
        self.setInRegion() // might not need this
        self.errorMessageLabel.text = ""
        
        // set up location manager
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.allowsBackgroundLocationUpdates = true //for alarm
        self.locationManager!.distanceFilter = 5 // filters out updates till it's traveled x meters. Set to 5 for testing purposes
        
        self.locationManager!.startUpdatingLocation()
        
        // Set up local notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        // set up add friends table view
        if self.playerID == nil {
            self.addFriendsButton.setTitle("Sign in to add friends", for: .normal)
            self.addFriendsButton.isEnabled = false
            self.addFriendsButton.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.addFriendsButton.setTitle("Add friends", for: .normal)
        }
        self.addFriendsTable.isHidden = true
        self.addFriendsTable.delegate = self
        self.addFriendsTable.dataSource = self
        self.addFriendsTable.register(addFriendsTableViewCell.nib(), forCellReuseIdentifier: addFriendsTableViewCell.identifier)
        
    }
    
    // hide table when tapped around
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != self.addFriendsTable {
            self.addFriendsTable.isHidden = true
        }
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    // opens and closes the table view and loads player data
    @IBAction func addFriendsButtonTapped(_ sender: Any) {
        if self.playerUsernamesIDs.count == 0 {
            self.player.getAllPlayers(vc: self, completion: { json in
                for eachPlayer in json {
                    // add player to player list
                    let username = eachPlayer["username"] as! String
                    let id = eachPlayer["id"] as! Int
                    if id == self.playerID {
                        continue
                    }
                    let playerData = [
                        "id": id,
                        "username": username
                    ] as [String : Any]
                    self.playerUsernamesIDs.append(playerData)
                }
                let tableHeight: CGFloat
                if self.playerUsernamesIDs.count > 5 {
                    tableHeight = 150
                } else {
                    tableHeight = CGFloat(30 * self.playerUsernamesIDs.count)
                }
                
                DispatchQueue.main.async {
                    self.errorMessageLabel.text = ""
                    self.addFriendsTable.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
                    self.addFriendsTable.isHidden = !self.addFriendsTable.isHidden
                    self.playerUsernamesIDs.sort { ($0["username"] as! String).lowercased() < ($1["username"] as! String).lowercased()}
                    self.addFriendsTable.reloadData()
                }
            })
        } else {
            self.addFriendsTable.isHidden = !self.addFriendsTable.isHidden
            print(self.addedPlayerIDs)
        }
    }
    
    func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "APPROACHING SILENT ROCK"
        content.subtitle = "SHHHHHH"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "LocalNotificationSound2.mp3"))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false) //Maybe update this to a location based trigger?
        
        let request = UNNotificationRequest(identifier: "Silent rock notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func setInRegion() {
        guard let locValue: CLLocationCoordinate2D = locationManager!.location?.coordinate else { return }
        let lat: Double = locValue.latitude
        let lon: Double = locValue.longitude
        if (self.targetLat - self.span < lat && lat < self.targetLat + self.span) && (self.targetLon - self.span < lon && lon < self.targetLon + self.span) {
            self.inRegion = true
        } else {
            self.inRegion = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let lat: Double = locValue.latitude
        let lon: Double = locValue.longitude
        // Creating didEnterRegion basically
        if (self.targetLat - self.span < lat && lat < self.targetLat + self.span) && (self.targetLon - self.span < lon && lon < self.targetLon + self.span) {
            if !self.inRegion {
                // Entered region
                self.sendLocalNotification()
                self.inRegion = true

                // only add trip to DB if a user is logged in - don't let them add friends if don't have an account
                if self.playerID != nil {
                    self.player.addTrip(vc: self, completion: { tripID in
                        self.player.addTripToUsers(vc: self, tripID: tripID, playerIDs: [self.playerID], completion: { tripID in
                            print("about to add pending players")
                            print("player ids:", self.addedPlayerIDs)
                            self.player.addPendingTripToUsers(vc: self, tripID: tripID, playerIDs: self.addedPlayerIDs, tripOwnerUsername: self.playerUsername!)
                        })
                    })
                }
            }
        } else {
            if self.inRegion {
                // Exited region
                self.inRegion = false
            }
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
        if segue.destination is profileViewController {
            let pvc = segue.destination as? profileViewController
        } else if segue.destination is leaderboardViewController {
            let lvc = segue.destination as? leaderboardViewController
        }
    }
    
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageView = (addFriendsTable.cellForRow(at: indexPath) as! addFriendsTableViewCell).checkImageView!
        let id = (addFriendsTable.cellForRow(at: indexPath) as! addFriendsTableViewCell).playerID
        if let index = self.addedPlayerIDs.firstIndex(of: id) {
            // remove the friend
            self.addedPlayerIDs.remove(at: index)
            imageView.image = nil
        } else {
            // add the friend
            self.addedPlayerIDs.append(id)
            let checkedImage:UIImage? = UIImage(systemName: "checkmark")
            imageView.image = checkedImage
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addFriendsTable.dequeueReusableCell(withIdentifier: "addFriendsTableViewCell", for: indexPath) as! addFriendsTableViewCell
        let username = self.playerUsernamesIDs[indexPath.row]["username"] as! String
        let id = self.playerUsernamesIDs[indexPath.row]["id"] as! Int
        if self.addedPlayerIDs.contains(id) {
            // set image as checked
            let checkedImage:UIImage? = UIImage(systemName: "checkmark")
            cell.checkImageView.image = checkedImage
        } else {
            // set image as unchecked
            cell.checkImageView.image = nil
        }
        cell.configure(id: id, username: username)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerUsernamesIDs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}
