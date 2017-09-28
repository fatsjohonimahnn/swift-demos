//
//  ViewController.swift
//  CustomCameraPreviewDemo
//
//  Created by Jonathon Fishman on 10/10/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//


import UIKit
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //add cameraView
        cameraView.layer.addSublayer(previewLayer)
        
        cameraSession.startRunning()
    }
    
    
    // set up the preview session
    // Lazy initialization (aka lazy instantiation, or lazy loading) is a technique for delaying the creation of an object or some other expensive process until it’s needed. When programming for iOS, this is helpful to make sure you utilize only the memory you need when you need it.
    lazy var cameraSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetLow
        return session
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        //add cameraView
        preview?.bounds = CGRect(x: 0, y: 0, width: self.cameraView.bounds.width, height: self.cameraView.bounds.height)
        //add cameraView
        preview?.position = CGPoint(x: self.cameraView.bounds.midX, y: self.cameraView.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize /*AspectFill*/
//        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
//        cameraView.layer.addSublayer(previewLayer)
//
//        previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
//        previewLayer.bounds = cameraView.frame
        
        return preview!
    }()
    
    func setupCameraSession() {
        
        let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
                
        do {
            // init of AVCaptureDeviceInput can throw an error, use do-try-catch
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            //1 start the session configuration
            cameraSession.beginConfiguration()
            
            // check if I can add input to the session
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            //2 instantiate the VideoDataOutput
            let dataOutput = AVCaptureVideoDataOutput()
            
            // set the AVCaptureVideoDataOutput properties
            // videoSettings is a dictionary containing compression settings keys
            // (jpeg, H264, …) or the pixel buffer attributes (RGBA32, ARGB32, 422YpCbCr8, …).
            // When apply image processing algorithms to extract information from the image
            // usually need to process only the image luminance.
            // Since the process to convert an RBGA signal to a gray-level signal can be
            // computational expensive,
            //3 ask AVFoundation to perform this job directly in hardware
            // kCVPixelFormatType_420YpCbCr8BiPlanarFullRange pixel format
            // is composed by two 8-bit components: first byte represents luma,
            // second byte represents two chroma components (blue and red).
            // This format is also shortly called YCC: https://en.wikipedia.org/wiki/YCbCr
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            //4 we don't want to block the process, discard late video frames
            dataOutput.alwaysDiscardsLateVideoFrames = true //
            
            //5 check if I can add output to the session and commit configuration
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            // define a GCD serial queue and the delegate object of the data output.
            // The session sends each frame to the delegate object.
            // You can collect each frame implementing
            // let queue = dispatch_queue_create("com.invasivecode.queue", DISPATCH_QUEUE_SERIAL)
            // dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
        
    }
    
    //    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    //            // Here you collect each frame and process it
    //    }
    //
    //    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    //            // Here you can count how many frames are dopped
    //    }
    
    
    
    
}
