import CoreLocation
import UIKit

let LAT_LON_FACTOR: CGFloat = 1.33975031663
let VERTICAL_SENS: CGFloat = 960
let H_PIXELS_PER_DEGREE: CGFloat = 14
let OVERLAY_VIEW_WIDTH: CGFloat = 360 * H_PIXELS_PER_DEGREE

let MAX_VISIBLE_ANNOTATIONS: Int = 500
let MAX_VERTICAL_LEVELS: Int = 10

internal func radiansToDegrees(_ radians: Double) -> Double
{
    return (radians) * (180.0 / Double.pi)
}

internal func degreesToRadians(_ degrees: Double) -> Double
{
    return (degrees) * (Double.pi / 180.0)
}


internal func normalizeDegree(_ degree: Double) -> Double
{
    var degreeNormalized = fmod(degree, 360)
    if degreeNormalized < 0
    {
        degreeNormalized = 360 + degreeNormalized
    }
    return degreeNormalized
}

internal func deltaAngle(_ angle1: Double, angle2: Double) -> Double
{
    var deltaAngle = angle1 - angle2
    
    if deltaAngle > 180
    {
        deltaAngle -= 360
    }
    else if deltaAngle < -180
    {
        deltaAngle += 360
    }
    return deltaAngle
}


@objc public protocol ARDataSource : NSObjectProtocol
{
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    
    
    @objc optional func ar(_ arViewController: ARViewController, shouldReloadWithLocation location: CLLocation) -> [ARAnnotation]
    
}


