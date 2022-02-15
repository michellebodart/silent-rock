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
    let state = UIApplication.shared.applicationState
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enable the right buttons
        stopButton.isEnabled = false
        startButton.isEnabled = true
        warningLabel.isHidden = true
        exitButton.isHidden = true
        
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
        
    }
    
    func soundAlarm() {
        if stopButton.isEnabled {
            backgroundColor.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.009361755543, alpha: 1)
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
    }
    
    func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "APPROACHING SILENT ROCK"
        content.subtitle = "SHHHHHH"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "LocalNotificationSound.mp3"))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false) //Maybe update this to a location based trigger?
        
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
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopButton.isEnabled = false
        startButton.isEnabled = true
        locationManager.stopUpdatingLocation()
    }
    
    var inRegion:Bool = false
//    For testing near my house
    let targetLat:Double = 47.654158
    let targetLon:Double = -122.348596
    let span:Double = 0.0002
    
//    Acutal silent rock coordinates
//    let targetLat:Double = 45.306558
//    let targetLon:Double = -121.830166
//    let span:Double = 0.005
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let lat: Double = locValue.latitude
        let lon: Double = locValue.longitude
        // Creating didEnterRegion basically
        if (targetLat - span < lat && lat < targetLat + span) && (targetLon - span < lon && lon < targetLon + span) {
            if !inRegion {
                soundAlarm()
                inRegion = true
            }
        } else {
            if inRegion {
                alarmOff()
                inRegion = false
            }
        }
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
}

