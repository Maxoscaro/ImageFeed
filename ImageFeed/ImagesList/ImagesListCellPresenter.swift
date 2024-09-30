//
//  ImagesListCellPresenter.swift
//  ImageFeed
//
//  Created by Maksim on 24.09.2024.
//

import Foundation

public protocol ImagesListCellPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func addImageListObserver()
    func appendPhotos(_ newPhotos: [Photo])
    func getPhotos() -> [Photo]
    func updateTableViewAnimated()
    func fetchInitialPhotos()
    func configureImagesListService (_ imagesListService: ImagesListServiceProtocol)
    
}

final class ImagesListCellPresenter: ImagesListCellPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol?
    var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    
    
    func viewDidLoad() {
        configureImagesListService(ImagesListService.shared)
        addImageListObserver()
    }
    
    func configureImagesListService (_ imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    func addImageListObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                print("Received didChangeNotification")
                self?.updateTableViewAnimated()
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func appendPhotos(_ newPhotos: [Photo]) {
        photos.append(contentsOf: newPhotos)
    }
    
    func getPhotos() -> [Photo] {
        return self.photos
    }
    
    func updateTableViewAnimated() {
        
        guard let photos = self.imagesListService?.photos else { return }
        let oldCount = self.photos.count
        let newCount = photos.count
        self.photos = photos
        view?.updateTableViewAnimated(oldPhotosCount: oldCount, newPhotosCount: newCount)
    }
    
    func fetchInitialPhotos() {
        imagesListService?.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let newPhotos):
                self?.appendPhotos(newPhotos)
                self?.view?.reloadData()
            case .failure(let error):
                print("Ошибка загрузки фото: \(error)")
            }
        }
    }
}
