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
    @IBOutlet weak var signInButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.isEnabled = false
        //do initial setup

    }
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")
        let phoneNumber = phoneNumberTextField.text ?? ""
        let result = phoneNumber.range(of: "^\\+[0-9]+ \\([0-9]{3}\\) [0-9]{3}-[0-9]{4}", options: .regularExpression)
        let phoneNumberIsValid = (result != nil)
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
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    self.errorMessageLabel.text = "The phone number you entered is not registered with an account"
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                self.verificationID = verificationID!
                self.performSegue(withIdentifier: "verificationViewController", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vvc = segue.destination as? verificationViewController
            vvc?.phoneNumber = phoneNumberTextField.text ?? ""
            vvc?.verificationID = self.verificationID
        } else if segue.destination is registerViewController {
            let rvc = segue.destination as? registerViewController
            rvc?.phoneNumber = phoneNumberTextField.text ?? ""
        }
    }
    
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
}

