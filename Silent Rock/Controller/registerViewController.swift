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
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = phone.format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")
        
        var phoneNumberIsValid = phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? ""
        )
        if !phoneNumberIsValid {
            phoneNumberErrorMessage.text = "Please enter a valid phone number"
        } else {
            phoneNumberErrorMessage.text = ""
        }
        if (phoneNumberIsValid && usernameTextField.text != "") {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
    
    @IBAction func usernameTextFieldUpdated(_ sender: Any) {
        usernameTextField.text = username.format(with: "XXXXXXXXXXXXXXXXXXXX", phone: usernameTextField.text ?? "")
        usernameErrorMessage.text = ""
        if ((phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? "")) && usernameTextField.text != "") {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
            
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text, let username = usernameTextField.text {
            player.checkPlayerDataFromRegister(phoneNumber: phoneNumber, username: username, vc: self, completion: { phoneNumber, username, json, vc in
                self.self.player.signUpOrError(phoneNumber: phoneNumber, username: username, json: json, vc: vc)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vvc = segue.destination as? verificationViewController
            vvc?.phoneNumber = phoneNumberTextField.text ?? ""
            vvc?.verificationID = self.verificationID
            vvc?.username = usernameTextField.text ?? ""
        }
    }
}
