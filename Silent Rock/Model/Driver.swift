//
//  Driver.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 11/10/21.
//

import Foundation
import CoreLocation

class Driver: NSObject, CLLocationManagerDelegate {
    // get location, is approaching silent rock, how long to wait functions
    
    override init() {
        super.init()
        let locationManager:CLLocationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100 //filters out updates till it has traveled 100m,maybe I can make it dynamic
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(45.3066, 121.8305), radius: 1000, identifier: "Silent Rock") // radius is in meters
        locationManager.startMonitoring(for: geoFenceRegion)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited \(region.identifier)")
    }
}
