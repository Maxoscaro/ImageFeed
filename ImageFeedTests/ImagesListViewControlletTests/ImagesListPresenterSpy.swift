//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Maksim on 25.09.2024.
//

import UIKit
import ImageFeed

final class ImagesListPresenterSpy: ImagesListCellPresenterProtocol {

    var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var reloadDataCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func addImageListObserver() {
        
    }
    
    func appendPhotos(_ newPhotos: [Photo]) {
        self.photos.append(contentsOf: newPhotos)
    }
    
    func getPhotos() -> [Photo] {
        return  []
    }
    
    func updateTableViewAnimated() {
        
    }
    
    func fetchInitialPhotos() {
        imagesListService?.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let newPhotos):
                guard let self = self else { return }
                self.appendPhotos(newPhotos)
                self.reloadDataCalled = true
            case .failure(_):
                print()
            }
        }
    }
    
    func configureImagesListService(_ imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    
}
