//
//  Player.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/27/22.
//

import UIKit
import Firebase

class Player: NSObject {
    
    func addToDatabase(username: String, phoneNumber: String, vc: verificationViewController, completion: @escaping (_ json: Dictionary<String, Any>) -> Void) {
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
        request.httpMethod = "POST"
        
        struct UploadData: Codable {
            let username: String
            let phone: String
        }
        
        let uploadDataModel = UploadData(username: username, phone: phoneNumber)
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            vc.errorMessageLabel.text = "oops, something went wrong"
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                completion(json)
                let httpResponseCode = response.statusCode
                print(httpResponseCode)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func verifyFromLogin(phoneNumber: String, vc: loginViewController) {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    vc.errorMessageLabel.text = "The phone number you entered is not valid"
                    vc.phoneNumberTextField.text = ""
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
                    vc.phoneNumberTextField.text = ""
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                vc.verificationID = verificationID!
                vc.performSegue(withIdentifier: "verificationViewController", sender: vc)
            }
    }
    
    func checkPlayerDataFromLogin (phoneNumber: String, vc: loginViewController, completion: @escaping (_ phoneNumber: String, _ json: Array<Any>) -> Void) {
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Array<Any>
                completion(phoneNumber, json)
            } catch {
                print("error: ", error)
            }
        })
        task.resume()
    }
    
    func checkPlayerDataFromRegister (phoneNumber: String, username: String, vc: registerViewController, completion: @escaping (_ phoneNumber: String, _ username: String, _ json: Array<Any>) -> Void){
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/?API_KEY=123456")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.usernameErrorMessage.text = "Oops, something went wrong"
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.usernameErrorMessage.text = "Oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.usernameErrorMessage.text = "Oops, something went wrong"
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Array<Any>
                completion(phoneNumber, username, json)
            } catch {
                print("error: ", error)
            }
        })
        task.resume()
    }
    
    func getPhoneUsername (playerID: Int, vc: profileViewController, completion: @escaping (_ json: Dictionary<String, Any>) -> Void){
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/\(playerID)/?API_KEY=123456")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Failed to load account information"
                    vc.editUsernameButton.isHidden = true
                    vc.usernameTextField.isHidden = true
                    vc.usernameLabel.isHidden = true
                    vc.phoneNumberLabel.isHidden = true
                    vc.checkboxImage.isHidden = true
                    vc.checkboxLabel.isHidden = true
                    vc.deleteAccountButton.isHidden = true
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                completion(json)
            } catch {
                print("error: ", error)
            }
        })
        task.resume()
    }
    
    func deletePlayer (playerID: Int, vc: profileViewController, completion: @escaping () -> Void){
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/\(playerID)/?API_KEY=123456")!)
        request.httpMethod = "DELETE"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                }
                return
            }
            completion()
        })
        task.resume()
    }
    
    func updateUsername(playerID: Int, username: String, vc: profileViewController, completion: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/\(playerID)/?API_KEY=123456")!)
        request.httpMethod = "PATCH"
        
        struct UploadData: Codable {
                let username: String
        }
        
        let uploadDataModel = UploadData(username: username)
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            DispatchQueue.main.async {
                vc.errorMessageLabel.text = "oops, something went wrong"
            }
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    if (response as? HTTPURLResponse)?.statusCode == 400 {
                        vc.errorMessageLabel.text = "Sorry, that username is taken"
                        vc.usernameTextField.text = ""
                    } else {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                    }
                }
                return
            }
            completion()
        })
        task.resume()
    }
    
    func updateShowOnLeaderboard(playerID: Int, visibleOnLeaderboard: Bool, vc: profileViewController, completion: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "http://localhost:5000/players/\(playerID)/?API_KEY=123456")!)
        request.httpMethod = "PATCH"
        
        struct UploadData: Codable {
                let visible_on_leaderboard: Bool
        }
        
        let uploadDataModel = UploadData(visible_on_leaderboard: !visibleOnLeaderboard)
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            DispatchQueue.main.async {
                vc.errorMessageLabel.text = "oops, something went wrong"
            }
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                }
                return
            }
            vc.visibleOnLeaderboard = !visibleOnLeaderboard
            completion()
        })
        task.resume()
    }
    
}
