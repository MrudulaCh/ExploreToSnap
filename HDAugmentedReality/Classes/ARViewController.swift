//
//  ARViewController.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
/**
 *      Augmented reality view controller.
 *
 *      How to use:
 *      1. Initialize controller and set datasource(and other properties if needed)
 *      2. Use setAnnotations method to set annotations
 *      3. Present controller modally
 *      4. Implement ARDataSource to provide annotation views in your data source
 *
 *      Properties maxVerticalLevel, maxVisibleAnnotations and maxDistance can be used to optimize performance.
 *      Use trackingManager.userDistanceFilter and trackingManager.reloadDistanceFilter to set how often data is refreshed/reloaded.
 *      All properties are documented.
 *
 *
 *
 */
open class ARViewController: UIViewController, ARTrackingManagerDelegate
{
    /// Data source
    open weak var dataSource: ARDataSource?
    /// Orientation mask for view controller. Make sure orientations are enabled in project settings also.
    open var interfaceOrientationMask: UIInterfaceOrientationMask = UIInterfaceOrientationMask.all
    /**
     *       Defines in how many vertical levels can annotations be stacked. Default value is 5.
     *       Annotations are initially vertically arranged by distance from user, but if two annotations visibly collide with each other,
     *       then farther annotation is put higher, meaning it is moved onto next vertical level. If annotation is moved onto level higher
     *       than this value, it will not be visible.
     *       NOTE: This property greatly impacts performance because collision detection is heavy operation, use it in range 1-10.
     *       Max value is 10.
     */
    open var maxVerticalLevel = 0
        {
        didSet
        {
            if(maxVerticalLevel > MAX_VERTICAL_LEVELS)
            {
                maxVerticalLevel = MAX_VERTICAL_LEVELS
            }
        }
    }
    /// Total maximum number of visible annotation views. Default value is 100. Max value is 500
    open var maxVisibleAnnotations = 0
        {
        didSet
        {
            if(maxVisibleAnnotations > MAX_VISIBLE_ANNOTATIONS)
            {
                maxVisibleAnnotations = MAX_VISIBLE_ANNOTATIONS
            }
        }
    }
    /**
     *       Maximum distance(in meters) for annotation to be shown.
     *       If the distance from annotation to user's location is greater than this value, than that annotation will not be shown.
     *       Also, this property, in conjunction with maxVerticalLevel, defines how are annotations aligned vertically. Meaning
     *       annotation that are closer to this value will be higher.
     *       Default value is 0 meters, which means that distances of annotations don't affect their visiblity.
     */
    open var maxDistance: Double = 0
    /// Class for managing geographical calculations. Use it to set properties like reloadDistanceFilter, userDistanceFilter and altitudeSensitive
    fileprivate(set) open var trackingManager: ARTrackingManager = ARTrackingManager()
 
    open var closeButtonImage: UIImage?
        {
        didSet
        {
            closeButton?.setImage(self.closeButtonImage, for: UIControlState())
        }
    }
   
    @available(*, deprecated, message: "Will be removed in next version, use uiOptions.debugEnabled.")
    open var debugEnabled = false
        {
        didSet
        {
            self.uiOptions.debugEnabled = debugEnabled
        }
    }
 
    open var headingSmoothingFactor: Double = 1
 
    open var onDidFailToFindLocation: ((_ timeElapsed: TimeInterval, _ acquiredLocationBefore: Bool) -> Void)?

    open var uiOptions = UiOptions()
    
   
    fileprivate var initialized: Bool = false
    fileprivate var cameraSession: AVCaptureSession = AVCaptureSession()
    fileprivate var overlayView: OverlayView = OverlayView()
    fileprivate var displayTimer: CADisplayLink?
    fileprivate var cameraLayer: AVCaptureVideoPreviewLayer?    // Will be
    fileprivate var annotationViews: [ARAnnotationView] = []
    fileprivate var previosRegion: Int = 0
    fileprivate var degreesPerScreen: CGFloat = 0
    fileprivate var shouldReloadAnnotations: Bool = false
    fileprivate var reloadInProgress = false
    fileprivate var reloadToken: Int = 0
    fileprivate var reloadLock = NSRecursiveLock()
    fileprivate var annotations: [ARAnnotation] = []
    fileprivate var activeAnnotations: [ARAnnotation] = []
    fileprivate var closeButton: UIButton?
    fileprivate var currentHeading: Double = 0
    fileprivate var lastLocation: CLLocation?
    
    fileprivate var debugLabel: UILabel?
    fileprivate var debugMapButton: UIButton?
    fileprivate var didLayoutSubviews: Bool = false
    var gooleadsenable = true
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        self.initializeInternal()
        
    }
    
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.initializeInternal()
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeInternal()
        
    }
    
    internal func initializeInternal()
    {
        if self.initialized
        {
            return
        }
        self.initialized = true;
      
        self.trackingManager.delegate = self
        self.maxVerticalLevel = 5
        self.maxVisibleAnnotations = 100
        self.maxDistance = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(ARViewController.locationNotification(_:)), name: NSNotification.Name(rawValue: "kNotificationLocationSet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ARViewController.appWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ARViewController.appDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        self.initialize()
    }
    
  
    internal func initialize()
    {
        print("initialize")
        
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
        self.stopCamera()
    }
 
    open override func viewWillAppear(_ animated: Bool)
    {
        
        super.viewWillAppear(animated)
        onViewWillAppear()  // Doing like this to prevent subclassing problems
        
       // load_Interstitial()
    }
    
    open override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        onViewDidAppear()   // Doing like this to prevent subclassing problems
    }
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        onViewDidDisappear()    // Doing like this to prevent subclassing problems
    }
    
    /*open override func viewWillDisappear(_ animated: Bool) {
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9209439256262742/4083972752")
    }*/
    
    open override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        onViewDidLayoutSubviews()
    }
    
    fileprivate func onViewWillAppear()
    {
        // Camera layer if not added
        if self.cameraLayer?.superlayer == nil { self.loadCamera() }
        
        // Overlay
        if self.overlayView.superview == nil { self.loadOverlay() }
        
        // Set orientation and start camera
        self.setOrientation(UIApplication.shared.statusBarOrientation)
        self.layoutUi()
        self.startCamera(notifyLocationFailure: true)
    }
    
    fileprivate func onViewDidAppear()
    {
        
    }
    
    fileprivate func onViewDidDisappear()
    {
        stopCamera()
    }
    
    
    
    @objc internal func closeButtonTap()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    open override var prefersStatusBarHidden : Bool
    {
        return true
    }
    
    fileprivate func onViewDidLayoutSubviews()
    {
        // Executed only first time when everything is layouted
        if !self.didLayoutSubviews
        {
            self.didLayoutSubviews = true
            
            // Close button
            if self.uiOptions.closeButtonEnabled { self.addCloseButton() }
            
            // Debug
            if self.uiOptions.debugEnabled { self.addDebugUi() }
            
            // Layout
            self.layoutUi()
            
            self.view.layoutIfNeeded()
        }
        
        self.degreesPerScreen = (self.view.bounds.size.width / OVERLAY_VIEW_WIDTH) * 360.0
        
        
    }
    @objc internal func appDidEnterBackground(_ notification: Notification)
    {
        if(self.view.window != nil)
        {
            self.trackingManager.stopTracking()
        }
    }
    @objc internal func appWillEnterForeground(_ notification: Notification)
    {
        if(self.view.window != nil)
        {
            
            for annotation in self.annotations
            {
                annotation.annotationView = nil
            }
            
            for annotationView in self.annotationViews
            {
                annotationView.removeFromSuperview()
            }
            
            self.annotationViews = []
            self.shouldReloadAnnotations = true;
            self.trackingManager.stopTracking()
            // Start tracking
            self.trackingManager.startTracking(notifyLocationFailure: true)
        }
    }

    open func setAnnotations(_ annotations: [ARAnnotation])
    {
        var validAnnotations: [ARAnnotation] = []
        // Don't use annotations without valid location
        for annotation in annotations
        {
            if annotation.location != nil && CLLocationCoordinate2DIsValid(annotation.location!.coordinate)
            {
                validAnnotations.append(annotation)
            }
        }
        self.annotations = validAnnotations
        self.reloadAnnotations()
    }
    
    open func getAnnotations() -> [ARAnnotation]
    {
        return self.annotations
    }
    

    open func reloadAnnotations()
    {
        if self.trackingManager.userLocation != nil && self.isViewLoaded
        {
            self.shouldReloadAnnotations = false
            self.reload(calculateDistanceAndAzimuth: true, calculateVerticalLevels: true, createAnnotationViews: true)
        }
        else
        {
            self.shouldReloadAnnotations = true
        }
    }
    

    fileprivate func createAnnotationViews()
    {
        var annotationViews: [ARAnnotationView] = []
        let activeAnnotations = self.activeAnnotations
        for annotationView in self.annotationViews
        {
            annotationView.removeFromSuperview()
        }
        
      
        for annotation in self.annotations
        {
            if(!annotation.active)
            {
                annotation.annotationView = nil
            }
        }
     
        for annotation in activeAnnotations
        {
            
            if annotation.location == nil || !CLLocationCoordinate2DIsValid(annotation.location!.coordinate)
            {
                continue
            }
            
            var annotationView: ARAnnotationView? = nil
            if annotation.annotationView != nil
            {
                annotationView = annotation.annotationView
            }
            else
            {
                annotationView = self.dataSource?.ar(self, viewForAnnotation: annotation)
            }
            
            if annotationView != nil
            {
                annotation.annotationView = annotationView
                annotationView!.annotation = annotation
                annotationViews.append(annotationView!)
            }
        }
        
        self.annotationViews = annotationViews
    }
    
    
    fileprivate func calculateDistanceAndAzimuthForAnnotations(sort: Bool, onlyForActiveAnnotations: Bool)
    {
        if self.trackingManager.userLocation == nil
        {
            return
        }
        
        let userLocation = self.trackingManager.userLocation!
        let array = (onlyForActiveAnnotations && self.activeAnnotations.count > 0) ? self.activeAnnotations : self.annotations
        
        for annotation in array
        {
            if annotation.location == nil
            {
                annotation.distanceFromUser = 0
                annotation.azimuth = 0
                continue
            }
            
        
            annotation.distanceFromUser = annotation.location!.distance(from: userLocation)
         
            let azimuth = self.trackingManager.azimuthFromUserToLocation(annotation.location!)
            annotation.azimuth = azimuth
        }
        
        if sort
        {
            self.annotations = self.annotations.sorted { $0.distanceFromUser < $1.distanceFromUser }
            
            
//            let sortedArray: NSMutableArray = NSMutableArray(array: self.annotations)
//            print(sortedArray)
//            let sortDesc = NSSortDescriptor(key: "distanceFromUser", ascending: true)
//            print(sortDesc)
//            sortedArray.sortedArray(using: [sortDesc])
//            self.annotations = sortedArray as [AnyObject] as! [ARAnnotation]
        }
    }
    
    fileprivate func updateAnnotationsForCurrentHeading()
    {
     
        let degreesDelta = Double(degreesPerScreen)
        
        for annotationView in self.annotationViews
        {
            if annotationView.annotation != nil
            {
                let delta = deltaAngle(currentHeading, angle2: annotationView.annotation!.azimuth)
                
                if fabs(delta) < degreesDelta && annotationView.annotation!.verticalLevel <= self.maxVerticalLevel
                {
                    if annotationView.superview == nil
                    {
                        self.overlayView.addSubview(annotationView)
                    }
                }
                else
                {
                    if annotationView.superview != nil
                    {
                        annotationView.removeFromSuperview()
                    }
                }
            }
        }

        let threshold: Double = 40
        var currentRegion: Int = 0
        
        if currentHeading < threshold
        {
            currentRegion = 1
        }
        else if currentHeading > (360 - threshold)
        {
            currentRegion = -1
        }
        
        if currentRegion != self.previosRegion
        {
            if self.annotationViews.count > 0
            {
           
                self.reload(calculateDistanceAndAzimuth: false, calculateVerticalLevels: false, createAnnotationViews: false)
            }
        }
        
        self.previosRegion = currentRegion
    }
    
    
    
    fileprivate func positionAnnotationViews()
    {
        for annotationView in self.annotationViews
        {
            let x = self.xPositionForAnnotationView(annotationView, heading: self.trackingManager.heading)
            let y = self.yPositionForAnnotationView(annotationView)
            
            annotationView.frame = CGRect(x: x, y: y, width: annotationView.bounds.size.width, height: annotationView.bounds.size.height)
        }
    }
    
    fileprivate func xPositionForAnnotationView(_ annotationView: ARAnnotationView, heading: Double) -> CGFloat
    {
        if annotationView.annotation == nil { return 0 }
        let annotation = annotationView.annotation!
        
       
        let azimuth = annotation.azimuth
     
        var xPos: CGFloat = CGFloat(azimuth) * H_PIXELS_PER_DEGREE - annotationView.bounds.size.width / 2.0
        

        let threshold: Double = 40
        if heading < threshold
        {
            if annotation.azimuth > (360 - threshold)
            {
                xPos = -(OVERLAY_VIEW_WIDTH - xPos);
            }
        }
        else if heading > (360 - threshold)
        {
            if annotation.azimuth < threshold
            {
                xPos = OVERLAY_VIEW_WIDTH + xPos;
            }
        }
        
        return xPos
    }
    
    fileprivate func yPositionForAnnotationView(_ annotationView: ARAnnotationView) -> CGFloat
    {
        if annotationView.annotation == nil { return 0 }
        let annotation = annotationView.annotation!
        
        let annotationViewHeight: CGFloat = annotationView.bounds.size.height
        var yPos: CGFloat = (self.view.bounds.size.height * 0.65) - (annotationViewHeight * CGFloat(annotation.verticalLevel))
        yPos -= CGFloat( powf(Float(annotation.verticalLevel), 2) * 4)
        return yPos
    }
    
    fileprivate func calculateVerticalLevels()
    {

        let dictionary: NSMutableDictionary = NSMutableDictionary()
        
  
        for level in stride(from: 0, to: self.maxVerticalLevel + 1, by: 1)
        {
            let array = NSMutableArray()
            dictionary[Int(level)] = array
        }
 
        for i in stride(from: 0, to: self.activeAnnotations.count, by: 1)
        {
            let annotation = self.activeAnnotations[i] as ARAnnotation
            if annotation.verticalLevel <= self.maxVerticalLevel
            {
                let array = dictionary[annotation.verticalLevel] as? NSMutableArray
                array?.add(annotation)
            }
        }

        var annotationWidthInDegrees: Double = 0
        if let annotationWidth = self.getAnyAnnotationView()?.bounds.size.width
        {
            annotationWidthInDegrees = Double(annotationWidth / H_PIXELS_PER_DEGREE)
        }
        if annotationWidthInDegrees < 5 { annotationWidthInDegrees = 5 }
        
    
        var minVerticalLevel: Int = Int.max
        for level in stride(from: 0, to: self.maxVerticalLevel + 1, by: 1)
        {
            let annotationsForCurrentLevel = dictionary[(level as Int)] as! NSMutableArray
            let annotationsForNextLevel = dictionary[((level + 1) as Int)] as? NSMutableArray
            
            for i in stride(from: 0, to: annotationsForCurrentLevel.count, by: 1)
            {
                let annotation1 = annotationsForCurrentLevel[i] as! ARAnnotation
                if annotation1.verticalLevel != level { continue }
                
                for j in stride(from: (i+1), to: annotationsForCurrentLevel.count, by: 1)
                {
                    let annotation2 = annotationsForCurrentLevel[j] as! ARAnnotation
                    if annotation1 == annotation2 || annotation2.verticalLevel != level
                    {
                        continue
                    }
                 
                    var deltaAzimuth = deltaAngle(annotation1.azimuth, angle2: annotation2.azimuth)
                    deltaAzimuth = fabs(deltaAzimuth)
                    
                    if deltaAzimuth > annotationWidthInDegrees
                    {
                        
                        continue
                    }
                    
                    if annotation1.distanceFromUser > annotation2.distanceFromUser
                    {
                        annotation1.verticalLevel += 1
                        if annotationsForNextLevel != nil
                        {
                            annotationsForNextLevel?.add(annotation1)
                        }
                       
                        break
                    }
                      
                    else
                    {
                        annotation2.verticalLevel += 1
                        if annotationsForNextLevel != nil
                        {
                            annotationsForNextLevel?.add(annotation2)
                        }
                    }
                }
                
                if annotation1.verticalLevel == level
                {
                    minVerticalLevel = Int(fmin(Float(minVerticalLevel), Float(annotation1.verticalLevel)))
                }
            }
        }
        
 
        for annotation in self.activeAnnotations
        {
            if annotation.verticalLevel <= self.maxVerticalLevel
            {
                annotation.verticalLevel -= minVerticalLevel
            }
        }
    }

    fileprivate func setInitialVerticalLevels()
    {
        if self.activeAnnotations.count == 0
        {
            return
        }
        

        let activeAnnotations = self.activeAnnotations
        var minDistance = activeAnnotations.first!.distanceFromUser
        var maxDistance = activeAnnotations.last!.distanceFromUser
        if self.maxDistance > 0
        {
            minDistance = 0;
            maxDistance = self.maxDistance;
        }
        var deltaDistance = maxDistance - minDistance
        let maxLevel: Double = Double(self.maxVerticalLevel)
        
    
        for annotation in self.annotations
        {
            annotation.verticalLevel = self.maxVerticalLevel + 1
        }
        if deltaDistance <= 0 { deltaDistance = 1 }
        
        
        for annotation in activeAnnotations
        {
            let verticalLevel = Int(((annotation.distanceFromUser - minDistance) / deltaDistance) * maxLevel)
            annotation.verticalLevel = verticalLevel
        }
    }
    
    fileprivate func getAnyAnnotationView() -> ARAnnotationView?
    {
        var anyAnnotationView: ARAnnotationView? = nil
        
        if let annotationView = self.annotationViews.first
        {
            anyAnnotationView = annotationView
        }
        else if let annotation = self.activeAnnotations.first
        {
            anyAnnotationView = self.dataSource?.ar(self, viewForAnnotation: annotation)
        }
        
        return anyAnnotationView
    }

    fileprivate func reload(calculateDistanceAndAzimuth: Bool, calculateVerticalLevels: Bool, createAnnotationViews: Bool)
    {
        //NSLog("==========")
        if calculateDistanceAndAzimuth
        {
            
            let sort = createAnnotationViews
           
            let onlyForActiveAnnotations = !createAnnotationViews
            self.calculateDistanceAndAzimuthForAnnotations(sort: sort, onlyForActiveAnnotations: onlyForActiveAnnotations)
            
            
        }
        
        if(createAnnotationViews)
        {
            self.activeAnnotations = filteredAnnotations(nil, maxVisibleAnnotations: self.maxVisibleAnnotations, maxDistance: self.maxDistance)
            self.setInitialVerticalLevels()
        }
        
        if calculateVerticalLevels
        {
            self.calculateVerticalLevels()
        }
        
        if createAnnotationViews
        {
            self.createAnnotationViews()
        }
        
        self.positionAnnotationViews()

        if calculateDistanceAndAzimuth
        {
            for annotationView in self.annotationViews
            {
                annotationView.bindUi()
            }
        }
        
    }

    fileprivate func filteredAnnotations(_ maxVerticalLevel: Int?, maxVisibleAnnotations: Int?, maxDistance: Double?) -> [ARAnnotation]
    {
        let nsAnnotations: NSMutableArray = NSMutableArray(array: self.annotations)
        
        var filteredAnnotations: [ARAnnotation] = []
        var count = 0
        
        let checkMaxVisibleAnnotations = maxVisibleAnnotations != nil
        let checkMaxVerticalLevel = maxVerticalLevel != nil
        let checkMaxDistance = maxDistance != nil
        
        for nsAnnotation in nsAnnotations
        {
            let annotation = nsAnnotation as! ARAnnotation
            
          
            if(checkMaxVisibleAnnotations && count >= maxVisibleAnnotations!)
            {
                annotation.active = false
                continue
            }
            
      
            if (!checkMaxVerticalLevel || annotation.verticalLevel <= maxVerticalLevel!) &&
                (!checkMaxDistance || self.maxDistance == 0 || annotation.distanceFromUser <= maxDistance!)
            {
                filteredAnnotations.append(annotation)
                annotation.active = true
                count += 1;
            }
            else
            {
                annotation.active = false
            }
        }
        return filteredAnnotations
    }
    

    @objc internal func displayTimerTick()
    {
        let filterFactor: Double = headingSmoothingFactor
        let newHeading = self.trackingManager.heading
        
 
        if(self.headingSmoothingFactor == 1 || fabs(currentHeading - self.trackingManager.heading) > 50)
        {
            currentHeading = self.trackingManager.heading
        }
        else
        {
         
            currentHeading = (newHeading * filterFactor) + (currentHeading  * (1.0 - filterFactor))
        }
        
        self.overlayView.frame = self.overlayFrame()
        self.updateAnnotationsForCurrentHeading()
        
        logText("Heading: \(self.trackingManager.heading)")
    }
    
    internal func arTrackingManager(_ trackingManager: ARTrackingManager, didUpdateUserLocation: CLLocation?)
    {
        if let location = trackingManager.userLocation
        {
            self.lastLocation = location
        }
        

        if self.shouldReloadAnnotations
        {
            self.reloadAnnotations()
        }
        
        else if self.activeAnnotations.count > 0
        {
            self.reload(calculateDistanceAndAzimuth: true, calculateVerticalLevels: true, createAnnotationViews: false)
        }
        

        if(self.uiOptions.debugEnabled)
        {
            let view = UIView()
            view.frame = CGRect(x: self.view.bounds.size.width - 80, y: 10, width: 30, height: 30)
            view.backgroundColor = UIColor.red
            self.view.addSubview(view)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
            {
                view.removeFromSuperview()
            }
        }
    }
    
    internal func arTrackingManager(_ trackingManager: ARTrackingManager, didUpdateReloadLocation: CLLocation?)
    {
        // Manual reload?
        if didUpdateReloadLocation != nil && self.dataSource != nil && self.dataSource!.responds(to: #selector(ARDataSource.ar(_:shouldReloadWithLocation:)))
        {
            let annotations = self.dataSource?.ar?(self, shouldReloadWithLocation: didUpdateReloadLocation!)
            if let annotations = annotations
            {
                setAnnotations(annotations);
            }
        }
        else
        {
            self.reloadAnnotations()
        }
        
        // Debug view, indicating that reload was done
        if(self.uiOptions.debugEnabled)
        {
            let view = UIView()
            view.frame = CGRect(x: self.view.bounds.size.width - 80, y: 10, width: 30, height: 30)
            view.backgroundColor = UIColor.blue
            self.view.addSubview(view)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
            {
                view.removeFromSuperview()
            }
        }
    }
    internal func arTrackingManager(_ trackingManager: ARTrackingManager, didFailToFindLocationAfter elapsedSeconds: TimeInterval)
    {
        self.onDidFailToFindLocation?(elapsedSeconds, self.lastLocation != nil)
    }
    
    internal func logText(_ text: String)
    {
        self.debugLabel?.text = text
    }
    

    fileprivate func loadCamera()
    {
        self.cameraLayer?.removeFromSuperlayer()
        self.cameraLayer = nil
        
        //===== Video device/video input
        let captureSessionResult = ARViewController.createCaptureSession()
        guard captureSessionResult.error == nil, let session = captureSessionResult.session else
        {
            print("HDAugmentedReality: Cannot create capture session, use createCaptureSession method to check if device is capable for augmented reality.")
            return
        }
        
        self.cameraSession = session
        
        //===== View preview layer
        if let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession) as? AVCaptureVideoPreviewLayer
        {
            cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.insertSublayer(cameraLayer, at: 0)
            self.cameraLayer = cameraLayer
        }
    }

    open class func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?)
    {
        var error: NSError?
        var captureSession: AVCaptureSession?
        var backVideoDevice: AVCaptureDevice?
        
        
       
       // let captureDevices = AVCaptureDevice.devices(for: mediaType)
        
        //let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: .video, position: .front).devices
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice]
        
        // Get back video device
        if let videoDevices = videoDevices
        {
            for captureDevice in videoDevices
            {
                if (captureDevice as AnyObject).position == AVCaptureDevice.Position.back
                {
                    backVideoDevice = captureDevice as? AVCaptureDevice
                    break
                }
            }
        }
        
        if backVideoDevice != nil
        {
            var videoInput: AVCaptureDeviceInput!
            do {
                videoInput = try AVCaptureDeviceInput(device: backVideoDevice!)
            } catch let error1 as NSError {
                error = error1
                videoInput = nil
            }
            if error == nil
            {
                captureSession = AVCaptureSession()
                
                if captureSession!.canAddInput(videoInput)
                {
                    captureSession!.addInput(videoInput)
                }
                else
                {
                    error = NSError(domain: "HDAugmentedReality", code: 10002, userInfo: ["description": "Error adding video input."])
                }
            }
            else
            {
                error = NSError(domain: "HDAugmentedReality", code: 10001, userInfo: ["description": "Error creating capture device input."])
            }
        }
        else
        {
            error = NSError(domain: "HDAugmentedReality", code: 10000, userInfo: ["description": "Back video device not found."])
        }
        
        return (session: captureSession, error: error)
    }
    
    fileprivate func startCamera(notifyLocationFailure: Bool)
    {
        self.cameraSession.startRunning()
        self.trackingManager.startTracking(notifyLocationFailure: notifyLocationFailure)
        self.displayTimer = CADisplayLink(target: self, selector: #selector(ARViewController.displayTimerTick))
        self.displayTimer?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    fileprivate func stopCamera()
    {
        self.cameraSession.stopRunning()
        self.trackingManager.stopTracking()
        self.displayTimer?.invalidate()
        self.displayTimer = nil
    }
    
    fileprivate func loadOverlay()
    {
        self.overlayView.removeFromSuperview()
        self.overlayView = OverlayView()
        self.view.addSubview(self.overlayView)
 
    }
    
    fileprivate func overlayFrame() -> CGRect
    {
        let x: CGFloat = self.view.bounds.size.width / 2 - (CGFloat(currentHeading) * H_PIXELS_PER_DEGREE)
        let y: CGFloat = (CGFloat(self.trackingManager.pitch) * VERTICAL_SENS) + 60.0
        
        let newFrame = CGRect(x: x, y: y, width: OVERLAY_VIEW_WIDTH, height: self.view.bounds.size.height)
        return newFrame
    }
    
    fileprivate func layoutUi()
    {
        self.cameraLayer?.frame = self.view.bounds
        self.overlayView.frame = self.overlayFrame()
    }

    open override var shouldAutorotate : Bool
    {
        return true
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask(rawValue: self.interfaceOrientationMask.rawValue)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition:
            {
                (coordinatorContext) in
                
                self.setOrientation(UIApplication.shared.statusBarOrientation)
        })
        {
            [unowned self] (coordinatorContext) in
            
            self.layoutAndReloadOnOrientationChange()
        }
    }
    
    internal func layoutAndReloadOnOrientationChange()
    {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.layoutUi()
        self.reload(calculateDistanceAndAzimuth: false, calculateVerticalLevels: false, createAnnotationViews: false)
        CATransaction.commit()
    }
    
    fileprivate func setOrientation(_ orientation: UIInterfaceOrientation)
    {
        if self.cameraLayer?.connection?.isVideoOrientationSupported != nil
        {
            if let videoOrientation = AVCaptureVideoOrientation(rawValue: Int(orientation.rawValue))
            {
                self.cameraLayer?.connection?.videoOrientation = videoOrientation
            }
        }
        
        if let deviceOrientation = CLDeviceOrientation(rawValue: Int32(orientation.rawValue))
        {
            self.trackingManager.orientation = deviceOrientation
        }
    }
    

    func addCloseButton()
    {
        self.closeButton?.removeFromSuperview()
        
        if self.closeButtonImage == nil
        {
            let bundle = Bundle(for: ARViewController.self)
            let path = bundle.path(forResource: "hdar_close", ofType: "png")
            if let path = path
            {
                self.closeButtonImage = UIImage(contentsOfFile: path)
            }
        }
      
        let closeButton: UIButton = UIButton(type: UIButtonType.custom)
        closeButton.setImage(closeButtonImage, for: UIControlState());
        closeButton.frame = CGRect(x: self.view.bounds.size.width - 50, y: 40,width: 40,height: 40)
        closeButton.addTarget(self, action: #selector(ARViewController.closeButtonTap), for: UIControlEvents.touchUpInside)
        closeButton.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleBottomMargin]
        self.view.addSubview(closeButton)
        self.closeButton = closeButton
    }

    @objc internal func locationNotification(_ sender: Notification)
    {
        if let location = sender.userInfo?["location"] as? CLLocation
        {
            self.trackingManager.startDebugMode(location)
            self.reloadAnnotations()
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    @objc internal func debugButtonTap()
    {
        let bundle = Bundle(for: DebugMapViewController.self)
        let mapViewController = DebugMapViewController(nibName: "DebugMapViewController", bundle: bundle)
        self.present(mapViewController, animated: true, completion: nil)
        mapViewController.addAnnotations(self.annotations)
    }
    
    func addDebugUi()
    {
        self.debugLabel?.removeFromSuperview()
        self.debugMapButton?.removeFromSuperview()
        
        let debugLabel = UILabel()
        debugLabel.backgroundColor = UIColor.white
        debugLabel.textColor = UIColor.black
        debugLabel.font = UIFont.boldSystemFont(ofSize: 10)
        debugLabel.frame = CGRect(x: 5, y: self.view.bounds.size.height - 50, width: self.view.bounds.size.width - 10, height: 45)
        debugLabel.numberOfLines = 0
        debugLabel.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        debugLabel.textAlignment = NSTextAlignment.left
        view.addSubview(debugLabel)
        self.debugLabel = debugLabel
        
        let debugMapButton: UIButton = UIButton(type: UIButtonType.custom)
        debugMapButton.frame = CGRect(x: 5,y: 5,width: 40,height: 40);
        debugMapButton.addTarget(self, action: #selector(ARViewController.debugButtonTap), for: UIControlEvents.touchUpInside)
        debugMapButton.setTitle("map", for: UIControlState())
        debugMapButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        debugMapButton.setTitleColor(UIColor.black, for: UIControlState())
        self.view.addSubview(debugMapButton)
        self.debugMapButton = debugMapButton
    }

    fileprivate class OverlayView: UIView
    {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
        {
            if(!self.clipsToBounds && !self.isHidden)
            {
                for subview in self.subviews.reversed()
                {
                    let subPoint = subview.convert(point, from: self)
                    if let result:UIView = subview.hitTest(subPoint, with:event)
                    {
                        return result;
                    }
                }
            }
            return nil
        }
    }

    public struct UiOptions
    {
  
        public var debugEnabled = false
        public var closeButtonEnabled = true
    }
}

















