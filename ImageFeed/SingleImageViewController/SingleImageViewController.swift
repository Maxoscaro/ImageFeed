//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Maksim on 23.05.2024.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded else { return }
            self.setImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private let alertService = AlertService.shared
    
    @IBOutlet private  weak var imageView: UIImageView!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else {
            assertionFailure("Не удалось поделиться изображением")
            return }
        let share = UIActivityViewController(
            activityItems:[image],
            applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertService.singleImageViewDelegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        setImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setImage() {
        UIBlockingProgressHUD.show()
        guard let imageURL = imageURL else { return }
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(_):
                guard let self = self else { return }
                self.image = self.imageView.image
                guard let image = image else { return }
                imageView.frame.size = image.size
                rescaleAndCenterImageInScrollView(image: image)
                
            case .failure(let error):
                print(error)
                guard let self = self else { return }
                self.alertService.showAlert(title: "Ошибка", message: "Изображение не загружено", buttonRetryTitle: "Повторить", buttonCloseTitle: "Пропустить")
            }
        }
    }
    
    //MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        let x = (scrollViewSize.width - imageViewSize.width) / 2
        let y = (scrollViewSize.height - imageViewSize.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
}

//MARK: - Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
}
