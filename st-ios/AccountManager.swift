//
//  AccountManager.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 19/04/2024.
//

import Foundation

class AccountManager {
    // Base URL of your Django backend
    let baseURL = "https://your-django-backend-url.com/api/"
    
    // Access and refresh tokens
    private var accessToken: String?
    private var refreshToken: String?
    
    // State variables
    private var isConnected = false
    private var currentConnectedUser: User?

    // MARK: - Registration
    func register(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters = ["username": username, "password": password]
        sendRequest(endpoint: "register", method: "POST", parameters: parameters) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Login
    func login(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters = ["username": username, "password": password]
        sendRequest(endpoint: "login", method: "POST", parameters: parameters) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch User List
    func fetchUserList(completion: @escaping (Result<[String], Error>) -> Void) {
        sendRequest(endpoint: "users", method: "GET") { result in
            switch result {
            case .success(let data):
                if let userList = data as? [String] {
                    completion(.success(userList))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch User Detail
    func fetchUserDetail(userID: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "users/\(userID)"
        sendRequest(endpoint: endpoint, method: "GET") { result in
            switch result {
            case .success(let data):
                if let userDetail = data as? [String: Any] {
                    completion(.success(userDetail))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Send Request
    private func sendRequest(endpoint: String, method: String, parameters: [String: Any]? = nil, completion: @escaping (Result<Any, Error>) -> Void) {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add access token if available
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add parameters for POST requests
        if method == "POST", let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
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

