//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Maksim on 23.09.2024.
//

import Foundation
import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var profile: Profile?
    var view: ProfileViewViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var isLogoutButtonTapped: Bool = false
    
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        print("ProfilePresenterSpy's viewDidLoad called") // Логирование вызова
    }
    
    func logout() {
        
    }
    
    func logOutButtonTapped() {
        isLogoutButtonTapped = true
    }
    
    func updateProfileDetails() {
        
    }
    
    func getProfileAvatarURL() -> URL? {
        return nil
    }
}
