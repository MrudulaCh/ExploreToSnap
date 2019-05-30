
import UIKit
import CoreMotion
import CoreLocation


@objc protocol ARTrackingManagerDelegate : NSObjectProtocol
{
    @objc optional func arTrackingManager(_ trackingManager: ARTrackingManager, didUpdateUserLocation location: CLLocation?)
    @objc optional func arTrackingManager(_ trackingManager: ARTrackingManager, didUpdateReloadLocation location: CLLocation?)
    @objc optional func arTrackingManager(_ trackingManager: ARTrackingManager, didFailToFindLocationAfter elapsedSeconds: TimeInterval)
    
    @objc optional func logText(_ text: String)
}


open class ARTrackingManager: NSObject, CLLocationManagerDelegate
{
 
    open var altitudeSensitive = false
    
  
    open var reloadDistanceFilter: CLLocationDistance!
    open var userDistanceFilter: CLLocationDistance!
        {
        didSet
        {
            self.locationManager.distanceFilter = self.userDistanceFilter
        }
    }
    
 
    fileprivate(set) internal var locationManager: CLLocationManager = CLLocationManager()
    fileprivate(set) internal var tracking = false
    fileprivate(set) internal var userLocation: CLLocation?
    fileprivate(set) internal var heading: Double = 0
    internal weak var delegate: ARTrackingManagerDelegate?
    internal var orientation: CLDeviceOrientation = CLDeviceOrientation.portrait
    {
        didSet
        {
            self.locationManager.headingOrientation = self.orientation
        }
    }
    internal var pitch: Double
    {
        get
        {
            return self.calculatePitch()
        }
    }
    

    fileprivate var motionManager: CMMotionManager = CMMotionManager()
    fileprivate var lastAcceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    fileprivate var reloadLocationPrevious: CLLocation?
    fileprivate var pitchPrevious: Double = 0
    fileprivate var reportLocationTimer: Timer?
    fileprivate var reportLocationDate: TimeInterval?
    fileprivate var debugLocation: CLLocation?
    fileprivate var locationSearchTimer: Timer? = nil
    fileprivate var locationSearchStartTime: TimeInterval? = nil
    
    
    override init()
    {
        super.init()
        self.initialize()
    }
    
    deinit
    {
        self.stopTracking()
    }
    
    fileprivate func initialize()
    {
      
        self.reloadDistanceFilter = 75
        self.userDistanceFilter = 25
        
    
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = CLLocationDistance(self.userDistanceFilter)
        self.locationManager.headingFilter = 1
        self.locationManager.delegate = self
    }
    

    internal func startTracking(notifyLocationFailure: Bool = false)
    {
       
        if CLLocationManager.locationServicesEnabled()
        {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined
            {
                if #available(iOS 8.0, *)
                {
                    self.locationManager.requestWhenInUseAuthorization()
                }
                else
                {
                   
                }
                
            }
        }
        
       
        self.motionManager.startAccelerometerUpdates()
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation()
        
        self.tracking = true
        
       
        self.stopLocationSearchTimer()
        if notifyLocationFailure
        {
            self.startLocationSearchTimer()
            
            
            self.delegate?.arTrackingManager?(self, didFailToFindLocationAfter: 0)
        }
    }
    

    internal func stopTracking()
    {
        self.reloadLocationPrevious = nil
        self.userLocation = nil
        self.reportLocationDate = nil
        
        
        self.motionManager.stopAccelerometerUpdates()
        self.locationManager.stopUpdatingHeading()
        self.locationManager.stopUpdatingLocation()
        
        self.tracking = false
        self.stopLocationSearchTimer()
    }
    

    
    open func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        self.heading = fmod(newHeading.trueHeading, 360.0)
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if locations.count > 0
        {
            let location = locations[0]
            
            
            let age = location.timestamp.timeIntervalSinceNow;
            if age < -30 || location.horizontalAccuracy > 500 || location.horizontalAccuracy < 0
            {
                print("Disregarding location: age: \(age), ha: \(location.horizontalAccuracy)")
                return
            }
            
            self.stopLocationSearchTimer()
      
            self.userLocation = location
            
            
            if self.userLocation != nil && !self.altitudeSensitive
            {
                let location = self.userLocation!
                self.userLocation = CLLocation(coordinate: location.coordinate, altitude: 0, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, timestamp: location.timestamp)
            }
            
            if debugLocation != nil {self.userLocation = debugLocation}
            
            if self.reloadLocationPrevious == nil
            {
                self.reloadLocationPrevious = self.userLocation
            }
     
            let reportIsScheduled = self.reportLocationTimer != nil
            
           
            if self.reportLocationDate == nil
            {
                self.reportLocationToDelegate()
            }
            else if reportIsScheduled
            {
                
            }
                
            else
            {
                self.reportLocationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ARTrackingManager.reportLocationToDelegate), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc internal func reportLocationToDelegate()
    {
        self.delegate?.arTrackingManager?(self, didUpdateUserLocation: self.userLocation)
        
        if self.userLocation != nil && self.reloadLocationPrevious != nil && self.reloadLocationPrevious!.distance(from: self.userLocation!) > self.reloadDistanceFilter!
        {
            self.reloadLocationPrevious = self.userLocation
            self.delegate?.arTrackingManager?(self, didUpdateReloadLocation: self.userLocation)
        }
        
        self.reportLocationTimer?.invalidate()
        self.reportLocationTimer = nil
        self.reportLocationDate = Date().timeIntervalSince1970
    }
    

    internal func calculatePitch() -> Double
    {
        if self.motionManager.accelerometerData == nil
        {
            return 0
        }
        
        let acceleration: CMAcceleration = self.motionManager.accelerometerData!.acceleration
        
     
        let filterFactor: Double = 0.05
        self.lastAcceleration.x = (acceleration.x * filterFactor) + (self.lastAcceleration.x  * (1.0 - filterFactor));
        self.lastAcceleration.y = (acceleration.y * filterFactor) + (self.lastAcceleration.y  * (1.0 - filterFactor));
        self.lastAcceleration.z = (acceleration.z * filterFactor) + (self.lastAcceleration.z  * (1.0 - filterFactor));
        
        let deviceOrientation = self.orientation
        var angle: Double = 0
        
        if deviceOrientation == CLDeviceOrientation.portrait
        {
            angle = atan2(self.lastAcceleration.y, self.lastAcceleration.z)
        }
        else if deviceOrientation == CLDeviceOrientation.portraitUpsideDown
        {
            angle = atan2(-self.lastAcceleration.y, self.lastAcceleration.z)
        }
        else if deviceOrientation == CLDeviceOrientation.landscapeLeft
        {
            angle = atan2(self.lastAcceleration.x, self.lastAcceleration.z)
        }
        else if deviceOrientation == CLDeviceOrientation.landscapeRight
        {
            angle = atan2(-self.lastAcceleration.x, self.lastAcceleration.z)
        }
        
        angle += Double.pi/2
        angle = (self.pitchPrevious + angle) / 2.0
        self.pitchPrevious = angle
        return angle
    }
    
    internal func azimuthFromUserToLocation(_ location: CLLocation) -> Double
    {
        var azimuth: Double = 0
        if self.userLocation == nil
        {
            return 0
        }
        
        let coordinate: CLLocationCoordinate2D = location.coordinate
        let userCoordinate: CLLocationCoordinate2D = self.userLocation!.coordinate
        
     
        let latitudeDistance: Double = userCoordinate.latitude - coordinate.latitude;
        let longitudeDistance: Double = userCoordinate.longitude - coordinate.longitude;
        
        azimuth = radiansToDegrees(atan2(longitudeDistance, (latitudeDistance * Double(LAT_LON_FACTOR))))
        azimuth += 180.0
        
        return azimuth;
    }
    
    internal func startDebugMode(_ location: CLLocation)
    {
        self.debugLocation = location
        self.userLocation = location;
    }
    internal func stopDebugMode(_ location: CLLocation)
    {
        self.debugLocation = nil;
        self.userLocation = nil
    }
    
    
    func startLocationSearchTimer(resetStartTime: Bool = true)
    {
        self.stopLocationSearchTimer()
        
        if resetStartTime
        {
            self.locationSearchStartTime = Date().timeIntervalSince1970
        }
        self.locationSearchTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ARTrackingManager.locationSearchTimerTick), userInfo: nil, repeats: false)
        
    }
    
    func stopLocationSearchTimer(resetStartTime: Bool = true)
    {
        self.locationSearchTimer?.invalidate()
        self.locationSearchTimer = nil
    }
    
    @objc func locationSearchTimerTick()
    {
        guard let locationSearchStartTime = self.locationSearchStartTime else { return }
        let elapsedSeconds = Date().timeIntervalSince1970 - locationSearchStartTime
        
        self.startLocationSearchTimer(resetStartTime: false)
        self.delegate?.arTrackingManager?(self, didFailToFindLocationAfter: elapsedSeconds)
    }
}

