//
//  registerViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/24/22.
//

import UIKit
import Firebase

class registerViewController: UIViewController {
    
    var phone: Phone = Phone()
    var username: Username = Username()
    var player: Player = Player()
    var phoneNumber: String = ""
    var verificationID:String = ""
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberErrorMessage: UILabel!
    @IBOutlet weak var usernameErrorMessage: UILabel!
    @IBOutlet weak var signUpButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.text = phoneNumber
        signUpButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = phone.format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")
        
        var phoneNumberIsValid = phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? ""
        )
        if !phoneNumberIsValid {
            phoneNumberErrorMessage.text = "Please enter a valid phone number"
        } else {
            phoneNumberErrorMessage.text = ""
        }
        if (phoneNumberIsValid && usernameTextField.text != "") {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
    
    @IBAction func usernameTextFieldUpdated(_ sender: Any) {
        usernameTextField.text = username.format(with: "XXXXXXXXXXXXXXXXXXXX", phone: usernameTextField.text ?? "")
        usernameErrorMessage.text = ""
        if ((phone.isPhoneValid(phoneNumber: phoneNumberTextField.text ?? "")) && usernameTextField.text != "") {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
            
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        if let phoneNumber = phoneNumberTextField.text, let username = usernameTextField.text {
            var phoneUsed = false
            var usernameUsed = false
            var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                guard error == nil else {
                    print("error")
                    DispatchQueue.main.async {
                        self.usernameErrorMessage.text = "Oops, something went wrong"
                    }
                    return
                }
                guard let data = data else {
                    print("error, did not receive data")
                    DispatchQueue.main.async {
                        self.usernameErrorMessage.text = "Oops, something went wrong"
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("error, HTTP request failed")
                    DispatchQueue.main.async {
                        self.usernameErrorMessage.text = "Oops, something went wrong"
                    }
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Array<Any>
                    for player in json {
                        let phone = (player as! NSDictionary)["phone"]
                        let playerUsername = (player as! NSDictionary)["username"]
                        if phoneNumber == (phone! as! String) {
                            phoneUsed = true
                        }
                        if username == (playerUsername! as! String) {
                            usernameUsed = true
                        }
                    }
                    if !phoneUsed && !usernameUsed {
//                        self.signUp(phoneNumber: phoneNumber, username: username)
                        self.player.verifyFromRegister(phoneNumber: phoneNumber, vc: self)
                    }
                    DispatchQueue.main.async {
                        if phoneUsed {
                            self.phoneNumberErrorMessage.text = "The phone number you entered is already registered with an account"
                            self.phoneNumberTextField.text = ""
                        } else {
                            self.phoneNumberErrorMessage.text = ""
                        }
                        if usernameUsed {
                            self.usernameErrorMessage.text = "Sorry, that username is taken"
                            self.usernameTextField.text = ""
                        } else {
                            self.usernameErrorMessage.text = ""
                        }
                    }
                } catch {
                    print("error: ", error)
                }
            })
            task.resume()
        }
    }
    
    func signUp(phoneNumber: String, username: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.phoneNumberErrorMessage.text = "The phone number you entered is not valid"
                self.phoneNumberTextField.text = ""
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
            self.verificationID = verificationID!
            self.performSegue(withIdentifier: "verificationViewController", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is verificationViewController {
            let vvc = segue.destination as? verificationViewController
            vvc?.phoneNumber = phoneNumberTextField.text ?? ""
            vvc?.verificationID = self.verificationID
            vvc?.username = usernameTextField.text ?? ""
        }
    }

}
