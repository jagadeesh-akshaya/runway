//
//  userService.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import Foundation
import Firebase

class userService {
    static var currentUserProfile: UserProfile?
    static func observeUserProfile(_ uid:String, completion: @escaping ((_ userProfile:UserProfile?)->())) {
        //let userRef = Database.database().reference().child("users").child("profile").child("WA389Yv1vIZuJP0cvxy37FYUuRc2")
  
        let userRef = Database.database().reference().child("users/profile/\(uid)")
        userRef.observe(.value, with: { (snapshot) in
            var userProfile:UserProfile?
          print("USER\(snapshot.value as Any)")
            if let dict = snapshot.value as? [String:Any],
                let username = dict["username"] as? String,
                let profileImage = dict["photoURL"] as? String,
                let url = URL(string: profileImage) {
              userProfile = UserProfile(uid: snapshot.key, username: username, profileImage: url)
            }
            completion(userProfile)
            
        })
    }
}
