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
    private let tokenStorage = OAuth2TokenStorage.shared
    private (set) var photos: [Photo] = []
    
    private var isFetching = false
       private var currentPage = 0
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        
        isFetching = true
        currentPage += 1
    }
}
