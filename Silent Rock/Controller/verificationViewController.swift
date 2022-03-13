//
//  verificationViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/25/22.
//

import UIKit
import Firebase

class verificationViewController: UIViewController {

    var playerID: Int? = nil
    var playerUsername: String? = nil
    var newPlayer: Bool = false
    let player: Player = Player()
    let verificationCode: VerificationCode = VerificationCode()
    @IBOutlet weak var verificationCodeTextField: UITextField!
    var phoneNumber: String = ""
    var verificationID: String = ""
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signInButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    // Disable screen rotation
    override var shouldAutorotate: Bool {
            return false
        }

    @IBAction func verificationCodeTextFieldUpdated(_ sender: Any) {
        verificationCodeTextField.text = verificationCode.format(with: "XXXXXX", code: verificationCodeTextField.text ?? "")
        self.errorMessageLabel.text = ""
        if (verificationCodeTextField.text ?? "")?.count == 6 {
            signInButton.isEnabled = true
        } else {
            signInButton.isEnabled = false
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        self.errorMessageLabel.text = "loading..."
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID, verificationCode: verificationCodeTextField.text ?? "")
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
                self.errorMessageLabel.text = "The code you entered was incorrect"
                self.signInButton.isEnabled = false
                self.verificationCodeTextField.text = ""
              // ...
              return
            }
            // User is signed in
            // Register user if new user
            if self.newPlayer {
                self.player.addToDatabase(username: self.playerUsername!, phoneNumber: self.phoneNumber, vc: self, completion: { json in
                    self.playerID = (json["id"] as? Int)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "TabBarController", sender: self)
                    }
                })
            } else {
                self.performSegue(withIdentifier: "TabBarController", sender: self)
            }
        }
    }
    
    @IBAction func sendNewCodeTapped(_ sender: Any) {
        self.errorMessageLabel.text = ""
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.errorMessageLabel.text = "there was an error"
//                    at this point we have already verified the phone number
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
            self.verificationID = verificationID!
        }
    }
    
    @IBAction func useWithoutAccountTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "TabBarController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UITabBarController {
            let vc = segue.destination as? ViewController
            vc?.playerID = self.playerID
            vc?.playerUsername = self.playerUsername
        }
    }
    
}
