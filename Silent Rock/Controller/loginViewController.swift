//
//  loginViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/24/22.
//

import UIKit
import Firebase

class loginViewController: UIViewController {
    var verificationID = ""
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //do initial setup

    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    self.errorMessageLabel.text = "there was an error"
//                    Need to check if the phone number is valid, then check if it is in the database, then return an appropriate error message 
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                print(verificationID)
                self.verificationID = verificationID!
                self.performSegue(withIdentifier: "verificationViewController", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vc = segue.destination as? verificationViewController
            vc?.phoneNumber = phoneNumberTextField.text ?? "1234567890"
            vc?.verificationID = self.verificationID
        }
    }
}

