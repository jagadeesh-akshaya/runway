//
//  Post.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import Foundation
class Post {
    var id:String
  var author:UserProfile
    var createdAt: Date
    var tag:String
  
  var contentImage: URL
  init (id: String, author: UserProfile, timestamp: Double, tag: String, contentImage: URL) {
        self.id = id
        self.author = author
        self.tag = tag
     
        self.contentImage = contentImage
        self.createdAt = Date(timeIntervalSince1970: timestamp/1000)
    }
} 

