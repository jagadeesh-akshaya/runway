//
//  editProfileViewController.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import AVFoundation

class editProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var editPic: UIButton!
  
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var editName: UITextField!
  @IBOutlet weak var aboutMe: UITextField!
  @IBOutlet weak var saveChanges: UIButton!
    let databaseRef = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.databaseRef.child("users").child("profile").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String:Any]
            let databaseProfilePic = dict?["photoURL"] as? String
            let data = URL(string: databaseProfilePic!)
            if data != nil {
                ImageService.getImage(withURL: data!) { image in
                    self.profileImage.image = image
                }
                let about = dict?["about"] as? String
                self.aboutMe?.text = about
                let name = dict?["name"] as? String
                self.editName?.text = name
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.changeProfilePic1))
            tapGestureRecognizer.numberOfTapsRequired = 1
            self.profileImage.addGestureRecognizer(tapGestureRecognizer)
            
        }
    
        // Do any additional setup after loading the view.
    }
    var isProfilePic: Bool = false
    @objc func changeProfilePic1 () {
        isProfilePic = true
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true) {
            
        }
    }
  
  @IBAction func saveChangesButton(_ sender: Any) {
    databaseRef.child("users").child("profile").child(userID!).child("about").setValue(self.aboutMe?.text)
    
    databaseRef.child("users").child("profile").child(userID!).child("name").setValue(self.editName?.text)
    
    self.dismiss(animated: true, completion: nil)
    uploadProfilePic(profileImage.image!){ url in
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = url
        changeRequest?.commitChanges { error in
            if error == nil {
                self.saveProfile(profileImageURL: url!)
              
            }
        }
    }
  }
  
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if isProfilePic {
              profileImage.image = image
            }
               
           } else {
               print("Error babe")
               
           }
           self.dismiss(animated: true, completion: nil)
       }
    
    
    let userID = Auth.auth().currentUser?.uid
    
    func saveProfile (profileImageURL: URL) {
        let userObject = profileImageURL.absoluteString
        databaseRef.child("users").child("profile").child(userID!).child("photoURL").setValue(userObject)
        
    }
    func uploadProfilePic (_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
        let storageRef = Storage.storage().reference().child("user/\(userID!)")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
