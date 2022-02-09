//
//  registerViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/24/22.
//

import UIKit
import Firebase

class registerViewController: UIViewController {
    
    var phone: Phone = Phone()
    var username: Username = Username()
    var player: Player = Player()
    var phoneNumber: String = ""
    var verificationID:String = ""
    var phoneNumberUsed: Bool = false //NEW
    var usernameUsed: Bool = false //NEW
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberErrorMessage: UILabel!
    @IBOutlet weak var usernameErrorMessage: UILabel!
    @IBOutlet weak var signUpButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.text = phoneNumber
        signUpButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = phone.format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")
        
        let phoneNumberIsValid = phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? ""
        )
        if !phoneNumberIsValid {
            phoneNumberErrorMessage.text = "Please enter a valid phone number"
        } else {
            phoneNumberErrorMessage.text = ""
        }
        if (phoneNumberIsValid && (usernameTextField.text ?? "").count > 5) {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
    
    @IBAction func usernameTextFieldUpdated(_ sender: Any) {
        usernameTextField.text = username.format(with: "XXXXXXXXXXXXXXXXXXXX", username: usernameTextField.text ?? "")
        usernameErrorMessage.text = ""
        if ((phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? "")) && (usernameTextField.text ?? "").count > 5) {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
            
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text, let username = usernameTextField.text {
            player.checkPlayerDataFromRegister(phoneNumber: phoneNumber, username: username, vc: self, completion: { phoneNumber, username, json in
                self.signUpOrError(phoneNumber: phoneNumber, username: username, json: json)
            })
        }
    }
    
    func signUpOrError(phoneNumber: String, username: String, json: Array<Any> ) -> Void {
        var phoneUsed = false
        var usernameUsed = false
        for player in json {
            let phone = (player as! NSDictionary)["phone"]
            let playerUsername = (player as! NSDictionary)["username"]
            if phoneNumber == (phone! as! String) {
                phoneUsed = true
            }
            if username == (playerUsername! as! String) {
                usernameUsed = true
            }
        }
        if phoneUsed || usernameUsed {
            DispatchQueue.main.async {
                self.signUpButton.isEnabled = false
                if phoneUsed {
                    self.phoneNumberErrorMessage.text = "The phone number you entered is already registered with an account"
                    self.phoneNumberTextField.text = ""
                } else {
                    self.phoneNumberErrorMessage.text = ""
                }
                if usernameUsed {
                    self.usernameErrorMessage.text = "Sorry, that username is taken"
                    self.usernameTextField.text = ""
                } else {
                    self.usernameErrorMessage.text = ""
                }
            }
        } else {
            self.player.verifyFromRegister(phoneNumber: phoneNumber, vc: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vvc = segue.destination as? verificationViewController
            vvc?.phoneNumber = phoneNumberTextField.text ?? ""
            vvc?.verificationID = self.verificationID
            vvc?.playerUsername = usernameTextField.text ?? ""
            vvc?.newPlayer = true
        }
    }
}
