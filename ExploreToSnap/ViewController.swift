//
//  ViewController.swift
//  ExploreToSnap
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class ViewController: UIViewController,MKMapViewDelegate {
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var arViewController: ARViewController!
    fileprivate var startedLoadingPOIs = false
    fileprivate var places = [Place]()
    
    let colors = [UIColor.red,UIColor.green,UIColor.orange,UIColor.blue,UIColor.black]
    var placnameary = [String]()
    var placeary = [PlaceAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        print("**")
        print(storeList)
    }
    
    
    @IBAction func showARController(_ sender: Any) {
        arViewController = ARViewController()
        arViewController.dataSource = self
       // arViewController.maxVisibleAnnotations = 30
        //arViewController.headingSmoothingFactor = 0.05
        
        arViewController.presenter.distanceOffsetMode = .manual
        arViewController.presenter.distanceOffsetMultiplier = 0.1   // Pixels per meter
        arViewController.presenter.distanceOffsetMinThreshold = 500 // Doesn't raise annotations that are nearer than this
        // Filtering for performance
        arViewController.presenter.maxDistance = 3000               // Don't show annotations if they are farther than this
        arViewController.presenter.maxVisibleAnnotations = 100      // Max number of annotations on the screen
        // Stacking
        arViewController.presenter.verticalStackingEnabled = true
        // Location precision
        arViewController.trackingManager.userDistanceFilter = 15
        arViewController.trackingManager.reloadDistanceFilter = 50
        // Ui
        arViewController.uiOptions.closeButtonEnabled = true
        // Debugging
        arViewController.uiOptions.debugLabel = true
        arViewController.uiOptions.debugMap = true
        arViewController.uiOptions.simulatorDebugging = Platform.isSimulator
        arViewController.uiOptions.setUserLocationToCenterOfAnnotations =  Platform.isSimulator
        // Interface orientation
        arViewController.interfaceOrientationMask = .all
        // Failure handling
        arViewController.onDidFailToFindLocation =
            {
                [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
                // Show alert and dismiss
        }
        
        arViewController.setAnnotations(places)
        self.present(arViewController, animated: true, completion: nil)
    }
    
    
    
}

extension UIImage {
    func tint(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        
        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


extension ViewController: CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "AnnotationIdentifier"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
            anView = dequeuedAnnotationView
            anView?.annotation = annotation
        }
        else {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        
        //Set annotation-specific properties **AFTER**
        anView?.canShowCallout = true
        let cpa = annotation as! CustomPointAnnotation
        anView?.image = UIImage(named:cpa.imageName)
        
        return anView
        
    }
    
    
    // Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if locations.count > 0 {
            let location = locations.last!
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                
                let reference = "photographyplaces"
                
                //Now starts here
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true
                    let databaseRef = Database.database().reference().child("photographyplaces")
                    databaseRef.observe(DataEventType.value, with: { (snapshot) in
                        print(snapshot)
                        if snapshot.childrenCount > 0 {
                            for stores in snapshot.children.allObjects as! [DataSnapshot] {
                                let storeObject = stores.value as? [String: AnyObject]
                                let storeName  = storeObject?["sNams"]
                                let sDescription  = storeObject?["description"]
                                let website = storeObject?["website"]
                                let phoneNumber = storeObject?["phoneNumber"]
                                let photoS = storeObject?["photo"]
                                let sLati = storeObject?["lati"]
                                let sLongi = storeObject?["longi"]
                                let email = storeObject?["email"]
                                let address = storeObject?["address"]
                                let cate = storeObject?["category"]
                                
                                let location = CLLocation(latitude: sLati as! CLLocationDegrees, longitude: sLongi as! CLLocationDegrees)
                                print(location)
                                let place = Place(location: location, reference: reference, name: storeName as! String, des: sDescription as! String, website: website as! String, phoneNumber: phoneNumber as! String,photo:photoS as AnyObject,email:email as! String,Address:address as! String,category:cate as! String, newlati: sLati as! Double,newlong:sLongi as! Double)
                                self.places.append(place)
                                let annotation = PlaceAnnotation(location: (place.location.coordinate), title:place.placeName, phoneNumber: place.phoneNumber!, website: place.website!, photo: place.photo! as AnyObject, des: place.des ,email:(place.email as? String)!,Address:(place.Address as? String)!,category:(place.category as? String)!)
                                self.placeary.append(annotation)
                                self.placnameary.append(place.placeName)
                                let distance = locations.last!.distance(from: location)
                                let finalindex = EditableCategory.index(of: place.category!)
                                let info1 = CustomPointAnnotation()
                                info1.coordinate = annotation.coordinate
                                info1.title = place.placeName
                                info1.subtitle = String(format: "%.2f miles", distance / 1000)
                                info1.imageName =  PinImageName[finalindex!]
                                self.mapView.addAnnotation(info1)
                                
                                
                                
                                
                                DispatchQueue.main.async {
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    
}

extension ViewController: ARDataSource {
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 160, height: 60)
        return annotationView
    }
    
    func showInfoView(forPlace PlaceAnnotation: PlaceAnnotation) {//1
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "DescriptionOfStores") as! DescriptionOfStores
        (resultViewController ).sName = PlaceAnnotation.title!
        (resultViewController ).descText = PlaceAnnotation.des!
        (resultViewController ).imageUrl = PlaceAnnotation.photo
        (resultViewController ).pNumber = PlaceAnnotation.phoneNumber!
        (resultViewController ).wName = PlaceAnnotation.website!
        (resultViewController).didFlag = true
        resultViewController.wlati = PlaceAnnotation.coordinate.latitude
        resultViewController.wlongi = PlaceAnnotation.coordinate.longitude
        resultViewController.emailid = PlaceAnnotation.email!
        resultViewController.addressfield = PlaceAnnotation.Address!
        resultViewController.catvalue = PlaceAnnotation.category!
        
        self.navigationController?.pushViewController(resultViewController, animated:true)
        
    }
    
}

extension ViewController: AnnotationViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        print(view.annotation?.title)
        let index = placnameary.index(of: ((view.annotation?.title)!)!)
        let placeannotation = placeary[index!]
        showInfoView(forPlace: placeannotation)
    }
    
    func didTouch(annotationView: AnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            print(annotation.placeName)
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "DescriptionOfStores") as! DescriptionOfStores
            (resultViewController ).sName = annotation.placeName
            (resultViewController ).descText = annotation.des
            (resultViewController ).imageUrl = annotation.photo
            (resultViewController ).pNumber = annotation.phoneNumber!
            (resultViewController ).wName = annotation.website!
            (resultViewController).didFlag = true
            resultViewController.wlati = annotation.newlati
            resultViewController.wlongi = annotation.newlong
            resultViewController.emailid = annotation.email!
            resultViewController.addressfield = annotation.Address!
            resultViewController.catvalue = annotation.category!
            annotationView.removeFromSuperview()
            self.arViewController.dismiss(animated: false, completion: nil)
            
            self.navigationController?.pushViewController(resultViewController, animated:true)
            
        }
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    var pincolor:UIColor!
}



