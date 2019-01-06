//
//  ViewController.swift
//  SocialNetworkLogin
//
//  Created by Ângelo Melo on 05/01/19.
//  Copyright © 2019 Ângelo Melo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class ViewController: UIViewController {
    
   @IBOutlet weak var emailTextField: UITextField!
   @IBOutlet weak var passwordTextField: UITextField!
   @IBOutlet var btnFacebook: FBSDKLoginButton!
    
   let usersignedinKey = "usersignedin"
   let segueToSignin   = "Segue_To_Signin"
   let userDefault     = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGoogle()
        configureFacebook()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userDefault.bool(forKey: usersignedinKey) {
            self.navigateTosSigninScreen()
        }
    }
    
    fileprivate func saveStatusLogged() {
        self.userDefault.set(true, forKey: usersignedinKey)
        self.userDefault.synchronize()
    }
    
    fileprivate func navigateTosSigninScreen() {
        self.performSegue(withIdentifier: segueToSignin, sender: self)
    }

}

extension ViewController {
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        signInUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error ==  nil {
                self.saveStatusLogged()
                self.navigateTosSigninScreen()
            } else if (error?._code == AuthErrorCode.userNotFound.rawValue) {
                self.createUser(email: email, password: password)
            } else {
                print(error!)
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.saveStatusLogged()
                self.navigateTosSigninScreen()
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
}

extension ViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func configureGoogle() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                if error == nil {
                    self.saveStatusLogged()
                    self.navigateTosSigninScreen()
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
        
    }
}

extension ViewController: FBSDKLoginButtonDelegate {
    
    func configureFacebook() {
        btnFacebook.readPermissions = ["public_profile", "email"];
        btnFacebook.delegate = self
        btnFacebook.backgroundColor = UIColor.clear;
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
                    guard let accessToken = FBSDKAccessToken.current() else {
                        print("Failed to get access token")
                        return
                    }
        
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
                    // Perform login by calling Firebase APIs
                    Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                        if error == nil {
                            self.saveStatusLogged()
                            self.navigateTosSigninScreen()
                        } else {
                            print(error?.localizedDescription ?? "")
                        }
                    }
        
                }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
       
    }
    
}


