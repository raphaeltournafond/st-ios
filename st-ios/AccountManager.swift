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

class AccountManager: ObservableObject {
    // Base URL of your Django backend
    let baseURL = "http://192.168.1.60:8000/"
    
    // Access and refresh tokens
    private var accessToken: String?
    private var refreshToken: String?

    // MARK: - Registration
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

    // MARK: - Login
    func login(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters = ["username": username, "password": password]
        sendRequest(endpoint: "accounts/login/", method: "POST", parameters: parameters) { result in
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
        sendRequest(endpoint: "accounts/users/", method: "GET") { result in
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
        let endpoint = "accounts/users/\(userID)/"
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
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add access token if available
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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


