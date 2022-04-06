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
    var playerUsername: String? = nil
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signInButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.isEnabled = false
        
        self.hideKeyboardWhenTappedAround()
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.hidesBackButton = false
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
            self.errorMessageLabel.text = "loading..."
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
                self.playerUsername = ((player as! NSDictionary)["username"] as! String)
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
    
    @IBAction func useWithoutAccountTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vvc = segue.destination as? verificationViewController
            vvc?.phoneNumber = phoneNumberTextField.text ?? ""
            vvc?.verificationID = self.verificationID
            vvc?.playerID = self.playerID
            vvc?.playerUsername = self.playerUsername
        } else if segue.destination is registerViewController {
            let rvc = segue.destination as? registerViewController
            rvc?.phoneNumber = phoneNumberTextField.text ?? ""
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
