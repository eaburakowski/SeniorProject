/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
View controller for camera interface.
*/

import UIKit
import Photos
import CoreMotion

class CameraViewController: UIViewController {
    
    // Camera and UI properties
    let cameraController = CameraController()
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView! // Displays a preview of the video output generated by the device's cameras.
    @IBOutlet fileprivate var toggleCameraButton: UIButton! // Allows the user to put the camera in photo mode.
    
    // MotionGraphContainer properties
    let motionManager = CMMotionManager() // motion manager object
    let levelingThreshold = 0.1 // this accounts for how level device must actually be (0.00 is perfectly level)
    let updateInterval = 0.25 // measured in seconds
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: UIViewController overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdates()
    }
    
    @IBAction func captureImageButtonPressed(_ sender: UIButton) {
        captureImage()
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
        stopUpdates()
    }
    
    // MARK: MotionGraphContainer implementation
    
    // start updates for leveling data. Captures image when roll, pitch, and yaw meet the established
    // threshold set by the property levelingThreshold
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("ERROR - dev motion not available");
            return
        }
        
        motionManager.deviceMotionUpdateInterval = self.updateInterval
        
        motionManager.startDeviceMotionUpdates(to: .main) { deviceMotion, error in
            guard let deviceMotion = deviceMotion else { return }
            
            let roll = deviceMotion.attitude.roll
            let pitch = deviceMotion.attitude.pitch
            let yaw = deviceMotion.attitude.yaw
            let thresh = self.levelingThreshold
            
            if abs(roll) <= thresh && abs(pitch) <= thresh && abs(yaw) <= thresh {
                print("*** Device is level - capturing image - roll:\(roll) pitch:\(pitch) yaw:\(yaw)")
                self.captureImage()
            } else {
                print("Device not level: roll:\(roll) pitch:\(pitch) yaw:\(yaw)")
            }
        }
    }
    
    // stop the leveling data updates
    func stopUpdates() {
        if !motionManager.isDeviceMotionActive { return }
        motionManager.stopDeviceMotionUpdates()
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

extension CameraViewController {
    override func viewDidLoad() {
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
    }
}
