//
//  verificationViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/25/22.
//

import UIKit
import Firebase

class verificationViewController: UIViewController {

    @IBOutlet weak var verificationCodeTextField: UITextField!
    var phoneNumber: String = ""
    var verificationID: String = ""
    var username: String = ""
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func signInTapped(_ sender: Any) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID, verificationCode: verificationCodeTextField.text ?? "")
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
                self.errorMessageLabel.text = "The code you entered was incorrect"
              // ...
              return
            }
            // User is signed in
            // ...
            self.performSegue(withIdentifier: "mainViewController", sender: self)
        }
    }
    
    @IBAction func sendNewCodeTapped(_ sender: Any) {
        print("in send new code!")
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    self.errorMessageLabel.text = "there was an error"
//                    at this point we have already verified the phone number
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                print(verificationID)
                self.verificationID = verificationID!
            }
    }
}
