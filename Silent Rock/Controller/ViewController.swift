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
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isEnabled = false
        startButton.isEnabled = true
        warningLabel.isHidden = true
        exitButton.isHidden = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.activityType = .other //not sure if I need this
        locationManager.allowsBackgroundLocationUpdates = true //for alarm
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 5 // filters out updates till it's traveled x meters. Set to 5 for testing purposes
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {success, error in
            if success {
                print("fine")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func soundAlarm() {
        if stopButton.isEnabled {
            backgroundColor.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.009361755543, alpha: 1)
            startButton.isHidden = true
            stopButton.isHidden = true
            warningLabel.isHidden = false
            exitButton.isHidden = false
            
                // set up player and play
            let urlString = Bundle.main.path(forResource: "arcade", ofType: "wav")

            do {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

                guard let urlString = urlString else {
                    return
                }

                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))

                    guard let player = player else {
                        return
                    }

                player.play()

            }
            catch {
                print("something went wrong")
            }

        }
    }
    
    func alarmOff() {
        backgroundColor.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.009361755543, alpha: 0)
        startButton.isHidden = false
        stopButton.isHidden = false
        warningLabel.isHidden = true
        exitButton.isHidden = true
    }
    
    func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "APPROACHING SILENT ROCK"
        content.subtitle = "SHHHHHH"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "arcade.wav"))
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false) //Maybe update this to a location based trigger?
        
//        let center = CLLocationCoordinate2D(latitude: targetLat, longitude: targetLon)
//        let region = CLCircularRegion(center: center, radius: 5, identifier: "silent rock") // not sure how big the radius should be
//        let trigger = UNLocationNotificationTrigger(region: region, repeats: false) //not sure if this should repeat or not
        
        let request = UNNotificationRequest(identifier: "Silent rock notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        alarmOff()
    }
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var backgroundColor: UIImageView!
    @IBOutlet weak var startButton: BorderButton!
    @IBOutlet weak var stopButton: BorderButton!
    
    
    @IBAction func startButtonPressed(_ sender: Any) {
        stopButton.isEnabled = true
        startButton.isEnabled = false
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopButton.isEnabled = false
        startButton.isEnabled = true
    }
    
    var inRegion:Bool = false
//    For testing near my house
    let targetLat:Double = 47.623549
    let targetLon:Double = -122.326578
    let span:Double = 0.0002
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // still doesn't work if you're in the location when you press start
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let lat: Double = locValue.latitude
        let lon: Double = locValue.longitude
        // Creating didEnterRegion basically
        if (targetLat - span < lat && lat < targetLat + span) && (targetLon - span < lon && lon < targetLon + span) {
            if !inRegion {
                soundAlarm() //put  this back later!
                inRegion = true
                sendLocalNotification()
            }
        } else {
            if inRegion {
                alarmOff()
                inRegion = false
            }
        }
    }
}

