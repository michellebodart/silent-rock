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
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 5 // filters out updates till it's traveled x meters. Set to 5 for testing purposes
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
                try AVAudioSession.sharedInstance().setCategory(.playback)
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
    
    //testing current locaiton
    
//    @IBOutlet weak var targetLocation: UILabel!
//    @IBOutlet weak var currentLocation: UILabel!
    
    var inRegion:Bool = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // still doesn't work if you're in the location when you press start
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let lat: Double = locValue.latitude
        let lon: Double = locValue.longitude
//        currentLocation.text = "\(lat), \(lon)"
//        targetLocation.text = "47.624 - 47.625,\n -122.327 - -122.326"
        // Creating didEnterRegion basically
        if (47.624 < lat && lat < 47.625) && (-122.327 < lon && lon < -122.326) {
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

