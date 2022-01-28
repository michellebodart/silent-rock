//
//  Player.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/27/22.
//

import UIKit
import Firebase

class Player: NSObject {
    
    func addToDatabase(username: String, phoneNumber: String) {
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
        request.httpMethod = "POST"
        
        struct UploadData: Codable {
            let username: String
            let phone: String
        }
        
        let uploadDataModel = UploadData(username: username, phone: phoneNumber)
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("error trying to convert model to JSON data")
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error calling POST")
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                return
            }
            do {
                let httpResponseCode = response.statusCode
                print(httpResponseCode)
            }
        })
        task.resume()
    }
    
    func verifyFromLogin(phoneNumber: String, vc: loginViewController) {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    vc.errorMessageLabel.text = "The phone number you entered is not valid"
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                vc.verificationID = verificationID!
                vc.performSegue(withIdentifier: "verificationViewController", sender: vc)
            }
    }
    
    func verifyFromRegister(phoneNumber: String, vc: registerViewController) {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    vc.phoneNumberErrorMessage.text = "The phone number you entered is not valid"
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                vc.verificationID = verificationID!
                vc.performSegue(withIdentifier: "verificationViewController", sender: vc)
            }
    }
    
    
}
