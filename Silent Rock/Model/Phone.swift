//
//  Phone.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/27/22.
//

import UIKit

class Phone: NSObject {
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
    
    func isPhoneValid(phoneNumber: String) -> Bool {
        let result = phoneNumber.range(of: "^\\+[0-9]+ \\([0-9]{3}\\) [0-9]{3}-[0-9]{4}", options: .regularExpression)
        let phoneNumberIsValid = (result != nil)
        return phoneNumberIsValid
    }
    
}
