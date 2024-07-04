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
    let bio: String
    
    
    private enum CodingKeys: String, CodingKey {
        
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
    
    static func decodeProfileResponse(from data: Data) -> Result<ProfileResult, Error> {
        do {
            let response = try JSONDecoder().decode(ProfileResult.self, from: data)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
struct Profile {
    
    var username: String
    var name: String
    var loginName: String
    var bio: String
}

extension Profile {
    init(result profile: ProfileResult) {
        self.init(
            username: profile.userName,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.userName)",
            bio: profile.bio
        )
    }
}
