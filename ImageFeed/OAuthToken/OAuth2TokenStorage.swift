//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Maksim on 05.07.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    private let tokenKey = "Auth token"
    
    var token: String? {
        get { KeychainWrapper.standard.string(forKey: tokenKey) }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func clearToken() {
        guard KeychainWrapper.standard.string(forKey: tokenKey) != nil else { return }
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
