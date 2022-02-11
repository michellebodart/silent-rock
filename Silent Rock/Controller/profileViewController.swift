//
//  profileViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/30/22.
//

import UIKit

class profileViewController: UIViewController {
    
    var playerID: Int? = nil
    var playerUsername: String? = nil
    var visibleOnLeaderboard: Bool = true
    var addedPlayerIDs: Array<Int?> = []
    var alreadyStartedUpdatingLocation: Bool = false
    var pendingTrips: Array<Dictionary<String, Any>> = []
    var notificationCellHeight: Int = 90
    
    let username: Username = Username()
    let player: Player = Player()
    let phone: Phone = Phone()
    
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
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var notificationTable: UITableView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var cancelSubmitPhoneStackView: UIStackView!
    @IBOutlet weak var submitPhoneButton: UIButton!
    @IBOutlet weak var cancelPhoneButton: UIButton!
    @IBOutlet weak var editPhoneButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up notification table
        self.notificationTable.dataSource = self
        self.notificationTable.delegate = self
        self.notificationTable.register(NotificationTableViewCell.nib(), forCellReuseIdentifier: NotificationTableViewCell.identifier)
        self.notificationTable.isHidden = true
        
        // Hide update username buttons
        usernameTextField.isHidden = true
        cancelButton.isHidden = true
        submitButton.isHidden = true
        
        // Hide delete/are you sure button and refrehs button
        areYouSureStack.isHidden = true
        refreshButton.isHidden = true
        
        // Hide update phone buttons
        phoneNumberTextField.isHidden = true
        cancelSubmitPhoneStackView.isHidden = true
        
        
        // Set username, phone, notifications, and checkbox if api call successful
        player.getPhoneUsername(playerID: self.playerID!, vc: self, completion: {json in
            self.parsePlayerData(json: json)
            DispatchQueue.main.async {
                self.notificationTable.reloadData()
            }
        })
        
        // hide everything until api call works
        apiItemsHidden(bool: true)
        
        // Hide keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    // Hide notifications when tapped around
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != self.notificationTable {
            self.notificationTable.isHidden = true
        }
    }
    
    func parsePlayerData(json: Dictionary<String, Any>) {
        DispatchQueue.main.async {
            self.usernameLabel.text = ((json as NSDictionary)["username"] as! String)
            self.phoneNumberLabel.text = ((json as NSDictionary)["phone"] as! String)
            self.visibleOnLeaderboard = ((json as NSDictionary)["visible_on_leaderboard"] as! Bool)
            self.pendingTrips = ((json as NSDictionary)["pending_trips"] as! Array<Dictionary<String, Any>>)
            if self.pendingTrips.count == 0 {
                self.notificationButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            } else {
                self.notificationButton.tintColor = #colorLiteral(red: 0.7536441684, green: 0.07891514152, blue: 0.2141970098, alpha: 1)
            }
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
    
    @IBAction func notificationButtonTapped(_ sender: Any) {
        self.notificationTable.isHidden = !self.notificationTable.isHidden
        print(self.pendingTrips)
        let tableHeight: CGFloat
        if self.pendingTrips.count < 1 {
            tableHeight = CGFloat(self.notificationCellHeight)
        } else {
            tableHeight = CGFloat(min(self.pendingTrips.count * self.notificationCellHeight, 3*60))
        }
        self.notificationTable.heightAnchor.constraint(equalToConstant: tableHeight).isActive = false
        self.notificationTable.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        self.notificationTable.reloadData()
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
    
    @IBAction func editPhoneButtonTapped(_ sender: Any) {
        self.phoneNumberTextField.text = ""
        self.submitPhoneButton.isEnabled = false
        self.phoneNumberLabel.isHidden = true
        self.editPhoneButton.isHidden = true
        self.phoneNumberTextField.isHidden = false
        self.cancelSubmitPhoneStackView.isHidden = false
    }
    
    @IBAction func usernameTextFieldUpdated(_ sender: Any) {
        // formats the user input to limit certain characters and limit to 20 characters
        usernameTextField.text = username.format(with: "XXXXXXXXXXXXXXXXXXXX", username: usernameTextField.text ?? "")
        errorMessageLabel.text = ""
        if  (usernameTextField.text ?? "").count > 5 {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
            
        }
    }
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = phone.format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")

        let phoneNumberIsValid = phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? "")
        if !phoneNumberIsValid {
            errorMessageLabel.text = "Please enter a valid phone number"
            submitPhoneButton.isEnabled = false
        } else {
            errorMessageLabel.text = ""
            submitPhoneButton.isEnabled = true
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
    
    @IBAction func cancelPhoneButtonTapped(_ sender: Any) {
        self.phoneNumberLabel.isHidden = false
        self.editPhoneButton.isHidden = false
        self.phoneNumberTextField.isHidden = true
        self.errorMessageLabel.text = ""
        self.cancelSubmitPhoneStackView.isHidden = true
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        // disable submit phone button
        self.submitPhoneButton.isEnabled = false
        // updates username in DB, if successful, returns to main page, otherwise displays an error message
        player.updateUsername(playerID: self.playerID!, username: self.usernameTextField.text!, vc: self, completion: {
            DispatchQueue.main.async {
                self.submitButton.isHidden = true
                self.cancelButton.isHidden = true
                self.usernameTextField.isHidden = true
                self.usernameLabel.isHidden = false
                self.editUsernameButton.isHidden = false
                self.usernameLabel.text = self.usernameTextField.text!
                self.submitPhoneButton.isEnabled = true
            }
        })
    }
    
    @IBAction func checkboxTapped(_ sender: Any) {
        // sends API call to update users' settings, if unsuccessful displays an error message
        player.updateShowOnLeaderboard(playerID: self.playerID!, visibleOnLeaderboard: self.visibleOnLeaderboard, vc: self, completion: {
            DispatchQueue.main.async {
                self.setCheckbox(checked: self.visibleOnLeaderboard)
            }
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
            vc?.playerUsername = self.playerUsername
            vc?.addedPlayerIDs = self.addedPlayerIDs
            vc?.alreadyStartedUpdatingLocation = self.alreadyStartedUpdatingLocation
        } else if segue.destination is leaderboardViewController {
            let lvc = segue.destination as? leaderboardViewController
            lvc?.playerID = self.playerID
            lvc?.playerUsername = self.playerUsername
            lvc?.addedPlayerIDs = self.addedPlayerIDs
            lvc?.alreadyStartedUpdatingLocation = self.alreadyStartedUpdatingLocation
        } else if segue.destination is leaderboardDetailViewController {
            let ldvc = segue.destination as? leaderboardDetailViewController
            ldvc?.detailPlayerID = self.playerID
            ldvc?.playerID = self.playerID
            ldvc?.playerUsername = self.playerUsername
            ldvc?.detailPlayerUsername = self.usernameLabel.text ?? ""
            ldvc?.returnTo = "profile"
            ldvc?.addedPlayerIDs = self.addedPlayerIDs
            ldvc?.alreadyStartedUpdatingLocation = self.alreadyStartedUpdatingLocation
        }
    }

}

// Setting up notification table
extension profileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected a notification")
    }
}

extension profileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.pendingTrips.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationTable.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        if self.pendingTrips.count == 0 {
            // no notifications
            cell.configure(notificationText: "No new notifications", tripID: nil, playerID: nil, vc: self)
            cell.acceptButton.isHidden = true
            cell.rejectButton.isHidden = true
        } else {
            let trip = self.pendingTrips[indexPath.row]
            let dateTime = (trip["date"] as! String).split(separator: "!")
            let date = String(dateTime[0])
            let time = String(dateTime[1])
            let username = trip["trip_owner_username"] as! String
            let notificationText = "\(username) added you to their \(time) trip on \(date)"
            let tripID = trip["id"] as! Int
            let playerID = self.playerID!
            cell.configure(notificationText: notificationText, tripID: tripID, playerID: playerID, vc: self)
            cell.acceptButton.isHidden = false
            cell.rejectButton.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.notificationCellHeight)
    }
}
