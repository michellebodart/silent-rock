//
//  loginViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/24/22.
//

import UIKit
import Firebase
import Contacts

class loginViewController: UIViewController {
    let phone: Phone = Phone()
    let player: Player = Player()
    var verificationID: String = ""
    var playerID: Int? = nil
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signInButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        phoneNumberTextField.text = "+1"
        signInButton.isEnabled = false
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = phone.format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")

        let phoneNumberIsValid = phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? "")
        if !phoneNumberIsValid {
            errorMessageLabel.text = "Please enter a valid phone number"
            signInButton.isEnabled = false
        } else {
            errorMessageLabel.text = ""
            signInButton.isEnabled = true
        }
    }

    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text {
            player.checkPlayerDataFromLogin(phoneNumber: phoneNumber, vc: self, completion: { phoneNumber, json in
                self.signInOrError(phoneNumber: phoneNumber, json: json)
            })
        }
    }
    
    func signInOrError(phoneNumber: String, json: Array<Any>) -> Void {
        var phoneUsed = false
        for player in json {
            let phone = (player as! NSDictionary)["phone"]
            if phoneNumber == (phone! as! String) {
                phoneUsed = true
                self.playerID = ((player as! NSDictionary)["id"] as! Int)
            }
        }
        if !phoneUsed {
            DispatchQueue.main.async {
                self.signInButton.isEnabled = false
                self.errorMessageLabel.text = "The phone number you entered is not registered with an account"
            }
        } else {
            self.player.verifyFromLogin(phoneNumber: phoneNumber, vc: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vvc = segue.destination as? verificationViewController
            vvc?.phoneNumber = phoneNumberTextField.text ?? ""
            vvc?.verificationID = self.verificationID
            vvc?.playerID = self.playerID
        } else if segue.destination is registerViewController {
            let rvc = segue.destination as? registerViewController
            rvc?.phoneNumber = phoneNumberTextField.text ?? ""
        } else if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.playerID = 29
//            DELETE THIS -MB
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
