//
//  LoginViewController.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import UIKit

import GoogleSignIn

class LoginViewController: UIViewController,GIDSignInUIDelegate , GIDSignInDelegate {
    
    @IBOutlet weak var UserGoogleSignIn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        configureGoogleSignInButton()

        // Do any additional setup after loading the view.
    }
    
    fileprivate func configureGoogleSignInButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.frame = CGRect(x: 120, y: 580, width: view.frame.width - 240, height: 50)
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            guard let authentication = user.authentication else { return }
            
            /*let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            print(credential)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print(error)
                }*/
            
                print("User signIn successful")
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }

}
