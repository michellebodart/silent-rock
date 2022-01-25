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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //do initial setup

    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                  print(error)
                  print("erroooooooor")
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

