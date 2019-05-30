//
//  AddStores.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import Foundation
import  UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MapKit
import CoreLocation
import DropDown


class AddStore:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate{
    
    let catdropdown = DropDown()
    @IBOutlet var Category_Button: UIButton!
    @IBOutlet var txt_category: UITextField!
    @IBOutlet weak var nameTextFeild: UITextField!
    @IBOutlet weak var phoneTextFeild: UITextField!
    @IBOutlet weak var webTextFeild: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet var Txt_Address: UITextView!
    @IBOutlet var Txt_Email: UITextField!
    
    @IBOutlet var Addtostore: UIButton!
    @IBOutlet var Scroll_View: UIScrollView!
    @IBOutlet var Backsideview: UIView!
    // Vars
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var timer:Timer?
    var ref:DatabaseReference!
    let databaseRef = Database.database().reference(withPath: "photographyplaces")
    let storageRef = Storage.storage().reference()
    let imagePicker = UIImagePickerController()
    let imageView = UIImageView()
    fileprivate let locationManager = CLLocationManager()
    var mapView:MKMapView!
    var lati:Double = Double()
    var longi:Double = Double()
    
    
    
    override func viewDidLoad() {
        imagePicker.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        addControls()
        setupdropdown()
        
        Backsideview.frame.size.height = Addtostore.frame.origin.y + Addtostore.frame.size.height + 20
        Scroll_View.contentSize = CGSize(width: self.Scroll_View.frame.size.width, height: Backsideview.frame.size.height + Backsideview.frame.origin.y)
    }
    
    func setupdropdown() {
        
        catdropdown.anchorView = Category_Button
        catdropdown.dataSource = EditableCategory
        catdropdown.selectionAction = { (index: Int, item: String) in
            self.txt_category.text = item
        }
        
        catdropdown.width = txt_category.frame.size.width
        
    }
   
    @IBAction func Click_Dropdown(_ sender: UIButton) {
        catdropdown.show()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            let location = locations.last! as CLLocation
            let coord = location.coordinate
            longi = coord.longitude
            lati = coord.latitude
        }
    }

    
    
    @IBAction func takeAPhoto(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Photo", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default){
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Photo Gallery", style: UIAlertActionStyle.default){
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel){
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
        if(imagePicker.sourceType == .camera){
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }else{
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
   @IBAction func AddStore(_ sender: Any) {
        postDataToFireBase()
    ref = Database.database().reference()
    }
    func openCamera(){
        imagePicker.delegate = self
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(imagePicker, animated: true, completion: nil)
        }else{
            let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel){
                UIAlertAction in
            }
            alert.addAction(cancelAction)
        }
        
    }
    
    func openGallary(){
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func postDataToFireBase(){
        
        var sNams = ""
        var website = "N.A"
        var description = ""
        var phoneNumber = "N.A"
        var photoUrl:URL
        var email = "N.A"
        var address = ""
        var category = ""
        if(nameTextFeild.text != nil){
            sNams = nameTextFeild.text!
            
        }
        if(webTextFeild.text != nil){
            website = webTextFeild.text!
        }
        if(descriptionText.text != nil){
            description = descriptionText.text!
        }
        if(phoneTextFeild.text != nil){
            phoneNumber = phoneTextFeild.text!
        }
        
        if(phoneTextFeild.text != nil){
            email = Txt_Email.text!
        }
        
        if(phoneTextFeild.text != nil){
            address = Txt_Address.text!
        }
        
        if(txt_category.text != nil){
            category = txt_category.text!
        }
        
        if(nameTextFeild.text != nil && descriptionText.text != nil && imageView.image != nil && Txt_Address.text != nil && txt_category.text != nil){
            let  imageUploadManager = ImageUploadManager()
            imageUploadManager.uploadImage(imageView.image!, progressBlock: { (percentage) in
                print(percentage)
                self.progressView?.isHidden = false
                let myFloat: Float = percentage
                let myInt = Int(myFloat)
                self.progressLabel?.text = "\(myInt) %"
                self.progressView?.progress = myFloat/100.0
                
            }, completionBlock: { [weak self] (fileURL, errorMessage) in
                guard let strongSelf = self else {
                    return
                }
                
                
                print("**")
                let photo:String = (fileURL?.absoluteString)!
                print(photo)
                print("**")
                
                let newPostRef = Database.database().reference().child("photographyplaces").childByAutoId()
                let newPostKey = newPostRef.key
                
                //let key = self?.databaseRef.childByAutoId().key
                
                let currentdate = Date()
                let dateformater = DateFormatter()
                dateformater.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let datestr = dateformater.string(from: currentdate)
                print(datestr)
                
                
                let post:[String:AnyObject] = ["sNams":sNams as AnyObject,"description":description as AnyObject,"phoneNumber":phoneNumber as AnyObject,"website":website as AnyObject,"photo":photo as AnyObject,"lati":self!.lati as AnyObject,"longi":self!.longi as AnyObject,"address":address as AnyObject,"email":email as AnyObject,"category":category as AnyObject,"date":datestr as AnyObject]
               
                self?.databaseRef.child("locationimages/\(newPostKey)").setValue(post)
                let storeData = StoreDataModel(name: sNams, description: description, photo: photo , lati: self!.lati, longi: self?.longi, website: website, phoneNumber: phoneNumber,email:email,Address:address,category:category, date: datestr)
                storeList.insert(storeData, at: 0)
                self?.progressLabel?.text = "\(100) %"
                self?.progressView?.progress = 1000/100.0
                self?.alertController(msg: "Saved!",title:"Well Done")
            })
        } else {
            alertController(msg: "Please enter all parameters.",title:"CityTravel")
        }
    }
    
    func alertController(msg:String,title:String){
    let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
       view.endEditing(true)
    }
    
    func addControls() {
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
        progressView?.frame = CGRect(x:view.frame.width/1.8,y:(view.frame.height-140),width:150,height:60)
        view.addSubview(progressView!)
        progressView?.isHidden = true
        progressLabel = UILabel()
        let frame = CGRect(x: ((view.frame.width/2.8)+130), y:(view.frame.height-175), width: 60, height: 30)
        progressLabel?.frame = frame
        progressLabel?.textColor = UIColor.black
        view.addSubview(progressLabel!)
        
    }
}
