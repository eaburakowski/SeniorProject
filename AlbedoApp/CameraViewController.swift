/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
View controller for camera interface.
*/

import UIKit
import Photos

class CameraViewController: UIViewController {
    let cameraController = CameraController()
    
    @IBOutlet fileprivate var captureButton: UIButton!
    
    ///Displays a preview of the video output generated by the device's cameras.
    @IBOutlet fileprivate var capturePreviewView: UIView!
    
    ///Allows the user to put the camera in photo mode.
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            // this code saves the photo to the device so it has been commented out
            /*try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }*/
        }
        flashEffect()
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
