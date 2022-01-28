//
//  loginViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/24/22.
//

import UIKit
import Firebase

class loginViewController: UIViewController {
    let phone: Phone = Phone()
    var verificationID: String = ""
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signInButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.isEnabled = false
        
        self.hideKeyboardWhenTappedAround()
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
    
    
    func signIn(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.errorMessageLabel.text = "The phone number you entered is not valid"
                self.phoneNumberTextField.text = ""
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
            self.verificationID = verificationID!
            self.performSegue(withIdentifier: "verificationViewController", sender: self)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text {
            var userExists = false
            var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    // NEED TO ADD WHAT TO DO IF SERVER IS DOWN
                    let httpResponseCode = (response as? HTTPURLResponse)!.statusCode
                    print(httpResponseCode)
                    let json = try JSONSerialization.jsonObject(with: data!) as! Array<Any>
                    for player in json {
                        let phone = (player as! NSDictionary)["phone"]
                        if phoneNumber == (phone! as! String) {
                            userExists = true
                        }
                    }
                    if userExists {
                        self.signIn(phoneNumber: phoneNumber)
                    }
                    DispatchQueue.main.async {
                        if !userExists {
                            self.errorMessageLabel.text = "The phone number you entered is not registered with an account"
                        }
                    }
                } catch {
                    print("error: ", error)
                }
            })
            task.resume()
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
