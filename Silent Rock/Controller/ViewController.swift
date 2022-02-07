//
//  ViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 11/10/21.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var playerID: Int? = nil
    var playerIDs: Array<Int?> = []
    let locationManager:CLLocationManager = CLLocationManager()
    var inRegion:Bool = false
    let player: Player = Player()
    
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
        
        // enable the right buttons
        stopButton.isEnabled = false
        startButton.isEnabled = true
        warningLabel.isHidden = true
        exitButton.isHidden = true
        errorMessageLabel.text = ""
        
        // set up location manager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true //for alarm
        locationManager.distanceFilter = 5 // filters out updates till it's traveled x meters. Set to 5 for testing purposes
        
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
            addFriendsButton.setTitle("Sign in to add friends", for: .normal)
            addFriendsButton.isEnabled = false
            addFriendsButton.setTitleColor(UIColor.gray, for: .normal)
        } else {
            addFriendsButton.setTitle("Add friends", for: .normal)
        }
        addFriendsTable.isHidden = true
        addFriendsTable.delegate = self
        addFriendsTable.dataSource = self
        addFriendsTable.register(UITableViewCell.self, forCellReuseIdentifier: "addFriendsCell")
    }
    
    // hide table when tapped around
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != addFriendsTable {
            addFriendsTable.isHidden = true
        }
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    // opens and closes the table view
    @IBAction func addFriendsButtonTapped(_ sender: Any) {
        //        update this later!
        addFriendsTable.heightAnchor.constraint(equalToConstant: 60).isActive = true
        addFriendsTable.isHidden = !addFriendsTable.isHidden
    }
    
    
    func soundAlarm() {
        if stopButton.isEnabled {
            backgroundColor.backgroundColor = #colorLiteral(red: 0.7536441684, green: 0.07891514152, blue: 0.2141970098, alpha: 1)
            startButton.isHidden = true
            stopButton.isHidden = true
            warningLabel.isHidden = false
            exitButton.isHidden = false
            sendLocalNotification()
        }
    }
    
    func alarmOff() {
        backgroundColor.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.009361755543, alpha: 0)
        startButton.isHidden = false
        stopButton.isHidden = false
        warningLabel.isHidden = true
        exitButton.isHidden = true
        errorMessageLabel.text = ""
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
        alarmOff()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        stopButton.isEnabled = true
        startButton.isEnabled = false
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopButton.isEnabled = false
        startButton.isEnabled = true
        locationManager.stopUpdatingLocation()
    }
    

    
//    Acutal silent rock coordinates
    let targetLat:Double = 45.306558
    let targetLon:Double = -121.830166
    let span:Double = 0.005
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let lat: Double = locValue.latitude
        let lon: Double = locValue.longitude
        // Creating didEnterRegion basically
        if (targetLat - span < lat && lat < targetLat + span) && (targetLon - span < lon && lon < targetLon + span) {
            if !inRegion {
                soundAlarm()
                inRegion = true
                
                // only add trip to DB if a user is logged in - don't let them add friends if don't have an account
                if self.playerID != nil {
                    self.playerIDs.append(self.playerID)
                    self.player.addTrip(vc: self, completion: { tripID in
                        self.player.addTripToUsers(vc: self, tripID: tripID, playerIDs: self.playerIDs) // REVISIT
                    })
                }
            }
        } else {
            if inRegion {
                alarmOff()
                inRegion = false
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
        } else if segue.destination is leaderboardViewController {
            let lvc = segue.destination as? leaderboardViewController
            lvc?.playerID = self.playerID
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
        print("selected cell")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addFriendsTable.dequeueReusableCell(withIdentifier: "addFriendsCell", for: indexPath)
        cell.textLabel?.text = "friend 1"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
