//
//  TabBarController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 3/13/22.
//

import UIKit

class TabBarController: UITabBarController {

    var playerID: Int? = nil
    var playerUsername: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults().integer(forKey: "PlayerID") == 0 {
            playerID = nil
        } else {
            playerID = UserDefaults().integer(forKey: "PlayerID")
        }
        playerUsername = UserDefaults().string(forKey: "PlayerUsername")

        // Do any additional setup after loading the view.
    }

}
