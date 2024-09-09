//
//  ViewController.swift
//  ImageFeed
//
//  Created by Maksim on 03.05.2024.
//

import UIKit
import Kingfisher
import ProgressHUD

class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)"}
    private let imagesListService = ImagesListService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let alertService = AlertService.shared
    private var photos = [Photo]()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageListObserver()
        imagesListService.fetchPhotosNextPage()
        
        tableView.rowHeight = 200
        tableView.backgroundColor = UIColor(named: "ypBlack")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { assertionFailure("Invalid segue destination")
                return
            }
            let imageURL = URL(string: photos[indexPath.row].largeImageURL)
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func addImageListObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateTableViewAnimated() {
        
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let imageIndex = photos[indexPath.row]
        let imageURLString = imageIndex.thumbImageURL
        let imageURL = URL(string: imageURLString)
        let placeholderImage = UIImage(named: "photo_stub")
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.cancelDownloadTask()
        cell.cellImage.kf.setImage(with: imageURL, placeholder: placeholderImage, options: nil)
        { completion in
            switch completion {
            case .success(_):
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                ProgressHUD.dismiss()
                print("ImagesListViewController.configCell: Загрузка фото завершена")
            case .failure(let error):
                ProgressHUD.dismiss()
                print("ImagesListViewController.configCell: Загрузка фото не завершена. Код \(error)")
            }
        }
        
        let isLiked = imageIndex.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.likeButton.setTitle("", for: .normal)
        
        guard let imageDate = imageIndex.createdAt else {
            cell.dateLabel.text = dateFormatter.string(from: Date())
            return
        }
        cell.dateLabel.text = dateFormatter.string(from: imageDate)
    }
    
    private func createPlaceholderImage(forCellWith frame: CGRect) -> UIImage {
        let placeholderView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        placeholderView.backgroundColor = .white.withAlphaComponent(0.3)
        
        guard let imageStub = UIImage(named: "photo_stub") else { return UIImage() }
        let imageStubView = UIImageView(image: imageStub)
        imageStubView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(imageStubView)
        
        NSLayoutConstraint.activate([
            imageStubView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageStubView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            imageStubView.heightAnchor.constraint(equalToConstant: 75),
            imageStubView.widthAnchor.constraint(equalToConstant: 83)
        ])
        
        placeholderView.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(placeholderView.bounds.size, false, 0.0)
        placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return placeholderImage ?? UIImage()
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let imageIndex = photos[indexPath.row]
        let imageInserts = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInserts.left - imageInserts.right
        let imageWidth = imageIndex.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageIndex.size.height * scale + imageInserts.top + imageInserts.bottom
        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt IndexPath: IndexPath) {
        if IndexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success():
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                print("ImagesListViewController: Лайк изменен")
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                print("ImagesListViewController: Лайк не изменен - \(error)")
                UIBlockingProgressHUD.dismiss()
                self.alertService.showAlert(title: "Ошибка", message: "Что-то пошло не так", buttonTitle: "Ок")
            }
        }
    }
}
