//
//  SplashScreenViewController.swift
//  ImageFeed
//
//  Created by Maksim on 13.06.2024.
//

import UIKit

final class SplashScreenViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
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
}
    extension SplashScreenViewController {
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showAuthenticationScreenSegueIdentifier {
                guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers[0] as?
                        AuthViewController
                else {
                    assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                    return
                }
                viewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }

    extension SplashScreenViewController: AuthViewControllerDelegate {
        func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                switchToTabBarController()
            }
        }
   
    }
