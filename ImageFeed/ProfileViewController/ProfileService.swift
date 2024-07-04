//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Maksim on 20.06.2024.
//

import Foundation

final class ProfileService {
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
   
    static let shared = ProfileService()
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let decodeResult = ProfileResult.decodeProfileResponse(from: data)
                    
                    switch decodeResult {
                    case.success(let profileResult):
                        let profile = Profile(result: profileResult)
                        self.profile = profile
                        completion(.success(profile))
                        
                    case .failure(let error):
                        completion(.failure(error))
                        print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                    }
                case .failure(let error):
                    switch error {
                    case NetworkError.httpStatusCode(let statusCode):
                        print("HTTP Error: status-code \(statusCode)")
                    case NetworkError.urlRequestError(let requestError):
                        print("Request error: \(requestError.localizedDescription)")
                    case NetworkError.urlSessionError:
                        print("URLSession Error")
                    default:
                        print("Unknown error: \(error.localizedDescription)")
                    }
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}

private func makeFetchProfileRequest(token: String) -> URLRequest? {
    
    guard let url = URL(string: Constants.profileURLString) else { return nil }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return request
}


