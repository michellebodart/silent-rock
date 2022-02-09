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
    var addedPlayerIDs: Array<Int?> = []
    var playerUsernamesIDs: Array<Dictionary<String, Any>> = []
    var locationManager: CLLocationManager? = CLLocationManager()
    var appDelegate: AppDelegate = AppDelegate()
    var inRegion: Bool = false
    let player: Player = Player()
    var tracking: Bool = true
    var alreadyStartedUpdatingLocation: Bool = false
    
    //    Acutal silent rock coordinates
//    let targetLat:Double = 45.306558
//    let targetLon:Double = -121.830166
//    let span:Double = 0.005
    
//    For testing near my house
    let targetLat:Double = 47.654151
    let targetLon:Double = -122.348564
    let span:Double = 0.0002
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var addFriendsTable: UITableView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var backgroundColor: UIImageView!
    @IBOutlet weak var startButton: BorderButton!
    @IBOutlet weak var stopButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load!")
        
        // check if in region, if in region, make screen red etc
        // enable the right buttons
        // if tracking, stop is enabled, if not, start is enabled
        self.setInRegion()
        if self.tracking {
            // resetting the location manager fixes a bug but introduces a new worse bug
//            self.locationManager!.stopUpdatingLocation()
//            self.locationManager!.startUpdatingLocation()
            self.stopButton.isEnabled = true
            self.startButton.isEnabled = false
            if self.inRegion {
                self.backgroundColor.backgroundColor = #colorLiteral(red: 0.7536441684, green: 0.07891514152, blue: 0.2141970098, alpha: 1)
                self.startButton.isHidden = true
                self.stopButton.isHidden = true
                self.addFriendsButton.isHidden = true
                self.addFriendsTable.isHidden = true
                self.warningLabel.isHidden = false
                self.exitButton.isHidden = false
            } else {
                self.warningLabel.isHidden = true
                self.exitButton.isHidden = true
                self.errorMessageLabel.text = ""
            }
        } else {
            self.stopButton.isEnabled = false
            self.startButton.isEnabled = true
            self.warningLabel.isHidden = true
            self.exitButton.isHidden = true
            self.errorMessageLabel.text = ""
        }
        
        // set up location manager
        self.locationManager = nil
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.allowsBackgroundLocationUpdates = true //for alarm
        self.locationManager!.distanceFilter = 5 // filters out updates till it's traveled x meters. Set to 5 for testing purposes
        
        if !self.alreadyStartedUpdatingLocation {
            self.locationManager!.startUpdatingLocation()
            print("starting to update location")
            self.alreadyStartedUpdatingLocation = true
        }
        
        
        // Set up local notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        // set up table view
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
        }
    }
    
    
    func soundAlarm() {
        if self.tracking {
            DispatchQueue.main.async {
                self.backgroundColor.backgroundColor = #colorLiteral(red: 0.7536441684, green: 0.07891514152, blue: 0.2141970098, alpha: 1)
                self.startButton.isHidden = true
                self.stopButton.isHidden = true
                self.addFriendsButton.isHidden = true
                self.addFriendsTable.isHidden = true
                self.warningLabel.isHidden = false
                self.exitButton.isHidden = false
                self.sendLocalNotification()
            }
        }
    }
    
    func alarmOff() {
        DispatchQueue.main.async {
            self.backgroundColor.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.009361755543, alpha: 0)
            self.startButton.isHidden = false
            self.stopButton.isHidden = false
            self.addFriendsButton.isHidden = false
            self.warningLabel.isHidden = true
            self.exitButton.isHidden = true
            self.errorMessageLabel.text = ""
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
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.alarmOff()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        self.stopButton.isEnabled = true
        self.startButton.isEnabled = false
        self.tracking = true
//        self.locationManager!.startUpdatingLocation()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        self.stopButton.isEnabled = false
        self.startButton.isEnabled = true
        self.tracking = false
//        self.locationManager!.stopUpdatingLocation()
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
                self.soundAlarm()
                self.inRegion = true

                // only add trip to DB if a user is logged in - don't let them add friends if don't have an account
                if self.playerID != nil {
                    print("about to add trip")
                    self.player.addTrip(vc: self, completion: { tripID in
                        self.player.addTripToUsers(vc: self, tripID: tripID, playerIDs: [self.playerID], completion: { tripID in
                            self.player.addPendingTripToUsers(vc: self, tripID: tripID, playerIDs: self.addedPlayerIDs, tripOwnerID: self.playerID!)
                        })
                    })
                }
            }
        } else {
            if self.inRegion {
                self.alarmOff()
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
            pvc?.playerID = self.playerID
            pvc?.addedPlayerIDs = self.addedPlayerIDs
            pvc?.tracking = self.tracking
            pvc?.alreadyStartedUpdatingLocation = self.alreadyStartedUpdatingLocation
        } else if segue.destination is leaderboardViewController {
            let lvc = segue.destination as? leaderboardViewController
            lvc?.playerID = self.playerID
            lvc?.addedPlayerIDs = self.addedPlayerIDs
            lvc?.tracking = self.tracking
            lvc?.alreadyStartedUpdatingLocation = self.alreadyStartedUpdatingLocation
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
