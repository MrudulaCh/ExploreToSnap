//
//  SignUpViewController.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SWRevealViewController

var resultViewController : UIViewController = UIViewController()
let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
class SignUpViewController: UIViewController {

    @IBOutlet var signUpView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginVeiw: UIView!
    @IBOutlet weak var resetEmailTextFeild: UITextField!
    @IBOutlet weak var resetPasswordView: UIView!
    @IBOutlet weak var loginEmialTextfeild: UITextField!
    @IBOutlet weak var loginPasFeild: UITextField!
    @IBOutlet weak var signUpEmailTextFeild: UITextField!
    @IBOutlet weak var signUpPassFeild: UITextField!
    @IBAction func resetPassword(_ sender: Any) {
        resetPasswordView.isHidden = false;
       
        
    }
    @IBAction func loginAction(_ sender: Any) {
        signUpView.isHidden = true
        loginVeiw.isHidden = false;
        resetPasswordView.isHidden = true;
        
    }
    
    override func viewDidLoad() {
        loginVeiw.isHidden = true;
        resetPasswordView.isHidden = true;
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func viewDidAppear(_ animated: Bool) {
        signUpView.isHidden = false
    }
    @IBAction func signUpAction(_ sender: Any) {
        loginVeiw.isHidden = true
        resetPasswordView.isHidden = true
        signUpView.isHidden = false;
       
    }
    @IBAction func createAccountAction(_ sender: AnyObject) {
        loginVeiw.isHidden = false;
        if signUpEmailTextFeild.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: signUpEmailTextFeild.text!, password: signUpPassFeild.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    let alertController = UIAlertController(title: "Alert", message: "You have successfully signed up", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.signUpEmailTextFeild.text = ""
                    self.signUpPassFeild.text = ""
                   
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
      
    }
    
    @IBAction func login(_ sender: AnyObject) {
        if self.loginEmialTextfeild.text == "" || self.loginPasFeild.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            Auth.auth().signIn(withEmail: self.loginEmialTextfeild.text!, password: self.loginPasFeild.text!) { (user, error) in
                
                if error == nil {
                    
                    print("You have successfully logged in")
                    let alertController = UIAlertController(title: "Alert", message: "You have successfully logged in", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                   // self.present(alertController, animated: true, completion: nil)
                   // self.loginEmialTextfeild.text = ""
                   // self.loginPasFeild.text = ""
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "Home_list_VC") as!
                                Home_list_VC
                    self.navigationController?.pushViewController(next, animated: true)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Reset Password
    @IBAction func submitAction(_ sender: AnyObject){
        if self.emailTextField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.emailTextField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
  
    @objc func dismissKeyboard() {
      view.endEditing(true)
    }
    


    
    
}

