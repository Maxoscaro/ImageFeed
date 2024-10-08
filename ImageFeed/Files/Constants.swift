//
//  Constants.swift
//  ImageFeed
//
//  Created by Maksim on 01.06.2024.
//

import Foundation

enum Constants {
    static let accessKey = "UkLT-MSMG1nv4EiVnUYURbVrKU0UJc2vfKfaJhVQuhs"
    static let secretKey = "ktS4n64hDw_kCg2A_L5Fkk_ZrCzSxv7UojlzkCxV1CA"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let authPath: String = "oauth/token/"
    static let defaultBaseURL = URL(string: "https://unsplash.com/")
    static let defaultPhotos = "https://api.unsplash.com/photos/"
    static let profileURLString = "https://api.unsplash.com/me"
    static let profileUserURl = "https://api.unsplash.com/users/"
    static let authorizeURL = "https://unsplash.com/oauth/authorize"
}
