//
//  LoginViewController.swift
//  runway
//
//  Created by Akshaya Jagadeesh on 7/25/20.
//  Copyright © 2020 Akshaya Jagadeesh. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class LoginViewController: UIViewController {
    
  
  @IBOutlet weak var usernameField: UITextField!
  
  
  @IBOutlet weak var passwordField: UITextField!
  
    
    @IBOutlet weak var logIncorrect: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  @IBAction func logInPressed(_ sender: Any) {
    if let email = usernameField?.text, let password = passwordField?.text {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error == nil && authResult != nil {
              self?.performSegue(withIdentifier: "toFeed", sender: self)
                
            } else {
                print("error: \(error!.localizedDescription)")
               
                self?.reset()
            
            }
        }
    }
  }
  
  
  
  
       func reset() {
           usernameField?.text = ""
           passwordField?.text = ""
           logIncorrect?.isHidden = false

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
