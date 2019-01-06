//
//  SignedInViewController.swift
//  SocialNetworkLogin
//
//  Created by Ângelo Melo on 05/01/19.
//  Copyright © 2019 Ângelo Melo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class SignedInViewController: UIViewController {

    @IBOutlet weak var emailOu: UILabel!
    
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any addtional setup after loading the view.
        guard let email = Auth.auth().currentUser?.email else { return }
        emailOu.text = email
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance()?.signOut()
            FBSDKLoginManager().logOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        } 
    }
    
   

}
