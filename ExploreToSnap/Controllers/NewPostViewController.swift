//
//  NewPostViewController.swift
//  ExploreToSnap
//
//  Created by Mrudula on 5/30/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import UIKit
import CoreLocation

class NewPostViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    fileprivate let locationManager = CLLocationManager()
    
    var latitude:Double = Double()
    var longitude:Double = Double()
    
    var textViewPlaceholderText = "Share your Experience"
    
    var takenImage: UIImage!
    var imagePicker: UIImagePickerController!
    var didShowCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        captionTextView.text = textViewPlaceholderText
        captionTextView.textColor = .lightGray
        captionTextView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !didShowCamera {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
           /* if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
            } else {*/
                imagePicker.sourceType = .photoLibrary
           // }
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            let location = locations.last! as CLLocation
            let coord = location.coordinate
            longitude = coord.longitude
            latitude = coord.latitude
        }
        
    }
    
    @IBAction func shareDidTap()
    {
        if captionTextView.text != textViewPlaceholderText && captionTextView.text != "" && takenImage != nil {
            let newPost = Post(image: self.takenImage, caption: self.captionTextView.text,latitude: self.longitude, longitude: self.latitude)
            newPost.save()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelDidTap(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

    extension NewPostViewController : UITextViewDelegate
    {
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == textViewPlaceholderText {
                textView.text = ""
                textView.textColor = .white
            }
            textView.becomeFirstResponder()
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = textViewPlaceholderText
                textView.textColor = .lightGray
            }
            textView.resignFirstResponder()
        }
    }

extension NewPostViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(image)
        self.postImageView.image = image
        self.takenImage = image
        didShowCamera = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
