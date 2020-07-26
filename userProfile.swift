//
//  userProfile.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import Foundation

class UserProfile {
    var uid: String
    var username: String
    
    var profileImage: URL
  init(uid: String, username: String, profileImage: URL){
        self.uid = uid
        self.username = username
      
        self.profileImage = profileImage
    }
}
