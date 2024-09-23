//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Maksim on 20.06.2024.
//

import Foundation

public protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

final class ProfileService: ProfileServiceProtocol {
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let oauth2Service = OAuth2TokenStorage.shared
    
    static let shared = ProfileService()
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
                
            case.success(let profileResult):
                
                self.profile = profileResult.toProfile()
                guard let profile = self.profile else { return }
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
                print("ProfileService.fetchProfile: профиль успешно загружен")
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("Ошибка сетевого запроса в функции \(#function): \(error.localizedDescription)")
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("ProfileService.fetchProfile.HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("ProfileService.fetchProfile.Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("ProfileService.fetchProfile.URLSession Error")
                default:
                    print("ProfileService.fetchProfile.Unknown error: \(error.localizedDescription)")
                }
            }
            
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func cleanProfile() {
        self.profile = Profile(username: "", name: "", loginName: "", bio: "")
    }
    
    private func makeFetchProfileRequest(token: String) -> URLRequest? {
        
        guard let url = URL(string: Constants.profileURLString) else {
            print("Invalid base URL")
            return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = oauth2Service.token
        else {
            print("No token")
            return nil}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

