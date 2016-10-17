//
//  CameraView.swift
//  Snapper
//
//  Created by Abid Amirali on 8/6/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import AVFoundation

var capturedImage: UIImage?
class CameraView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var currCam: AVCaptureDevice?
    var onBackCam: Bool = false
    var didSetUp = false

    @IBOutlet weak var cameraScreenView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.blackColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        previewLayer?.frame = cameraScreenView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

//        var error: NSError?
//        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
//        var input = AVCaptureDeviceInput()
//        do {
//            try input = AVCaptureDeviceInput(device: backCamera)
//
//        } catch let thorwnError as NSError {
//            print(thorwnError.localizedDescription)
//            error = thorwnError
//        }
//
//        if (error == nil && captureSession?.canAddInput(input) == true) {
//            captureSession?.addInput(input)
//            stillImageOutput = AVCaptureStillImageOutput()
//            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
//            if (captureSession?.canAddOutput(stillImageOutput) == true) {
//                captureSession?.addOutput(stillImageOutput)
//                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
//                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
//                cameraScreenView.layer.addSublayer(previewLayer!)
//                captureSession?.startRunning()
//            }
//        }
        getCameraWithPosition(AVCaptureDevicePosition.Front)
        startCaptureSession(currCam!)

    }

    @IBAction func takePhoto(sender: AnyObject) {
        print("taking photo")
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) in
                if (error != nil) {
                    print(error.localizedDescription)
                } else {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider!, nil, true, .RenderingIntentDefault)
                    var image: UIImage!
                    if (self.onBackCam) {
                        image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                        capturedImage = image

                    } else {
                        image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
                        capturedImage = image

                    }
//                    image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
                    print(image)
//                    capturedImage = image
                    // let previewVC = ImagePreviewViewController(nibName: "")
                    isReceviedImage = false
                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                    let previewVC = mainStoryBoard.instantiateViewControllerWithIdentifier("imagePreview")
                    previewVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
                    self.presentViewController(previewVC, animated: true, completion: nil)
                }
            })
        }

    }

    func startCaptureSession(device: AVCaptureDevice) {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        var error: NSError?
        var input = AVCaptureDeviceInput()
        do {
            input = try AVCaptureDeviceInput(device: device)
            print(input)
        } catch let thrownError as NSError {
            print(thrownError.localizedDescription)
            error = thrownError
        }
        print("printing errror", error)
        print(captureSession?.canAddInput(input))
        if (error == nil && captureSession?.canAddInput(input) == true) {
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if (captureSession?.canAddOutput(stillImageOutput) == true) {
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraScreenView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
    }

    @IBAction func flipCamera(sender: AnyObject) {
        print("in flip Cam")
        onBackCam = !onBackCam
        captureSession?.beginConfiguration()
        let currDeviceInput: AVCaptureInput = captureSession?.inputs.first as! AVCaptureInput
        captureSession?.removeInput(currDeviceInput)
        if (onBackCam) {
            getCameraWithPosition(AVCaptureDevicePosition.Back)
        } else {
            getCameraWithPosition(AVCaptureDevicePosition.Front)
        }
        var newInput: AVCaptureDeviceInput?
        var error: NSError?
        do {
            newInput = try AVCaptureDeviceInput(device: currCam)

        } catch let thrownError as NSError {
            print(thrownError.localizedDescription)
            error = thrownError
        }
        if (error == nil && newInput != nil) {
            captureSession?.addInput(newInput)
        }
        captureSession?.commitConfiguration()

    }

    func getCameraWithPosition(position: AVCaptureDevicePosition) {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if (device.position == position) {
                currCam = (device as! AVCaptureDevice)
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        if (segue.identifier == "toImagePreview") {
//            if let previewVC = segue.destinationViewController as? ImagePreviewViewController {
//                previewVC.capturedImageHolder.image = capturedImage!
//            }
//        }

    }

}
