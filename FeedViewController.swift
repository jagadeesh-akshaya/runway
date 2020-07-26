//
//  FeedViewController.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
class FeedViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var bioField: UILabel!
    
    @IBOutlet weak var timeField: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var postsLength: UILabel!
    
    @IBOutlet weak var minutesAgo: UILabel!
  
    @IBOutlet weak var designImage: UIImageView!
  
    var posts = [Post]()
    var post = [AnyObject?]()
    var loggedInUser : AnyObject?
    var loggedInUserData : AnyObject?
    let databaseRef = Database.database().reference()
    var Index = 0
    var userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        getPost()
        // Do any additional setup after loading the view.
    }
    var postCount:UInt = 0
    var PostCount = 0
    
    func getPost() {

        databaseRef.child("posts").observe(.value, with: { (snapshot) in
            var tempPosts = [Post]()
            print("Snap:\(snapshot.value as Any)")
          
            for child in snapshot.children {
              
                if let childSnapshot = child as? DataSnapshot,
                    let postDict = childSnapshot.value as? [String : Any],
                    let author = postDict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let timeStamp = postDict["timeStamp"] as? Double,
                    let photoURL = author["photoURL"] as? String,
                  let tags = postDict["tags"] as? String,
                  let designImages = postDict["contentImage"] as? String,
                  let url = URL(string: designImages),
                    let url1 = URL(string: photoURL){
                    
                  let userProfile = UserProfile(uid: uid, username: username, profileImage: url1)
                 // let post = Post(id: childSnapshot.key, author: userProfile, contentImage: designImages, tags: tags, timestamp: timeStamp)
                  
                  let post = Post(id: childSnapshot.key, author: userProfile, timestamp: timeStamp, tag: tags, contentImage: url)
                    tempPosts.insert(post, at: 0)
                    
                    
                }
            }
        
            self.posts = tempPosts
            print("count: \(self.posts.count)")
          self.databaseRef.child("posts").child("count").setValue(self.posts.count)
            self.postsLength?.text = String(self.posts.count)
         // print("index:\(posts[Index])")
            self.set(post: self.posts, index: self.Index)
          
        
          // ...
        })
            
    }
    func set (post: [Post], index: Int) {
      
      if index > 0 {
      print(index)
        if (post[index].author.uid != userID) {
                   ImageService.getImage(withURL: post[index].author.profileImage) { image in
                       self.profileImageView.image = image
                           
                   }
         usernameLabel?.text = post[index].author.username
        minutesAgo?.text = post[index].createdAt.calendarTimeSinceNow()

               }
      }
       
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
