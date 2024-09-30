//
//  ImagesListMockService.swift
//  ImageFeedTests
//
//  Created by Maksim on 25.09.2024.
//
import ImageFeed
import Foundation

class ImagesListMockService: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var shouldReturnError = false
    
    func fetchPhotosNextPage(completion: @escaping (Result<[ImageFeed.Photo], Error>) -> Void) {
        if shouldReturnError {
               let error = NSError()
               completion(.failure(error))
           } else {
               completion(.success(photos))
           }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldReturnError {
                let error = NSError()
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    

