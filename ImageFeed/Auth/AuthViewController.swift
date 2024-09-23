//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Maksim on 03.06.2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String)
    func authViewController(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Failed to prepare for \(showWebViewSegueIdentifier)")
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
                   webViewViewController.presenter = webViewPresenter
                   webViewPresenter.view = webViewViewController
                   webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
            case .failure(let error):
                print("Ошибка при получении OAuth токена: \(error.localizedDescription)")
                
            }
        }
    }
    
    func webViewViewControllerdidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}


