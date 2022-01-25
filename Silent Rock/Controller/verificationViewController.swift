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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func signInTapped(_ sender: Any) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID, verificationCode: verificationCodeTextField.text ?? "")
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
              print("not signed in")
              // ...
              return
            }
            // User is signed in
            // ...
            print("signed in!")
        }
    }
    
    @IBAction func sendNewCodeTapped(_ sender: Any) {
        print("in send new code!")
    }
}
