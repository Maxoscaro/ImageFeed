//
//  AlertService.swift
//  ImageFeed
//
//  Created by Maksim on 19.07.2024.
//

import UIKit


final class AlertService {
    
    static let shared = AlertService()
    private init() {}
    
    weak var delegate: UIViewController?
    weak var singleImageViewDelegate: SingleImageViewController?
    weak var profileViewControllerDelegate: ProfilePresenterProtocol?
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("AlertService.showAlert: \(buttonTitle) button tapped")
        }
        alertController.addAction(okAction)
        delegate?.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, buttonRetryTitle: String, buttonCloseTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: buttonRetryTitle, style: .default) { [weak self] _ in
            alertController.dismiss(animated: true, completion: nil)
            guard let self = self else { return }
            self.singleImageViewDelegate?.setImage()
            print("AlertService.showAlert: \(buttonRetryTitle) button tapped")
        }
        
        let closeAction = UIAlertAction(title: buttonCloseTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("AlertService.showAlert: \(buttonCloseTitle) button tapped")
        }
        
        alertController.addAction(retryAction)
        alertController.addAction(closeAction)
        
        singleImageViewDelegate?.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, buttonConfirmTitle: String, buttonDeclineTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: buttonConfirmTitle, style: .default) { [weak self] _ in
            alertController.dismiss(animated: true, completion: nil)
            guard let self = self else { return }
            self.profileViewControllerDelegate?.logout()
            print("AlertService.showAlert: \(buttonConfirmTitle) button tapped")
        }
        
        let declineAction = UIAlertAction(title: buttonDeclineTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("AlertService.showAlert: \(buttonDeclineTitle) button tapped")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(declineAction)
        
        profileViewControllerDelegate?.view?.present(alertController, animated: true, completion: nil)
        
    }
}

