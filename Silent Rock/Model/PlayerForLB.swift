//
//  PlayerForLB.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/1/22.
//

import Foundation
import UIKit

class PlayerForLB {
    
    var username: String
    var id: Int
    var trips: Array<Trip?>
    
    init( username: String, id: Int, trips: Array<Trip?>) {
        self.username = username
        self.id = id
        self.trips = trips
    }
}

class Trip {
    var date: String
    var season: String
    var id: Int
    
    init( date: String, season: String, id: Int) {
        self.date = date
        self.season = season
        self.id = id
    }
}
