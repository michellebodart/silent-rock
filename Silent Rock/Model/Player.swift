//
//  Player.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/27/22.
//

import UIKit

class Player: NSObject {
    var phone: String = ""
    var id: Int = 1
    var username: String = ""
    var trips: [Trip] = []

}

class Trip: NSObject {
    var date: String = ""
    var id: Int = 1
    var season: String = ""
}
