//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Maksim on 13.06.2024.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            return userDefaults.string(forKey: "accessToken")
        } set {
            userDefaults.setValue(newValue, forKey: "accessToken")
            print("Your token is \(token ?? "") is saved")
        }
    }
    
    private let userDefaults = UserDefaults.standard
}
