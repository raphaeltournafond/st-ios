//
//  AccountManager.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 19/04/2024.
//

import Foundation

struct User {
    let id: Int
    let firstName: String
    let lastName: String
    let username: String
    let email: String
}

struct Session {
    let id: Int
    let start_date: String
    let end_date: String
    let data: String
}

class BackendManager: ObservableObject {
    // Base URL of your Django backend
    let baseURL = "http://192.168.1.60:8000/"
    
    // Access and refresh tokens
    private var accessTokenKey: String = "accessToken"
    private var refreshTokenKey: String = "refreshToken"
    
    @Published var isConnected: Bool? = nil
    @Published var connectedUserID: Int? = nil
    

    // MARK: - ACCOUNT
    
    
    
    // MARK: - register
    func register(firstName: String, lastName: String, email: String, username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters = ["first_name": firstName,"last_name": lastName, "email": email, "username": username, "password": password]
        sendRequest(endpoint: "accounts/register/", method: "POST", parameters: parameters) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - login
    func login(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        disconnect()
        let parameters = ["username": username, "password": password]
        sendRequest(endpoint: "accounts/login/", method: "POST", parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let refreshToken = json["refresh"] as? String, let accessToken = json["access"] as? String {
                        UserDefaults.standard.set(refreshToken, forKey: self.refreshTokenKey)
                        UserDefaults.standard.set(accessToken, forKey: self.accessTokenKey)
                        self.initiateConnexion() { result in
                            completion(result ? .success(true) : .failure(LoginError.invalidResponse))
                        }
                    } else {
                        // Handle missing keys in JSON
                        completion(.failure(LoginError.invalidResponse))
                    }
                } else {
                    // Handle invalid JSON format
                    completion(.failure(LoginError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - user
    func fetchUserDetail(userID: Int, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        let endpoint = "accounts/users/\(userID)/"
        sendRequest(endpoint: endpoint, method: "GET") { result in
            switch result {
            case .success(let data):
                if let userDetail = data as? [[String: Any]] {
                    completion(.success(userDetail))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - verify
    private func tokenVerify(token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters = ["token": token]
        let endpoint = "api/token/verify/"
        sendRequest(endpoint: endpoint, method: "POST", parameters: parameters) { result in
            switch result {
            case .success(_):
                print("Token valid")
                completion(.success(true))
            case .failure(let error):
                print("Token invalid")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - refresh
    private func tokenRefresh(refreshToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters = ["refresh": refreshToken]
        let endpoint = "api/token/refresh/"
        sendRequest(endpoint: endpoint, method: "POST", parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let refreshToken = json["refresh"] as? String, let accessToken = json["access"] as? String {
                        UserDefaults.standard.set(refreshToken, forKey: self.refreshTokenKey)
                        UserDefaults.standard.set(accessToken, forKey: self.accessTokenKey)
                        completion(.success(true))
                    } else {
                        // Handle missing keys in JSON
                        completion(.failure(LoginError.invalidResponse))
                    }
                } else {
                    // Handle invalid JSON format
                    completion(.failure(LoginError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func initiateConnexion(completion: @escaping (Bool) -> Void) {
        if let access = UserDefaults.standard.string(forKey: accessTokenKey), let refresh = UserDefaults.standard.string(forKey: refreshTokenKey) {
            tokenVerify(token: access) { [self] verifyResult in
                switch verifyResult {
                case .success(let accessIsValid):
                    if accessIsValid {
                        self.tokenDecode()
                        DispatchQueue.main.async {
                            self.isConnected = true
                        }
                        completion(true)
                    } else {
                        tokenRefresh(refreshToken: refresh) { refreshResult in
                            switch refreshResult {
                            case .success(let refreshed):
                                if refreshed {
                                    self.tokenDecode()
                                    DispatchQueue.main.async {
                                        self.isConnected = true
                                    }
                                    completion(true)
                                } else {
                                    self.isConnected = false
                                    completion(false)
                                }
                            case .failure(_):
                                self.isConnected = false
                                completion(false)
                            }
                        }
                    }
                case .failure(_):
                    self.isConnected = false
                    completion(false)
                }
            }
        } else {
            self.isConnected = false
            completion(false)
        }
    }
    
    // MARK: - decode
    func tokenDecode() -> Void {
        let endpoint = "accounts/users/decode/"
        sendRequest(endpoint: endpoint, method: "GET", token: true) { result in
            switch result {
            case .success(let tokenPayload):
                print(tokenPayload)
                if let json = tokenPayload as? [String: Any] {
                    if let user_id = json["user_id"] as? Int {
                        DispatchQueue.main.async {
                            self.connectedUserID = user_id
                            print(self.connectedUserID ?? "Couldn't find user_id")
                        }
                    }
                }
            case .failure(_):
                print("Error, session is not saved")
            }
        }
    }
    
    func disconnect() {
        isConnected = false
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
    
    // MARK: - SESSIONS
    func addSession(data: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "st/sessions/"
        let parameters = ["start_date": "Date()", "end_date": "Date()", "data": data, "user_id": "1"]
        sendRequest(endpoint: endpoint, method: "POST", parameters: parameters, token: true) { result in
            switch result {
            case .success(_):
                print("Session added")
                completion(.success(true))
            case .failure(let error):
                print("Error, session is not saved")
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - REQUEST
    private func sendRequest(endpoint: String, method: String, parameters: [String: Any]? = nil, token: Bool = false, completion: @escaping (Result<Any, Error>) -> Void) {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add access token if available
        if token, let access = UserDefaults.standard.string(forKey: accessTokenKey) {
            request.setValue("Bearer \(access)", forHTTPHeaderField: "Authorization")
        }
        
        // Add parameters for POST requests
        if method == "POST", let parameters = parameters {
            var urlComponents = URLComponents()
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            
            if let query = urlComponents.percentEncodedQuery {
                request.httpBody = Data(query.utf8)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "ServerError", code: 0, userInfo: nil)))
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(.success(json))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

enum LoginError: Error {
    case invalidResponse
}


