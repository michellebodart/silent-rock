//
//  Username.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/27/22.
//

import UIKit

class Username: NSObject {
    func format(with mask: String, username: String) -> String {
        let numbers = username.replacingOccurrences(of: "[^0-9a-zA-Z_.]", with: "", options: .regularExpression)
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
    
    func isAppropriate(username: String) -> Bool {
        guard let fileUrl = Bundle.main.url(forResource: "bannedWords", withExtension: "txt") else { return false }
        guard let content =  try? String(contentsOf: fileUrl, encoding: .utf8)
            else { return false }
        let bannedWords = content.split(separator: "\n")
        for word in bannedWords {
            if (username.lowercased().contains(word)) {
                return false
            }
        }
        return true
    }
}
