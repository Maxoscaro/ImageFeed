//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Maksim on 25.06.2024.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    
    private let oauth2Service = OAuth2Service.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private (set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileAvatarRequest(username) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("Invalid request")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {
            (result:
                Result<ProfileImageResponseBody, Error>) in
            switch result {
                
            case .success(let profileImages):
                self.avatarURL = profileImages.profileImage.large
                guard let avatarURL = self.avatarURL else { return }
                DispatchQueue.main.async {
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                }
                print("ProfileImageService.fetchProfileImageURL:Profile received")
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    
                    print("Error during profile decoding")
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("ProfileImageService.fetchProfileImageURL.HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("ProfileImageService.fetchProfileImageURL.Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("ProfileImageService.fetchProfileImageURL.URLSession Error")
                default:
                    print("ProfileImageService.fetchProfileImageURL.Unknown error: \(error.localizedDescription)")
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileAvatarRequest(_ username: String) -> URLRequest? {
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("Invalid base URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = oauth2Service.getToken()
        else {
            print("No token")
            return nil}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

