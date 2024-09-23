//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Maksim on 20.09.2024.
//

import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var profile: Profile? { get set }
    var view: ProfileViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func logOutButtonTapped()
    func updateProfileDetails()
    func getProfileAvatarURL() -> URL?
}

final class ProfilePresenter: ProfilePresenterProtocol {
   
    var profile: Profile?
    var view: ProfileViewViewControllerProtocol?
    
    private var profileService: ProfileServiceProtocol?
    private var profileImageService: ProfileImageServiceProtocol?
    private let alertService = AlertService.shared
    private var profileLogoutService: ProfileLogoutServiceProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        
        configureProfileService(ProfileService.shared)
        configureProfileLogoutService(ProfileLogoutService.shared)
        configureProfileImageService(ProfileImageService.shared)
        alertService.profileViewControllerDelegate = self
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak view] _ in
                guard let view = view else { return }
                view.updateAvatar()
            }
        view?.updateAvatar()
    }
    
    func configureProfileService(_ profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    func configureProfileLogoutService(_ profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileLogoutService = profileLogoutService
    }
    
    func configureProfileImageService(_ profileImageService: ProfileImageServiceProtocol) {
        self.profileImageService = profileImageService
    }
    
    func logout() {
        UIBlockingProgressHUD.show()
        profileLogoutService?.logout()
        let splashViewCotroller = SplashScreenViewController()
        splashViewCotroller.modalPresentationStyle = .fullScreen
        view?.present(splashViewCotroller, animated: true, completion: nil)
        UIBlockingProgressHUD.dismiss()
    }
    
    func fetchProfileAvatarURL() -> URL? {
          return self.getProfileAvatarURL()
      }

    func logOutButtonTapped() {
        alertService.showAlert(title: "Пока, пока", message: "Уверены, что хотите выйти?", buttonConfirmTitle: "Да", buttonDeclineTitle: "Нет")
        
    }
    
        func updateProfileDetails() {
            
            guard let profile = profileService?.profile else { return }
                   self.profile = profile
        }
        
        func getProfileAvatarURL() -> URL? {
            guard
                let profileImageURL = profileImageService?.avatarURL,
                let url = URL(string: profileImageURL)
            else {   
                return nil
            }
            return url
        }
        
    }

