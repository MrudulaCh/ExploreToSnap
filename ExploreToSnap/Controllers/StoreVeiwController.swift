//
//  StoreVeiwController.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import CoreLocation

var storeList = [StoreDataModel]()
var currentlocation = CLLocationCoordinate2D()
import SDWebImage
import Firebase


var EditableCategory = ["San Francisco","New York","Spain","France","England"] // Insert here your Categories
var PinImageName = ["pin1","pin2","pin3","pin4","pin5"] // Insert here your Categories PINs Images
var CategoryImage = [#imageLiteral(resourceName: "SanFrancisco"),#imageLiteral(resourceName: "NY"),#imageLiteral(resourceName: "Spain"),#imageLiteral(resourceName: "France"),#imageLiteral(resourceName: "England")] // Insert here your Categories Images




struct storeData {
    let storeName:AnyObject!
    let storePhoto:AnyObject!
}

class StoreViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @IBOutlet weak var umar: UIImageView!
    var resultViewController : UIViewController = UIViewController()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var database: Database!
    var storage: Storage!
    var auth:Auth!
    
    var lat:Double = Double()
    var long:Double = Double()
    let locationManager = CLLocationManager()
    var a:Int = 0
    let imageView = UIImageView();
    var categotypeselect = "All"
    var catary = [StoreDataModel]()
    var shoppingary = [StoreDataModel]()
    var Barary = [StoreDataModel]()
    var Resturantary = [StoreDataModel]()
    var cateindex = Int()
    @IBOutlet weak var storeTableView: UITableView!
    
    var gooleadsenable = false
    override func viewDidLoad() {
        
        
         self.setLoadingScreen()
        database = Database.database()
        storage = Storage.storage()
        auth = Auth.auth()
         storeTableView.delegate = self
         storeTableView.dataSource = self
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
         locationManager.startUpdatingLocation()
         locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.main.async {
            self.loadDataFromFirebase()
        }

        self.storeTableView.addSubview(self.refreshControl)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {

    }
    
    
    
    @IBAction func Click_ActionSheet(_ sender: UIBarButtonItem) {
        
        let actionSheetController = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        
        let All = UIAlertAction(title: "All", style: .default) { action -> Void in
            
            self.CatFillAry(catetype: "All")
            self.categotypeselect = "All"
            self.storeTableView.reloadData()
        }
        actionSheetController.addAction(All)
        for i in 0..<EditableCategory.count {
            
            let Bar = UIAlertAction(title: EditableCategory[i], style: .default) { action -> Void in
                self.CatFillAry(catetype: EditableCategory[i])
                self.categotypeselect = EditableCategory[i]
                self.storeTableView.reloadData()
            }
            
            actionSheetController.addAction(Bar)
        }

        actionSheetController.popoverPresentationController?.sourceView = sender.customView
        
        actionSheetController.addAction(cancelAction)
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone){
            self.present(actionSheetController, animated: true, completion: nil)
        } else {
            
            let popController: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            popController.permittedArrowDirections = .any
            popController.barButtonItem = sender
            self.present(actionSheetController, animated: true, completion: nil)
            
        }
        
        
    }
    
    func CatFillAry(catetype:String) {
        self.catary.removeAll()
        for i in 0..<storeList.count {
            
            if storeList[i].category == catetype {
                self.catary.append(storeList[i])
                
            }
            
        }
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        Pictures.flag = false
        self.loadDataFromFirebase()
        refreshControl.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("picArray\(Pictures.picArray.count)")
        
        if self.categotypeselect == "All" {
            
            return storeList.count
        } else {
            
            return catary.count
        }
        
    }
    var selectedImage: String?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StoreCell
        let store:StoreDataModel
        cell.selectionStyle = .none
        if self.categotypeselect == "All" {
            store = storeList[indexPath.row]
            
        } else {
            store = catary[indexPath.row]
            
        }
        
        
            let picstr = store.photo
            let url = URL(string: picstr!)
        
            cell.cellTitleLabel.text = store.sName
            cell.cellBg.sd_setImage(with: url)
            let coordinate₀ = CLLocation(latitude:lat, longitude:long)
            let coordinate₁ = CLLocation(latitude:store.lati!, longitude: store.longi!)
            let distanceInMeters = coordinate₀.distance(from: coordinate₁)*0.000621371
            let dist = distanceInMeters
            let distanceInMiles = Double(dist)
            cell.distanceLabel.text = String(format: "%.2f miles",distanceInMiles)
            cell.distanceLabel.layer.cornerRadius = 12
            cell.CategoryLabel.text = store.category
    
    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "DescriptionOfStores") as! DescriptionOfStores
        let store:StoreDataModel
        if self.categotypeselect == "All" {
            store = storeList[indexPath.row]
            
        } else {
            store = catary[indexPath.row]
            
        }
        
        (resultViewController ).sName = store.sName!
        (resultViewController ).descText = store.description!
        (resultViewController ).imageUrl = store.photo as AnyObject
        (resultViewController ).pNumber = store.phoneNumber!
        (resultViewController ).wName = store.website!
        (resultViewController).didFlag = true
        resultViewController.wlati = store.lati!
        resultViewController.wlongi = store.longi!
        resultViewController.emailid = store.email!
        resultViewController.addressfield = store.Address!
        resultViewController.catvalue = store.category!
       self.navigationController?.pushViewController(resultViewController, animated:true)
       }
    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        var coord = locationObj.coordinate
        currentlocation = coord
        lat = coord.latitude
        long = coord.longitude
    }


   
    
    
    //General Methods
    func loadDataFromFirebase(){
        
        
       /* Database.database().reference().child("photographyplaces").observe(.childAdded) { (snapshot) in
            // snapshot is now a dictionary
            let newPost = Post(snapshot: snapshot)
            DispatchQueue.main.async {
                self.posts.insert(newPost, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .top)
            }
        }*/
        
        
        let databaseRef = Database.database().reference().child("photographyplaces")
        databaseRef.keepSynced(true)
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            if snapshot.childrenCount > 0 {
//                if(Pictures.flag == false){
                
                    storeList.removeAll()
                    
                for stores in snapshot.children.allObjects as! [DataSnapshot] {
                        let storeObject = stores.value as? [String: AnyObject]
                        let storeName  = storeObject?["sNams"]
                        let sDescription  = storeObject?["description"]
                        let website = storeObject?["website"]
                        let phoneNumber = storeObject?["phoneNumber"]
                        let photo = storeObject?["photo"]
                        let sLati = storeObject?["lati"]
                        let sLongi = storeObject?["longi"]
                        let email = storeObject?["email"]
                        let address = storeObject?["address"]
                        let cate = storeObject?["category"]
                        let date = storeObject?["date"]
                        let storeData = StoreDataModel(name: storeName as? String, description: sDescription as? String, photo: photo as? String, lati: sLati as? Double, longi: sLongi as? Double, website: website as? String, phoneNumber: phoneNumber as? String,email:email as? String,Address:address as? String,category:cate as? String, date: date as? String)
                        storeList.insert(storeData, at: 0)
                        
//                        storeList.sort(by: { ($0.date!.compare($1.date!) == ComparisonResult.orderedDescending)})
//                        storeList = storeList.sorted(by: {$0.date! > $1.date!})
                        self.removeLoadingScreen()
//                        Pictures.flag = true
                        
                    }
                    
                    self.categotypeselect = globalstr
                    self.cateindex = globalvalue
                    print(self.categotypeselect)
                    self.categotypeselect = EditableCategory[self.cateindex]
                    print(self.categotypeselect)
                    self.CatFillAry(catetype: self.categotypeselect)
                    self.storeTableView.reloadData()
//                }
                
            }else{
                self.removeLoadingScreen()
            }
        }) { (error) in
            
        }
       
        
    }
    
    private func loadData() {
    DispatchQueue.main.async{
    self.storeTableView.separatorStyle = .singleLine
    self.removeLoadingScreen()
    }
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    // Loading
    private func setLoadingScreen() {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.storeTableView.frame.width / 2) - (width / 2)
        let y = (self.storeTableView.frame.height / 2) - (height / 2) - 60
        loadingView.frame = CGRect(x:x, y:y,width: width, height:height)
        
        // Set Loading Text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.textColor = UIColor.black
        self.loadingLabel.frame = CGRect(x:0,y: 0,width: 140,height: 30)
        
        // Set Spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x:0,y: 0,width: 30,height: 30)
        self.spinner.startAnimating()
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        self.storeTableView.addSubview(loadingView)
    }
    
    
    private func removeLoadingScreen() {
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
    }
    
    //No Internet?
    func connectWify(){
        let alert = UIAlertController(title: "Cellular Data is Turned off", message: "Turn on cullar data or use Wi-Fi and make sure your device is connected to the internet.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
         UIAlertAction in}
        let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.cancel) {
        UIAlertAction in
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)}
        alert.addAction(okAction)
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
    }

 
}

// Round values
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    
    
}

