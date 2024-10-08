//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Maksim on 22.05.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profileImageView = UIImageView()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileImage = UIImage(named: "avatar")
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let alertService = AlertService.shared
    private let profileLogoutService = ProfileLogoutService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        alertService.profileViewControllerDelegate = self
        self.setupProfileImageView()
        self.setupNameLabel()
        self.setupLoginNameLabel()
        self.setupDescriptionLabel()
        self.setupLogOutButton()
        guard let profile = profileService.profile else { return }
        self.updateProfileDetails(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    //MARK: - Private Methods
    
    @IBAction private func didTapLogOutButton(_ sender: UIButton) {
        alertService.showAlert(title: "Пока, пока", message: "Уверены, что хотите выйти?", buttonConfirmTitle: "Да", buttonDeclineTitle: "Нет")
    }
    
    func logout(){
        UIBlockingProgressHUD.show()
        profileLogoutService.logout()
        let splashViewCotroller = SplashScreenViewController()
        splashViewCotroller.modalPresentationStyle = .fullScreen
        self.present(splashViewCotroller, animated: true, completion: nil)
        UIBlockingProgressHUD.dismiss()
    }
    
    private func setupProfileImageView() {
        
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        self.profileImageView = imageView
    }
    
    private func setupNameLabel() {
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 23.0, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        self.nameLabel = nameLabel
    }
    
    private func setupLoginNameLabel() {
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = UIColor(named: "ColorTextGr")
        loginNameLabel.font = .systemFont(ofSize: 13.0)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 148),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        self.loginNameLabel = loginNameLabel
    }
    
    private func setupDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 13.0)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 176),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        self.descriptionLabel = descriptionLabel
    }
    
    private func setupLogOutButton() {
        let logOutButton = UIButton.systemButton(with: UIImage(named: "Exit")!, target: self, action: #selector(Self.didTapLogOutButton))
        logOutButton.tintColor = .red
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logOutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name
        descriptionLabel?.text = profile.bio
        loginNameLabel?.text = profile.loginName
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        profileImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: .greatestFiniteMagnitude)
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder.jpg"),
            options: [.processor(processor)])
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        }
}

