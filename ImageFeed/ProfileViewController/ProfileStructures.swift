//
//  ProfileStructures.swift
//  ImageFeed
//
//  Created by Maksim on 20.06.2024.
//

import Foundation

struct ProfileResult: Codable {
    
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    
    private enum CodingKeys: String, CodingKey {
        
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }

    func toProfile() -> Profile {
        return Profile(
            username: self.userName,
            name: "\(self.firstName ?? "") \(self.lastName ?? "")",
            loginName: "@\(self.userName)",
            bio: self.bio ?? "empty"
        )
    }
}
struct Profile {
    
    var username: String
    var name: String
    var loginName: String
    var bio: String?
}




