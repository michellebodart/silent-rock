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
        
        // Set username, phone, and checkbox
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
    
    
    @IBAction func editUsernameButtonTapped(_ sender: Any) {
        self.usernameLabel.isHidden = true
        self.editUsernameButton.isHidden = true
        self.usernameTextField.isHidden = false
        self.cancelButton.isHidden = false
        self.submitButton.isHidden = false
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.usernameLabel.isHidden = false
        self.editUsernameButton.isHidden = false
        self.usernameTextField.isHidden = true
        self.usernameTextField.text = ""
        self.cancelButton.isHidden = true
        self.submitButton.isHidden = true
        self.errorMessageLabel.text = ""
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        player.updateUsername(playerID: self.playerID!, username: self.usernameTextField.text!, vc: self, completion: {
            self.submitButton.isHidden = true
            self.cancelButton.isHidden = true
            self.usernameTextField.isHidden = true
            self.usernameLabel.isHidden = false
            self.editUsernameButton.isHidden = false
            self.player.getPhoneUsername(playerID: self.playerID!, vc: self, completion: {json in
                DispatchQueue.main.async {
                    self.usernameLabel.text = ((json as NSDictionary)["username"] as! String)
                }
            })
        })
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        player.deletePlayer(playerID: self.playerID!, vc: self, completion: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginView", sender: self)
            }
        })
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.playerID = self.playerID
        }
    }

}
