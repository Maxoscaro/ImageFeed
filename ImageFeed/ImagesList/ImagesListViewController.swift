//
//  ViewController.swift
//  ImageFeed
//
//  Created by Maksim on 03.05.2024.
//

import UIKit
import Kingfisher
import ProgressHUD

public protocol ImagesListViewControllerProtocol: UIViewController {
    var presenter: ImagesListCellPresenterProtocol? { get set }
    func reloadData()
    func updateTableViewAnimated(oldPhotosCount: Int, newPhotosCount: Int)
    func configure(_ presenter: ImagesListCellPresenterProtocol)
}

class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListCellPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)"}
    private var imagesListService = ImagesListService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let alertService = AlertService.shared
    internal var photos = [Photo]()
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let presenter = presenter else { return }
        presenter.viewDidLoad()
        presenter.fetchInitialPhotos()
        
        tableView.rowHeight = 200
        tableView.backgroundColor = UIColor(named: "ypBlack")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configure(_ presenter: ImagesListCellPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func reloadData(){
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { assertionFailure("Invalid segue destination")
                return
            }
            guard let presenter = self.presenter else { return }
            let imageURL = URL(string: presenter.getPhotos()[indexPath.row].largeImageURL)
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated(oldPhotosCount: Int, newPhotosCount: Int) {
        
        
        if oldPhotosCount != newPhotosCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldPhotosCount..<newPhotosCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

//MARK: - Extensions

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let presenter = presenter else { return 0 }
        return presenter.getPhotos().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
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
        guard let presenter = self.presenter else { return }
        let imageIndex = presenter.getPhotos()[indexPath.row]
        let imageURLString = imageIndex.thumbImageURL
        let imageURL = URL(string: imageURLString)
        let placeholderImage = UIImage(named: "photo_stub")
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.cancelDownloadTask()
        cell.cellImage.kf.setImage(with: imageURL, placeholder: placeholderImage, options: nil)
        { [weak self] completion in
            switch completion {
            case .success(_):
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                print("ImagesListViewController.configCell: Загрузка фото завершена")
            case .failure(let error):
                print("ImagesListViewController.configCell: Загрузка фото не завершена. Код \(error)")
            }
            ProgressHUD.dismiss()
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
        guard let presenter = presenter else { return CGFloat() }
        let imageIndex = presenter.getPhotos()[indexPath.row]
        let imageInserts = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInserts.left - imageInserts.right
        let imageWidth = imageIndex.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageIndex.size.height * scale + imageInserts.top + imageInserts.bottom
        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt IndexPath: IndexPath) {
        guard let presenter = presenter else { return }
        if IndexPath.row == presenter.getPhotos().count - 1 {
            presenter.fetchInitialPhotos()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let presenter = presenter else { return }
        let photo = presenter.getPhotos()[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success():
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                print("ImagesListViewController: Лайк изменен")
                
            case .failure(let error):
                print("ImagesListViewController: Лайк не изменен - \(error)")
                self.alertService.showAlert(title: "Ошибка", message: "Что-то пошло не так", buttonTitle: "Ок")
            }
        }
        UIBlockingProgressHUD.dismiss()
    }
}
