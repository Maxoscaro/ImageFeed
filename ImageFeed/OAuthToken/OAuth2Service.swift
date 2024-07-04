//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Maksim on 10.06.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
            completion(.failure(AuthServiceError.invalidRequest))
            print("Authorization code is nil or failed to create URL")
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code)
        else { DispatchQueue.main.async {
            completion(.failure(AuthServiceError.invalidRequest))
        }
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    completion(.failure(error))
                    print("Failed to decode OAuthTokenResponseBody")
                }
            case .failure(let error):
                completion(.failure(error))
                print("Failed to fetch OAuthToken")
            }
            
            self.task = nil
            self.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
}

