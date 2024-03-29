//
//  Player.swift
//  Silent Rock
//
//  Created by Michelle Bodart on 1/27/22.
//

import UIKit
import Firebase

class Player: NSObject {
    var API_KEY: String
    let DB_URL: String
    
    override init() {
        self.API_KEY = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? "error_causing_key"
        let db_url = Bundle.main.object(forInfoDictionaryKey: "DB_URL") as? String ?? "bad_url"
        self.DB_URL = "https://" + db_url
        super.init()
    }
    
    func addToDatabase(username: String, phoneNumber: String, vc: verificationViewController, completion: @escaping (_ json: Dictionary<String, Any>) -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/?API_KEY=\(API_KEY)")!)
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
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "The phone number you entered is not valid"
                    vc.phoneNumberTextField.text = ""
                    vc.phoneNumberTextField.isEnabled = true
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
                    vc.spinner.isHidden = true
                    vc.phoneNumberErrorMessage.text = "The phone number you entered is not valid"
                    vc.usernameErrorMessage.text = ""
                    vc.phoneNumberTextField.text = ""
                    vc.phoneNumberTextField.isEnabled = true
                    vc.usernameTextField.isEnabled = true
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                vc.verificationID = verificationID!
                vc.performSegue(withIdentifier: "verificationViewController", sender: vc)
            }
    }
    
    // for a user updating their phone number
    func verifyFromProfile(phoneNumber: String, vc: profileViewController) {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "The phone number you entered is not valid"
                    vc.phoneNumberTextField.text = ""
                    vc.submitButton.isEnabled = true
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationId")
                vc.verificationID = verificationID!
                vc.phoneNumber = phoneNumber
                vc.performSegue(withIdentifier: "profileVerificationView", sender: vc)
            }
    }
    
    func checkPlayerDataFromLogin (phoneNumber: String, vc: loginViewController, completion: @escaping (_ phoneNumber: String, _ json: Array<Any>) -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.phoneNumberTextField.isEnabled = true
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.phoneNumberTextField.isEnabled = true
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.phoneNumberTextField.isEnabled = true
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
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.usernameErrorMessage.text = "Oops, something went wrong"
                    vc.phoneNumberTextField.isEnabled = true
                    vc.usernameTextField.isEnabled = true
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.usernameErrorMessage.text = "Oops, something went wrong"
                    vc.phoneNumberTextField.isEnabled = true
                    vc.usernameTextField.isEnabled = true
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.usernameErrorMessage.text = "Oops, something went wrong"
                    vc.phoneNumberTextField.isEnabled = true
                    vc.usernameTextField.isEnabled = true
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
    
    // Checks if a player's phone is taken
    func checkPlayerDataFromProfile (phoneNumber: String, vc: profileViewController, completion: @escaping (_ phoneNumber: String,_  json: Array<Any>) -> Void){
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.submitButton.isEnabled = true
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.submitButton.isEnabled = true
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "oops, something went wrong"
                    vc.submitButton.isEnabled = true
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
    
    // Get data to display for profile view
    func getPhoneUsername (playerID: Int, vc: profileViewController, completion: @escaping (_ json: Dictionary<String, Any>) -> Void){
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/\(playerID)/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Failed to load account information"
                    vc.refreshButton.isHidden = false
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.refreshButton.isHidden = false
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.refreshButton.isHidden = false
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
    
    // For deleting a player from profile view controller
    func deletePlayer (playerID: Int, vc: profileViewController, completion: @escaping () -> Void){
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/\(playerID)/?API_KEY=\(API_KEY)")!)
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
    
    // Check if username is taken before updating it
    func updateUsername(playerID: Int, username: String, vc: profileViewController, completion: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/\(playerID)/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "PATCH"
        
        struct UploadData: Codable {
                let username: String
        }
        
        let uploadDataModel = UploadData(username: username)
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            DispatchQueue.main.async {
                vc.spinner.isHidden = true
                vc.errorMessageLabel.text = "oops, something went wrong"
                vc.submitPhoneButton.isEnabled = true
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
                    vc.submitPhoneButton.isEnabled = true
                    vc.spinner.isHidden = true
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                    vc.submitPhoneButton.isEnabled = true
                    vc.spinner.isHidden = true
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    if (response as? HTTPURLResponse)?.statusCode == 400 {
                        vc.errorMessageLabel.text = "Sorry, that username is taken"
                        vc.usernameTextField.text = ""
                    } else {
                    vc.errorMessageLabel.text = "oops, something went wrong"
                    }
                    vc.submitPhoneButton.isEnabled = true
                }
                return
            }
            completion()
        })
        task.resume()
    }
    
    // update player settings to show or hide from leaderboard
    func updateShowOnLeaderboard(playerID: Int, visibleOnLeaderboard: Bool, vc: profileViewController, completion: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/\(playerID)/?API_KEY=\(API_KEY)")!)
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
    
    // Update phone number in DB
    func updatePhone(playerID: Int, phone: String, vc: ProfileVerificationViewController, completion: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/\(playerID)/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "PATCH"
        
        struct UploadData: Codable {
                let phone: String
        }
        
        let uploadDataModel = UploadData(phone: phone)
        
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
            completion()
        })
        task.resume()
    }
    
    // Get trips data for leaderboard
    func getPlayerDataForLeaderboard (vc: leaderboardViewController, sortBasis: String, filterBy: String, completion: @escaping (_ json: Array<Any>) -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/?API_KEY=\(API_KEY)&sort_basis=\(sortBasis)&filter_criteria=\(filterBy)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Failed to load leaderboard information"
                    vc.spinner.isHidden = true
                    vc.refreshButton.isHidden = false
                    vc.tableIsHidden(bool: true)
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Failed to load leaderboard information"
                    vc.refreshButton.isHidden = false
                    vc.tableIsHidden(bool: true)
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Failed to load leaderboard information"
                    vc.refreshButton.isHidden = false
                    vc.tableIsHidden(bool: true)
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Array<Any>
                completion(json)
            } catch {
                print("error: ", error)
            }
        })
        task.resume()
    }
    
    // Get trips of a specific user to show on the leaderboard detail view
    func getTrips (playerID: Int, vc: leaderboardDetailViewController, completion: @escaping (_ json: Dictionary<String, Any>) -> Void){
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/\(playerID)/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Failed to load trips"
                    vc.refreshButton.isHidden = false
                    vc.table.isHidden = true
                    vc.filterByStackView.isHidden = true
                    vc.totalTripsStackView.isHidden = true
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.refreshButton.isHidden = false
                    vc.table.isHidden = true
                    vc.filterByStackView.isHidden = true
                    vc.totalTripsStackView.isHidden = true
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.spinner.isHidden = true
                    vc.errorMessageLabel.text = "Oops, something went wrong"
                    vc.refreshButton.isHidden = false
                    vc.table.isHidden = true
                    vc.filterByStackView.isHidden = true
                    vc.totalTripsStackView.isHidden = true
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
 
    // for posting trips
    func addTrip(vc: ViewController, completion: @escaping (_ tripID: Int) -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/trips/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to database"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to database"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to database"
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                let tripID = json["trip_id"] as! Int
                print("in add trip", "trip id:", tripID)
                completion(tripID)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    // add trips to a user via players_trips
    func addTripToUsers(vc: ViewController, tripID: Int, playerIDs: Array<Int?>, completion: @escaping (_ tripID: Int) -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players_trips/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "POST"
        
        struct UploadData: Codable {
            let trip_id: Int
            let player_ids: Array<Int?>
        }
        
        let uploadDataModel = UploadData(trip_id: tripID, player_ids: playerIDs)
        
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            vc.errorMessageLabel.text = "Could not add trip to user(s)"
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to user(s)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to user(s)"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to user(s)"
                }
                return
            }
            completion(tripID)
        })
        task.resume()
    }
    
    // add pending trip to users
    func addPendingTripToUsers(vc: ViewController, tripID: Int, playerIDs: Array<Int?>, tripOwnerUsername: String) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/pending_players_trips/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "POST"
        
        struct UploadData: Codable {
            let trip_id: Int
            let player_ids: Array<Int?>
            let trip_owner_username: String
        }

        let uploadDataModel = UploadData(trip_id: tripID, player_ids: playerIDs, trip_owner_username: tripOwnerUsername)

        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            vc.errorMessageLabel.text = "Could not add trip to user(s)"
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to user(s)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to user(s)"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not add trip to user(s)"
                }
                return
            }
        })
        task.resume()
    }
    
    // accept or reject pending trip
    func acceptRejectPendingTrip(vc: profileViewController, tripID: Int, playerIDs: Array<Int?>, accept: Bool) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/pending_players_trips/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "DELETE"

        struct UploadData: Codable {
            let trip_id: Int
            let player_ids: Array<Int?>
            let accept: Bool
        }

        let uploadDataModel = UploadData(trip_id: tripID, player_ids: playerIDs, accept: accept)

        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            vc.errorMessageLabel.text = "Could not accept or reject trip"
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not accept or reject trip"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not accept or reject trip"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Could not accept or reject trip"
                }
                return
            }
        })
        task.resume()
    }
    
    // getting player names to add to trip
    func getAllPlayers (vc: ViewController, completion: @escaping (_ json: Array<Dictionary<String, Any>>) -> Void) {
        var request = URLRequest(url: URL(string: "\(DB_URL)/players/?API_KEY=\(API_KEY)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                print("error")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Failed to load other users"
                }
                return
            }
            guard let data = data else {
                print("error, did not receive data")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Failed to load other users"
                }
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("error, HTTP request failed")
                DispatchQueue.main.async {
                    vc.errorMessageLabel.text = "Failed to load other users"
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Array<Dictionary<String, Any>>
                completion(json)
            } catch {
                print("error: ", error)
            }
        })
        task.resume()
    }
}
