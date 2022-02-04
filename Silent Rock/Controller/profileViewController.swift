//
//  profileViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/30/22.
//

import UIKit

class profileViewController: UIViewController {
    
    var playerID: Int? = nil
    var visibleOnLeaderboard: Bool = true
    
    let username: Username = Username()
    let player: Player = Player()
    
    @IBOutlet weak var viewMyTripsButton: BorderButton!
    @IBOutlet weak var refreshButton: BorderButton!
    @IBOutlet weak var areYouSureStack: UIStackView!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var cancelButton: BorderButton!
    @IBOutlet weak var submitButton: BorderButton!
    @IBOutlet weak var editUsernameButton: BorderButton!
    @IBOutlet weak var checkboxImage: UIImageView!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var deleteAccountButton: BorderButton!
    @IBOutlet weak var signOutButton: BorderButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide update username buttons
        usernameTextField.isHidden = true
        cancelButton.isHidden = true
        submitButton.isHidden = true
        areYouSureStack.isHidden = true
        refreshButton.isHidden = true
        
        // Set username, phone, and checkbox if api call successful
        player.getPhoneUsername(playerID: self.playerID!, vc: self, completion: {json in
            self.displayPlayerData(json: json)
        })
        
        // hide everything until api call works
        apiItemsHidden(bool: true)
        
        // Hide keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    func displayPlayerData(json: Dictionary<String, Any>) {
        DispatchQueue.main.async {
            self.usernameLabel.text = ((json as NSDictionary)["username"] as! String)
            self.phoneNumberLabel.text = ((json as NSDictionary)["phone"] as! String)
            self.visibleOnLeaderboard = ((json as NSDictionary)["visible_on_leaderboard"] as! Bool)
            self.setCheckbox(checked: self.visibleOnLeaderboard)
            self.apiItemsHidden(bool: false)
            self.errorMessageLabel.text = ""
        }
    }
    
    func setCheckbox(checked: Bool) {
        DispatchQueue.main.async {
            if checked {
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
    }
    
    @IBAction func editUsernameButtonTapped(_ sender: Any) {
        self.usernameTextField.text = ""
        self.submitButton.isEnabled = false
        self.usernameLabel.isHidden = true
        self.editUsernameButton.isHidden = true
        self.usernameTextField.isHidden = false
        self.cancelButton.isHidden = false
        self.submitButton.isHidden = false
    }
    
    @IBAction func usernameTextFieldUpdated(_ sender: Any) {
        // formats the user input to limit certain characters and limit to 20 characters
        usernameTextField.text = username.format(with: "XXXXXXXXXXXXXXXXXXXX", username: usernameTextField.text ?? "")
        errorMessageLabel.text = ""
        if  usernameTextField.text != "" {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
            
        }
    }
    
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.viewDidLoad()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.usernameLabel.isHidden = false
        self.editUsernameButton.isHidden = false
        self.usernameTextField.isHidden = true
        self.cancelButton.isHidden = true
        self.submitButton.isHidden = true
        self.errorMessageLabel.text = ""
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        // updates username in DB, if successful, returns to main page, otherwise displays an error message
        player.updateUsername(playerID: self.playerID!, username: self.usernameTextField.text!, vc: self, completion: {
            DispatchQueue.main.async {
                self.submitButton.isHidden = true
                self.cancelButton.isHidden = true
                self.usernameTextField.isHidden = true
                self.usernameLabel.isHidden = false
                self.editUsernameButton.isHidden = false
                self.usernameLabel.text = self.usernameTextField.text!
            }
        })
    }
    
    @IBAction func checkboxTapped(_ sender: Any) {
        // sends API call to update users' settings, if unsuccessful displays an error message
        player.updateShowOnLeaderboard(playerID: self.playerID!, visibleOnLeaderboard: self.visibleOnLeaderboard, vc: self, completion: {
            self.setCheckbox(checked: self.visibleOnLeaderboard)
        })
    }
    
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        // presents are you sure options
        self.areYouSureStack.isHidden = false
        self.deleteAccountButton.isHidden = true
    }
    
    @IBAction func cancelDeleteAccountButtonTapped(_ sender: Any) {
        // returns to main page witwhout deleting account
        self.areYouSureStack.isHidden = true
        self.deleteAccountButton.isHidden = false
    }
    
    @IBAction func confirmDeleteAccountButtonTapped(_ sender: Any) {
        // deletes account from DB, if successful, returns to sign in page, else, shows an error message
        player.deletePlayer(playerID: self.playerID!, vc: self, completion: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginView", sender: self)
            }
        })
    }
    
    
    func apiItemsHidden(bool: Bool) -> Void {
        self.checkboxButton.isHidden = bool
        self.editUsernameButton.isHidden = bool
        self.usernameLabel.isHidden = bool
        self.phoneNumberLabel.isHidden = bool
        self.checkboxImage.isHidden = bool
        self.checkboxLabel.isHidden = bool
        self.deleteAccountButton.isHidden = bool
        self.viewMyTripsButton.isHidden = bool
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // always send player ID, so the views know if the user is logged in or if we are using without account
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.playerID = self.playerID
        } else if segue.destination is leaderboardViewController {
            let lvc = segue.destination as? leaderboardViewController
            lvc?.playerID = self.playerID
        } else if segue.destination is leaderboardDetailViewController {
            let ldvc = segue.destination as? leaderboardDetailViewController
            ldvc?.detailPlayerID = self.playerID
            ldvc?.playerID = self.playerID
            ldvc?.detailPlayerUsername = self.usernameLabel.text ?? ""
            ldvc?.returnTo = "profile"
        }
    }

}
