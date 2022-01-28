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
    let player: Player = Player()
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

    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text {
            var userExists = false
            var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                guard error == nil else {
                    print("error")
                    DispatchQueue.main.async {
                        self.errorMessageLabel.text = "Oops, something went wrong"
                    }
                    return
                }
                guard let data = data else {
                    print("error, did not receive data")
                    DispatchQueue.main.async {
                        self.errorMessageLabel.text = "Oops, something went wrong"
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("error, HTTP request failed")
                    DispatchQueue.main.async {
                        self.errorMessageLabel.text = "Oops, something went wrong"
                    }
                    return
                }
                do {
                    let httpResponseCode = response.statusCode
                    print(httpResponseCode)
                    let json = try JSONSerialization.jsonObject(with: data) as! Array<Any>
                    for player in json {
                        let phone = (player as! NSDictionary)["phone"]
                        if phoneNumber == (phone! as! String) {
                            userExists = true
                        }
                    }
                    if userExists {
                        self.player.verifyFromLogin(phoneNumber: phoneNumber, vc: self)
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
