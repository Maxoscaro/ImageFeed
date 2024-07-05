//
//  SplashScreenViewController.swift
//  ImageFeed
//
//  Created by Maksim on 13.06.2024.
//

import UIKit

final class SplashScreenViewController: UIViewController {
    
    private var splashImageView = UIImageView()
    private let splashImage = UIImage(named: "Logo_of_Unsplash")
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2TokenStorage.shared
    private let oauthService = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSplashImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2Service.token {
            
            self.fetchProfile(token)
            
        } else {
            guard let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(identifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    private func setupSplashImageView(){
        let imageView = UIImageView(image: splashImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        self.splashImageView = imageView
    }
}

extension SplashScreenViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oauth2Service.token else { return }
        self.fetchProfile(token)
        
        self.switchToTabBarController()
    }
    
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            
            guard let self = self else { return }
            self.fetchOAuthToken(code)
            UIBlockingProgressHUD.show()
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauthService.fetchOAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                
            case .failure:
                self.showAlert()
                break
            }
        }
    }
    
    func fetchProfile(_ token: String){
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username) { result in
                    switch result{
                    case .success:
                        print("Avatar recieved")
                    case .failure:
                        
                        break
                    }}
                self.switchToTabBarController()
            case .failure:
                self.showAlert()
                break
            }
        }
    }
    
    func fetchImageProfile(_ username: String){
        profileImageService.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success:
                print("Успешно загружен аватар")
            case .failure:
                self.showAlert()
                break
            }
        }
    }
    
    private func showAlert() {
        
        let alertController = UIAlertController(title: "Ошибка", message: "Что-то пошло не так", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("Ok button tapped")
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}




