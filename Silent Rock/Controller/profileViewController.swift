//
//  profileViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/30/22.
//

import UIKit

class profileViewController: UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signOutButton.contentMode = .center
        signOutButton.imageView?.contentMode = .scaleAspectFit

        // Do any additional setup after loading the view.
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
