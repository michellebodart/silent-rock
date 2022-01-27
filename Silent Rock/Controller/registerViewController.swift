//
//  registerViewController.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/24/22.
//

import UIKit

class registerViewController: UIViewController {
    
    var phoneNumber: String = ""
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberErrorMessage: UILabel!
    @IBOutlet weak var signUpButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.text = phoneNumber
        signUpButton.isEnabled = false
        
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func phoneNumberTextFieldUpdated(_ sender: Any) {
        phoneNumberTextField.text = format(with: "+X (XXX) XXX-XXXX", phone: phoneNumberTextField.text ?? "")
        let phoneNumber = phoneNumberTextField.text ?? ""
        let result = phoneNumber.range(of: "^\\+[0-9]+ \\([0-9]{3}\\) [0-9]{3}-[0-9]{4}", options: .regularExpression)
        let phoneNumberIsValid = (result != nil)
        if !phoneNumberIsValid {
            phoneNumberErrorMessage.text = "Please enter a valid phone number"
        } else {
            phoneNumberErrorMessage.text = ""
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
