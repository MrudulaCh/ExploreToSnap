//
//  DescriptionOfStores.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import Foundation
import UIKit
import FirebaseStorage
import CoreLocation
import MapKit
import SDWebImage

class DescriptionOfStores:UIViewController,MKMapViewDelegate {
   
    @IBOutlet var Category_Value: UILabel!
    @IBOutlet var map_View: MKMapView!
    @IBOutlet var scroll_View: UIScrollView!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Address: UILabel!
    @IBOutlet weak var websiteName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var storeImage: UIImageView!
    var catvalue = ""
    var wlati = Double()
    var wlongi = Double()
    var wName = ""
    var pNumber = ""
    var sName = ""
    var imageName:UIImage = UIImage()
    var descText = ""
    var emailid = ""
    var addressfield = ""
    var didFlag:Bool = Bool()
    var imageUrl:AnyObject?
    var storage: Storage!
    let loadingView = UIView()
    let loadingLabel = UILabel()
    let spinner = UIActivityIndicatorView()
    var gooleadsenable = true
    
    
    override func viewDidLoad() {
        
        scroll_View.contentSize = CGSize(width: self.scroll_View.frame.size.width, height: self.map_View.frame.origin.y + self.map_View.frame.size.height)
        
        
        let newYorkLocation = CLLocationCoordinate2DMake(wlati, wlongi)
        
        
        // Drop PIN
        let viewRegion = MKCoordinateRegionMakeWithDistance(newYorkLocation, 200, 200)
        map_View.setRegion(viewRegion, animated: false)
        map_View.delegate = self
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = newYorkLocation
        if sName != "" {
            dropPin.title = sName
        } else {
            dropPin.title = "Store Name"
        }
        
        if addressfield != "" {
            dropPin.subtitle = addressfield
        } else {
            dropPin.subtitle = "No Address"
        }
        
        map_View.addAnnotation(dropPin)
        
        self.setLoadingScreen()
        storage = Storage.storage()
        let url = URL(string: imageUrl as! String)
        self.storeImage.sd_setImage(with: url, placeholderImage:UIImage(named: "1"))
        self.Data()
        self.removeLoadingScreen()

        let tapPhone = UITapGestureRecognizer(target: self, action: #selector(DescriptionOfStores.callNumber))
        phoneNumber.isUserInteractionEnabled = true
        phoneNumber.addGestureRecognizer(tapPhone)
        
        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(DescriptionOfStores.OpenMap))
        Address.isUserInteractionEnabled = true
        Address.addGestureRecognizer(tapAddress)
        
        let tapWebsite = UITapGestureRecognizer(target: self, action: #selector(DescriptionOfStores.tapPhoneFunction))
        websiteName.isUserInteractionEnabled = true
        print(wName)
        if !wName.contains("N.A") {
            websiteName.addGestureRecognizer(tapWebsite)
        }
    
    
        
    }

    
    @objc func tapPhoneFunction(sender:UITapGestureRecognizer) {
        let url1  = "https://\(websiteName.text ?? "www.google.com")"
        guard let url = URL(string:url1) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func loadData() {
        DispatchQueue.main.async{
            self.removeLoadingScreen()
        }
    }
    
    @objc func callNumber() {
        let pNumber = phoneNumber.text
        guard let number = URL(string: "tel://\(pNumber ?? "03336856371")") else { return }
        UIApplication.shared.open(number)
        
    }
    
    @objc func OpenMap() {
        
        let latitude:CLLocationDegrees =  wlati
        let longitude:CLLocationDegrees =  wlongi
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let placemark : MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary:nil)
        let mapItem:MKMapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Target Location"
        let launchOptions:NSDictionary = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving, forKey: MKLaunchOptionsDirectionsModeKey as NSCopying)
        let currentLocationMapItem:MKMapItem = MKMapItem.forCurrentLocation()
        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions as? [String : Any])
        
    }
    
    func Data() {
        if(wName != ""){
            websiteName.text = wName
            
        }else{
            websiteName.text = "No website"
        }
        
        if(pNumber != ""){
            phoneNumber.text = pNumber
            
        }else{
            phoneNumber.text = "No phone"
        }
        
        if(sName != ""){
            storeName.text = sName
            
        }else{
            storeName.text = "No name"
        }
        
        if(storeImage.image != nil ){
            
        }else{
        }

        if(descText != ""){
            descriptionText.text = descText
        }else{
            descriptionText.text =  "No Description"
        }
        
        if(emailid != ""){
            Email.text = emailid
        }else{
            Email.text =  "No Email"
        }
        
        if(addressfield != ""){
            Address.text = addressfield
        }else{
            Address.text =  "No Address"
        }
        
        if(catvalue != ""){
            Category_Value.text = catvalue
        }else{
            Category_Value.text =  "No Category"
        }

        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    private func setLoadingScreen() {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.view.frame.width / 2) - (width / 2)
        let y = (self.view.frame.height / 2) - (height / 2) - 60
        loadingView.frame = CGRect(x:x, y:y,width: width, height:height)
        
        // Set Loading Text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.textColor = UIColor.red
        self.loadingLabel.frame = CGRect(x:0,y: 0,width: 140,height: 30)
        
        // Set Spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x:0,y: 0,width: 30,height: 30)
        self.spinner.startAnimating()
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        self.view.addSubview(loadingView)
    }
    
    private func removeLoadingScreen() {
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
    }
    
    func getAdressName(coords: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(coords) { (placemark, error) in
            if error != nil {
                print("Error")
                
            } else {
                
                let place = placemark! as [CLPlacemark]
                
                if place.count > 0 {
                    let place = placemark![0]
                    
                    var adressString : String = ""
                    
                    if place.thoroughfare != nil {
                        adressString = adressString + place.thoroughfare! + ", "
                    }
                    if place.subThoroughfare != nil {
                        adressString = adressString + place.subThoroughfare! + "\n"
                    }
                    if place.locality != nil {
                        adressString = adressString + place.locality! + " - "
                    }
                    if place.postalCode != nil {
                        adressString = adressString + place.postalCode! + "\n"
                    }
                    if place.subAdministrativeArea != nil {
                        adressString = adressString + place.subAdministrativeArea! + " - "
                    }
                    if place.country != nil {
                        adressString = adressString + place.country!
                    }
                    
                    self.Address.text = adressString
                }
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let eventAnnotation = view.annotation as? MKAnnotation {
            let theEvent = eventAnnotation.coordinate
            
            let url = URL(string:"http://maps.apple.com/?saddr=\(currentlocation.latitude),\(currentlocation.longitude)&daddr=\(theEvent.latitude),\(theEvent.longitude)")!
             UIApplication.shared.openURL(url)
        }
    }
    
   

}
