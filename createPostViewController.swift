//
//  createPostViewController.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




class createPostViewController: UIViewController {

  @IBOutlet weak var addTagField: UITextField!
  let databaseRef = Database.database().reference()
  
  var postArray: [String] = []
  
  func appendtoArray () {
    databaseRef.child("posts").observe(.value, with:{
     (snapshot) in
      for child in snapshot.children {
        if let childSnapshot = child as? DataSnapshot, let postDict = childSnapshot.value as? [String: Any],
          let voteCount = postDict["voteCount"] as? Int {
          
          self.postArray.append(childSnapshot.key)!
        }
      }
     })
  }
 
  override func viewDidLoad() {
        super.viewDidLoad()
    timer =  Timer.scheduledTimer(withTimeInterval: 1800.0, repeats: true) { (timer) in
                // Do what you need to do repeatedly
                quicksort(array: &postArray, start: 0, end: count)
            }
         
        // Do any additional setup after loading the view.
    }
  var linkNum = 1
  
  func split(array: inout [String], start: Int, end: Int) -> Int {
    Int(databaseRef.child("posts").child(array[end]).child("voteCount").observe(.value) { snapshot in
      var x: Int = (snapshot.value as? Int)!
      var i: Int = start - 1
      for j in start..<end {
          if( array[end].voteCount <= x) {
              i+=1
              (array[i], array[j]) = (array[j], array[i])
            }
         }
        (array[i+1], array[end]) = (array[end], array[i+1])
             return i+1
         }
    })
  
  
    func quicksort(array: inout [URL], start: Int, end: Int) {
          if(start < end) {
              var mid = split(array: &array, start: start, end: end)
              quicksort(array: &array, start: start, end: mid-1)
              quicksort(array: &array, start: mid+1, end: end)
          }
      }
  
  var timer: Timer?
  
  
  
  
  @IBAction func handlePostBtn(_ sender: Any) {
    guard let userProfile = userService.currentUserProfile else {return}
      let postRef = Database.database().reference().child("posts").childByAutoId()
    
    var strlinkNum = String(linkNum)

    //check if this link has already been assigned to a post
   //for child in snapshot.children {
      
    //if "www.google.com/strlinkNum" {
      //linkNum = Int(strlinkNum)!
      //linkNum = linkNum + 1
    //}
    
      let postObject = [
              
              "author" : [
                "uid" : userProfile.uid,
                "username" : userProfile.username,
                "photoURL" : userProfile.profileImage.absoluteString
              ],
              
              "timeStamp" : [".sv" : "timestamp"],
              "tags" : addTagField.text as Any,
              "contentImage" : "www.google.com"
              
          ] as [String: Any]
          postRef.setValue(postObject, withCompletionBlock: { error, ref in
            //add code to set variable of type URL to contentImage link
              if error == nil {
                  self.performSegue(withIdentifier: "toFeed", sender: self)
               
               // postArray.append(finalLink)
                  print("dismiss!")
                  
              } else {
                  //handle the error
              }
          })
      }
  }

