//
//  profileViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/30/22.
//

import UIKit

class profileViewController: UIViewController {
    
    let player: Player = Player()
    @IBOutlet weak var errorMessageLabel: UILabel!
    var playerID: Int? = nil
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var cancelButton: BorderButton!
    @IBOutlet weak var submitButton: BorderButton!
    @IBOutlet weak var editUsernameButton: BorderButton!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide update username buttons
        usernameTextField.isHidden = true
        cancelButton.isHidden = true
        submitButton.isHidden = true
        
        // Set username
        player.getPhoneUsername(playerID: self.playerID!, vc: self, completion: {json in
            DispatchQueue.main.async {
                self.usernameLabel.text = ((json as NSDictionary)["username"] as! String)
                self.phoneNumberLabel.text = ((json as NSDictionary)["phone"] as! String)
                if ((json as NSDictionary)["visible_on_leaderboard"] as! Bool) {
                    // checkbox checked
                    let checkedImage:UIImage? = UIImage(named: "Checkbox-checked-1.png")
                            
                    // Set above UIImage object as button icon.
                    self.checkboxImage.image = checkedImage

                } else {
                    // checkbox unchecked
                    let uncheckedImage:UIImage? = UIImage(named: "Checkbox-unchecked-1.png")
                            
                    // Set above UIImage object as button icon.
                    self.checkboxImage.image = uncheckedImage
                }
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.playerID = self.playerID
        }
    }

}
