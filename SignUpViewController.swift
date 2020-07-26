//
//  SignUpViewController.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController {
       
    @IBOutlet weak var emailField: UITextField!
       
    @IBOutlet weak var fullNameField: UITextField!

    @IBOutlet weak var usernameField: UITextField!
       
    @IBOutlet weak var passwordField: UITextField!
       
    @IBOutlet weak var confirmPasswordField: UITextField!
       
    @IBOutlet weak var passwordLength: UILabel!
       
    @IBOutlet weak var confirmError: UILabel!
    
       
    @IBOutlet weak var next1Outlet: UIButton!
       
    @IBOutlet weak var otherError: UILabel!
       
    var imagePicker: UIImagePickerController!
     
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
      
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePic))
      tapGestureRecognizer.numberOfTapsRequired = 1
profileImageView.addGestureRecognizer(tapGestureRecognizer)
      profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
  
  @IBAction func editProfile(_ sender: Any) {
    self.present(imagePicker, animated: true, completion: nil)
    print("tapped")
  }
  
  @objc func changeProfilePic () {
    self.present(imagePicker, animated: true, completion: nil)
    print("tapped")
  }
    
    var check = 0
    func checkLength () {

        if (passwordField?.text!.count)! < 7 && passwordField?.text != "" {
            print(passwordField?.text!.count ?? 0)
           passwordField.isHidden = false
            //let utterance = AVSpeechUtterance(string: "Password should be atleast seven characters long, please try again.")
            passwordField?.text = ""
            confirmPasswordField?.text = ""
        } else {
            check += 1
        }
    }
    func checkIfMatch () {
        if confirmPasswordField?.text != passwordField?.text {
            confirmError?.isHidden = false
            //let utterance = AVSpeechUtterance(string: "The passwords do not match, please try again.")
            confirmPasswordField?.text = ""
            passwordField?.text = ""
        } else {
           confirmError?.isHidden = true
           check += 1
        }
    }
    func checkForEmpty () {
        if emailField?.text == "" || fullNameField?.text == "" || passwordField?.text == "" || confirmPasswordField?.text == "" || usernameField?.text == "" {
            //let utterance = AVSpeechUtterance(string: "All fields are required, please fill all of them before clicking next.")
        } else {
            check += 1
        }
    
    }
    
    @IBAction func next1Btn(_ sender: UIButton) {
     checkForEmpty()
     checkLength()
     checkIfMatch()
    
     if check == 3 {
         if let email = emailField?.text, let password = passwordField?.text, let username = usernameField?.text, let name = fullNameField?.text,let image = profileImageView.image{
             Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                 if error == nil && authResult != nil {
                     print("User created!")
                     self.dismiss(animated: false, completion: nil)
                     uploadProfilePic(image) { url in
                         
                         if url != nil {
                             let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                             changeRequest?.displayName = username
                             changeRequest?.photoURL = url
                             
                             changeRequest?.commitChanges { error in
                                 if error == nil {
                                     print("User display name changed!")
                                     saveProfile(username: username, profileImageURL: url!, name: name) { success in
                                         if success {
                                            self.dismiss(animated: true, completion: nil)
                                         } else {
                                           self.reset()
                                             self.otherError?.text = error!.localizedDescription
                                             let utterance = AVSpeechUtterance(string: error!.localizedDescription + "please type a new username or password")
                                         }
                                     }
                                     //self.dismiss(animated: false, completion: nil)
                                 } else {
                                     print("error: \(error!.localizedDescription)")
                                     self.reset()
                                     self.otherError?.text = error!.localizedDescription
                                     let utterance = AVSpeechUtterance(string: error!.localizedDescription + "please type a new username or password")
                                 }
                             }
                         } else {
                             //Error unable to upload profile image
                             self.reset()
                             self.otherError?.text = error!.localizedDescription
                             let utterance = AVSpeechUtterance(string: error!.localizedDescription + "please type a new username or password")
                         }

                     }
      
                 } else {
                     print("error: \(error!.localizedDescription)")
                     self.reset()
                     self.otherError?.text = error!.localizedDescription
                     let utterance = AVSpeechUtterance(string: error!.localizedDescription + "please type a new username or password")
                 }
             }
         }
        
        func uploadProfilePic (_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    let storageRef = Storage.storage().reference().child("user/\(uid)")
                    guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
                    let metaData = StorageMetadata()
                    metaData.contentType = "img/jpg"
                  
                    storageRef.putData(imageData, metadata: metaData) {metaData, error in
                        if error == nil, metaData != nil {
                            
                            storageRef.downloadURL { url, error in
                                completion(url)
                                // success!
                            }
                        } else {
                            //failure
                            completion(nil)
                        }
                    }
                }
                func saveProfile (username: String, profileImageURL: URL, name: String, completion: @escaping ((_ success: Bool)->()) ) {
                   guard let uid = Auth.auth().currentUser?.uid else {return}
                   let databaseRef = Database.database().reference().child("users/profile/\(uid)")
                   let userObject = [
                    "username" : username,
                    "photoURL" : profileImageURL.absoluteString,
                    "name" : name
                    ] as [String:Any]
                    databaseRef.setValue(userObject) { error, ref in
                        completion(error == nil)
                    }
                }
            }
          check = 0
        }
    
    func reset() {
           usernameField?.text = ""
           passwordField?.text = ""
           confirmPasswordField?.text = ""
       }
}

extension SignUpViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
    }
}
