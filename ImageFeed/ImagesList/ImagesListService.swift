//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Maksim on 08.07.2024.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private (set) var photos: [Photo] = []
    
    private var isFetching = false
    private var currentPage = 0
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        
        isFetching = true
        currentPage += 1
        
        guard let request = makeFetchPhotosRequest(nextPage: currentPage) else {
            isFetching = false
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                
                
                self?.isFetching = false
                
                switch result {
                case .success(let photoResult):
                    self?.handleSuccess(photoResult: photoResult)
                case.failure:
                    self?.currentPage -= 1
                }
            }
                
            }
            
            task.resume()
        }
    
    private func makeFetchPhotosRequest(nextPage: Int) -> URLRequest? {
            guard let url = URL(string: Constants.defaultPhotos + "?page=\(nextPage)"),
                  let token = tokenStorage.token else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    
    private func handleSuccess(photoResult: [PhotoResult]) {
        let newPhotos = photoResult.map { Photo(from: $0) }
        photos.append(contentsOf: newPhotos)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
