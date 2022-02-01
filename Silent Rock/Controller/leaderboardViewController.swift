//
//  leaderboardViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 2/1/22.
//

import UIKit

class leaderboardViewController: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    let player: Player = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.getPlayerDataFromLeaderboard(vc: self, completion: {json in
            self.doAfterGetPlayerData(json: json)
        })

        // Do any additional setup after loading the view.
    }
    
    func doAfterGetPlayerData(json: Array<Any>) {
        print(json)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
