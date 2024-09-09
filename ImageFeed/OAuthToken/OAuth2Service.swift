//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Maksim on 10.06.2024.
//

import Foundation
import SwiftKeychainWrapper

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func makeOAuthTokenRequest(code: String?) ->URLRequest? {
        guard let code = code else {
            print("Invalid base URL")
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.path = Constants.authPath
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url(relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("Failed to construct URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            task?.cancel()
            completion(.failure(AuthServiceError.invalidRequest))
            print("Authorization code is nil or failed to create URL")
            return
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
            completion(.failure(AuthServiceError.invalidRequest))
        }
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result:
                                                            Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                
                let token = tokenResponse.accessToken
                self.tokenStorage.token = token
                let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
                guard isSuccess else {
                    print("OAuth2Service.fetchOAuthToken: токен не записан в KeyChain")
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(token))
                }
                print("OAuth2Service.fetchOAuthToken: OAuth токен получен: \(token)")
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("OAuth2Service.fetchOAuthToken. HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("OAuth2Service.fetchOAuthToken. Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("OAuth2Service.fetchOAuthToken. URLSession Error")
                default:
                    print("OAuth2Service.fetchOAuthToken. Unknown error: \(error.localizedDescription)")
                }
                print("OAuth2Service.fetchOAuthToken. Ошибка при декодировании токена")
            }
            
            self.task = nil
            self.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
    
  
    
}

