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
        
        self.hideKeyboardWhenTappedAround()
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
    
    
    func signIn(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.errorMessageLabel.text = "The phone number you entered is not valid"
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
