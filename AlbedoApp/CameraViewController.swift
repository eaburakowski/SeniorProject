//
//  CameraViewController.swift
//  AlbedoApp
//
//  Created by crt2004 on 12/22/17.
//
//  Adapted from:
//
//  "Building a Full Screen Camera App Using AVFoundation" by Pranjal Satija, AppCoda.com
//  https://www.appcoda.com/avfoundation-swift-guide/
//
//  Apple's Photo Capture Guide
//  https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/PhotoCaptureGuide/index.html
//
//  Apple's CoreMotion Demo App - MotionGraphs
//  https://developer.apple.com/library/content/samplecode/MotionGraphs/Introduction/Intro.html
//

import UIKit
import CoreMotion

class CameraViewController: UIViewController {
    
    // Camera and UI properties
    let cameraController = CameraController()
    @IBOutlet fileprivate var capturePreviewView: UIView! // Displays a preview of the video output generated by the device's cameras.
    
    // MotionGraphContainer properties
    let motionManager = CMMotionManager() // motion manager object
    let levelingThreshold = 5.0 // within how many degrees the device must be in order to count as level
    let updateInterval = 0.25 // measured in seconds
    
    var circularLevel:CircularLevel!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: UIViewController overrides
    override func viewDidLoad() {
        circularLevel = CircularLevel(frame: UIScreen.main.bounds) // create a new Circular Level object
        self.view.addSubview(circularLevel) // add it to the view
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        configureCameraController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startMotionUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopMotionUpdates()
    }
    
    func captureImage() {
        cameraController.captureImage {(image, error) in
            if image == nil {
                print(error ?? "Image capture error")
                return
            }
            
            // this code saves the photo to the device so it has been commented out
            /*try? PHPhotoLibrary.shared().performChangesAndWait {
             PHAssetChangeRequest.creationRequestForAsset(from: image)
             }*/
        }
        flashEffect()
        stopMotionUpdates()
    }
    
    // MARK: MotionGraphContainer implementation
    
    // start updates for leveling data. Captures image when roll, pitch, and yaw meet the established
    // threshold set by the property levelingThreshold
    func startMotionUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("ERROR - dev motion not available");
            return
        }
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 1.0 / 10.0 // 10 Hz
            self.motionManager.startAccelerometerUpdates()
        }
        
        motionManager.deviceMotionUpdateInterval = self.updateInterval
        
        motionManager.startDeviceMotionUpdates(to: .main) { deviceMotion, error in
            guard let deviceMotion = deviceMotion else { return }
            
            let accelX:Double = (self.motionManager.accelerometerData?.acceleration.x)!
            let accelY:Double = (self.motionManager.accelerometerData?.acceleration.y)!
            self.circularLevel.updatePos(accelX: accelX, accelY: accelY)
            
            let roll = deviceMotion.attitude.roll * (180 / Double.pi) // get roll, convert from radians to degrees
            let pitch = deviceMotion.attitude.pitch * (180 / Double.pi) // get pitch, convert from radians to degrees
            let yaw = deviceMotion.attitude.yaw * (180 / Double.pi) // get yaw, convert from radians to degrees
            let thresh = self.levelingThreshold
            
            // ensure that roll, pitch, and yaw are all within the threshold to take a picture
            if abs(roll) <= thresh && abs(pitch) <= thresh && abs(yaw) <= thresh {
                print("*** Device is level - capturing image - roll:\(roll) pitch:\(pitch) yaw:\(yaw)")
                self.captureImage()
            } else {
                //print("Device not level: roll:\(roll) pitch:\(pitch) yaw:\(yaw)")
            }
        }
    }
    
    // stop the leveling data updates
    func stopMotionUpdates() {
        if !motionManager.isDeviceMotionActive { return }
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }
    
    // creates a UI effect where the screen flashes when a photo is taken
    func flashEffect() {
        if let wnd = self.view { // check if view exists
            let v = UIView(frame: wnd.bounds) // programatically create a UIView the size of the screen
            v.backgroundColor = UIColor.white // set flash color
            v.alpha = 1 // set opacity
            wnd.addSubview(v) // add it to the window view
            
            UIView.animate(withDuration: 1, animations: { // handle the animation
                v.alpha = 0.0
            }, completion: {(finished:Bool) in
                v.removeFromSuperview() // remove when finished
            })
        }
    }
    
}
