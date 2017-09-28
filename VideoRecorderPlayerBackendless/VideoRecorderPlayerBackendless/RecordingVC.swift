//
//  RecordingVC.swift
//  VideoRecorderPlayerBackendless
//
//  Created by Jonathon Fishman on 10/8/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit

class RecordingVC: UIViewController, UITextFieldDelegate, IMediaStreamerDelegate {
    
    @IBOutlet weak var videoModeOptions: UISegmentedControl!
    @IBOutlet weak var recordingTypeOptions: UISegmentedControl!
    @IBOutlet weak var qualityOptions: UISegmentedControl!
    @IBOutlet weak var streamNameTextField: UITextField!
    @IBOutlet weak var preView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var swapCameraButton: UIButton!
    @IBOutlet weak var playbackView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var isLive = false
    
    //options.resolution = RESOLUTION_LOW    // 144x192px (landscape) & 192x144px (portrait)
    //options.resolution = RESOLUTION_CIF    // 288x352px (landscape) & 352x288px (portrait)
    //options.resolution = RESOLUTION_MEDIUM // 360x480px (landscape) & 480x368px (portrait)
    //options.resolution = RESOLUTION_VGA    // 480x640px (landscape) & 640x480px (portrait)
    //options.resolution = RESOLUTION_HIGH   // 720x1280px (landscape) & 1280x720px (portrait)
    var resolution: MPVideoResolution = RESOLUTION_CIF
    
    var backendless = Backendless.sharedInstance()
    var publisher: MediaPublisher?
    var player: MediaPlayer?
    let VIDEO_TUBE = "Default"
    
    enum VideoMode {
        
        case recordOnly
        case liveStream
        case liveAndRecord
    }
    
    var currentVideoMode: VideoMode = .recordOnly
    
    enum PublishOptions {
        
        case videoPlusAudio
        case videoOnly
        case audioOnly
    }
    
    var currentPublishOptions: PublishOptions = .videoPlusAudio
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add target to textField to know when it changes
        streamNameTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        
        recordButton.isEnabled = false
        playButton.isEnabled = false
        swapCameraButton.isEnabled = false
        stopButton.isEnabled = false
        
        // Set the BE MediaPlayer resolution options
        qualityOptions.selectedSegmentIndex = Int(resolution.rawValue)
        
//TODO: Start microphone with camera OR ask for just ask for permission 
        // start camera upon initialization
        setupCameraSession()
    }
    
    // added to setup camera preview layer
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        preView.layer.addSublayer(previewLayer)
        
        cameraSession.startRunning()
    }
    
    // set up the preview session
    lazy var cameraSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetLow
        return session
    }()
    
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        //add cameraView
        preview?.bounds = CGRect(x: 0, y: 0, width: self.preView.bounds.width, height: self.preView.bounds.height)
        //add cameraView
        preview?.position = CGPoint(x: self.preView.bounds.midX, y: self.preView.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        
        return preview!
    }()
    
    func setupCameraSession() {
        
        let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true //
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Selector for adding events to changes in textField
    func textFieldChanged(textField: UITextField) {
        
        if streamNameTextField.text == "" {
            
            playButton.isEnabled = false
            stopButton.isEnabled = false
            recordButton.isEnabled = false
            swapCameraButton.isEnabled = false
            
        } else {
            
            switch currentVideoMode {
            
            case .recordOnly:
                
                playButton.isEnabled = true
                recordButton.isEnabled = true
                
            case .liveStream:
                
                playButton.isEnabled = false
                recordButton.isEnabled = true

            case .liveAndRecord:
                
                playButton.isEnabled = false
                recordButton.isEnabled = true
            }
        }
    }
    
    // MARK: Actions

    @IBAction func onVideoOptionsChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            currentVideoMode = .recordOnly
        } else if sender.selectedSegmentIndex == 1 {
            currentVideoMode = .liveStream
        } else if sender.selectedSegmentIndex == 2 {
            currentVideoMode = .liveAndRecord
        }
        
        refreshUI()
    }
    
    func refreshUI() {
        
        streamNameTextField.isEnabled = true
        videoModeOptions.isEnabled = true
        recordingTypeOptions.isEnabled = true
        qualityOptions.isEnabled = true
        
        switch currentVideoMode {
            
        case .recordOnly:
            
            isLive = false
            
            if streamNameTextField.text == "" {
                recordButton.isEnabled = false
                playButton.isEnabled = false
            } else {
                recordButton.isEnabled = true
                playButton.isEnabled = true
            }
            
            swapCameraButton.isEnabled = false
            stopButton.isEnabled = false
            
            preView.isHidden = false
            playbackView.isHidden = true
            
            recordButton.setTitle("Record", for: .disabled)
            recordButton.setTitle("Record", for: .normal)
            
        case .liveStream:
            
            isLive = true
            
            if streamNameTextField.text == "" {
                recordButton.isEnabled = false
            } else {
                recordButton.isEnabled = true
            }
            
            playButton.isEnabled = false
            swapCameraButton.isEnabled = false
            stopButton.isEnabled = false
            
            preView.isHidden = false
            playbackView.isHidden = true
            
            recordButton.setTitle("Stream", for: .disabled)
            recordButton.setTitle("Stream", for: .normal)
            
        case .liveAndRecord:
            
            isLive = true
            
            recordButton.isEnabled = true
            
            if streamNameTextField.text == "" {
                playButton.isEnabled = false
            } else {
                playButton.isEnabled = true
            }
            
            swapCameraButton.isEnabled = false
            stopButton.isEnabled = false
            
            preView.isHidden = true
            playbackView.isHidden = false
            
            recordButton.setTitle("Stream", for: .disabled)
            recordButton.setTitle("Stream", for: .normal)
            
        }
    }
    
    @IBAction func onRecordingTypeOptionsChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            currentPublishOptions = .videoPlusAudio
        } else if sender.selectedSegmentIndex == 1 {
            currentPublishOptions = .videoOnly
        } else if sender.selectedSegmentIndex == 2 {
            currentPublishOptions = .audioOnly
        }
    }
    
    @IBAction func onQualityOptionsChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            resolution = RESOLUTION_LOW
        } else if sender.selectedSegmentIndex == 1 {
            resolution = RESOLUTION_CIF
        } else if sender.selectedSegmentIndex == 2 {
            resolution = RESOLUTION_MEDIUM
        } else if sender.selectedSegmentIndex == 3 {
            resolution = RESOLUTION_VGA
        } else if sender.selectedSegmentIndex == 4 {
            resolution = RESOLUTION_HIGH
        }
    }
    
    @IBAction func onRecordButton(_ sender: UIButton) {
        
        var options: MediaPublishOptions
        
        if isLive {
            options = MediaPublishOptions.appendStream(self.preView) as! MediaPublishOptions
        } else {
            options = MediaPublishOptions.recordStream(self.preView) as! MediaPublishOptions
        }
        
        switch currentPublishOptions {
            
        case .videoPlusAudio:
            
            options.orientation = .portrait
            options.resolution = resolution
            options.content = AUDIO_AND_VIDEO
            
        case .videoOnly:
            
            options.orientation = .portrait
            options.resolution = resolution
            options.content = ONLY_VIDEO
            
        case .audioOnly:
            
            options.content = ONLY_AUDIO
        }
        
        publisher = backendless?.mediaService.publishStream(streamNameTextField.text, tube: VIDEO_TUBE, options: options, responder: self)
        
        recordButton.isEnabled = false
        playButton.isEnabled = false
        streamNameTextField.isEnabled = false
        videoModeOptions.isEnabled = false
        recordingTypeOptions.isEnabled = false
        qualityOptions.isEnabled = false
        
        spinner.startAnimating()
    }
    
    @IBAction func onStopButton(_ sender: UIButton) {
        
        stopMedia()
    }
    
    func stopMedia() {
        
        if publisher != nil {
            
            publisher?.disconnect()
            publisher = nil;
        }
        
        if player != nil {
            
            player?.disconnect()
            player = nil;
        }
        
        refreshUI()
        
        spinner.stopAnimating()
    }
    
    @IBAction func onPlayButton(_ sender: UIButton) {
        
        var options: MediaPlaybackOptions
        
        if isLive {
            options = MediaPlaybackOptions.liveStream(self.playbackView) as! MediaPlaybackOptions
        } else {
            options = MediaPlaybackOptions.recordStream(self.playbackView) as! MediaPlaybackOptions
        }
        
        options.orientation = .up
        options.isRealTime = isLive
        
        player = backendless?.mediaService.playbackStream(streamNameTextField.text, tube: VIDEO_TUBE, options: options, responder: self)
        
        recordButton.isEnabled = false
        playButton.isEnabled = false
        streamNameTextField.isEnabled = false
        videoModeOptions.isEnabled = false
        recordingTypeOptions.isEnabled = false
        qualityOptions.isEnabled = false
        
        spinner.startAnimating()
    }
    
    @IBAction func onSwapCameraButton(_ sender: UIButton) {
        
        publisher?.switchCameras()
    }
    
    
    // MARK: UITextFieldDelegate protocol methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: IMediaStreamerDelegate protocol methods to handle stream state changes and errors
    
    public func streamStateChanged(_ sender: Any!, state: Int32, description: String!) {
        
        switch state {
            
        case 0: // CONN_DISCONNECTED
            
            stopMedia()
            
        case 1: break //CONN_CONNECTED
            
        case 2: //CONN_CREATED
            
            // STOP THE CAMERA PREVIEW
            cameraSession.stopRunning()
            
            stopButton.isEnabled = true
            
        case 3: //STREAM_PLAYING
            
            if self.publisher != nil {
                
                if description != "NetStream.Publish.Start" {
                    stopMedia()
                    return
                }
                
                swapCameraButton.isEnabled = true
                spinner.stopAnimating()
            }
            
            if self.player != nil {
                
                if description == "NetStream.Play.StreamNotFound" {
                    stopMedia()
                    
                    playButton.isEnabled = true
                    stopButton.isEnabled = false
                    
                    return
                }
                
                if description != "NetStream.Play.Start" {
                    return
                }
                
                MPMediaData.routeAudioToSpeaker()
                
                preView.isHidden = true
                playbackView.isHidden = false
                
                spinner.stopAnimating()
            }
            
            return
            
        case 4: //STREAM_PAUSED
            
            stopMedia()
            
        default:
            print("streamStateChanged unhandled state: \(state)")
            return
        }
    }
    
    func streamConnectFailed(_ sender: Any!, code: Int32, description: String!) {
        
        print("<IMediaStreamerDelegate> streamConnectFailed: \(code) = \(description)")
        
        stopMedia()
    }
    
}

