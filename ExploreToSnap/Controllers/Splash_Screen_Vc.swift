//
//  Splash_Screen_Vc.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import UIKit
import AVFoundation
import GoogleSignIn

class Splash_Screen_Vc: UIViewController,GIDSignInUIDelegate , GIDSignInDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        configureGoogleSignInButton()
        
        let playerLayer = videoPlayerLayer()
        playerLayer.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
        playerLayer.frame = view.frame
        view.layer.insertSublayer(playerLayer, at: 0)
        
        go_button.layer.cornerRadius = self.go_button.frame.size.height/2
        go_button.clipsToBounds = true
        
        self.view.bringSubview(toFront: go_button)
    }
    
    fileprivate var player: AVPlayer? {
        didSet { player?.play() }
    }
    
    fileprivate func configureGoogleSignInButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.frame = CGRect(x: 120, y: 580, width: view.frame.width - 240, height: 50)
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBOutlet weak var go_button: UIButton!
    fileprivate var playerObserver: Any?
    
    deinit {
        guard let observer = playerObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }
    
    func videoPlayerLayer() -> AVPlayerLayer {
        let videoURL: URL = Bundle.main.url(forResource: "video", withExtension: "mov")!

        let player = AVPlayer(url: videoURL)
        let resetPlayer = {
            player.seek(to: kCMTimeZero)
            player.play()
        }
        playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
            resetPlayer()
        }
        self.player = player
        return AVPlayerLayer(player: player)
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
