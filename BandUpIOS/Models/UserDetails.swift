//
//  UserDetails.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation

struct UserDetails: Decodable {
    var id: Int
    var username: String
    var profilePicture: String?
}
