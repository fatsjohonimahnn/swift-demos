//
//  PlaybackVC.swift
//  VideoRecorderPlayerBackendless
//
//  Created by Jonathon Fishman on 10/8/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit

class PlaybackVC: UIViewController, UITextFieldDelegate, IMediaStreamerDelegate {

    @IBOutlet weak var streamNameTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playBackView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var isLive = false
    
    var resolution: MPVideoResolution = RESOLUTION_CIF

    
    var backendless = Backendless.sharedInstance()
    var player: MediaPlayer?
    let VIDEO_TUBE = "Default"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        streamNameTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }
    
    func textFieldChanged(textField: UITextField) {
        
        if streamNameTextField.text == "" {
            
            playButton.isEnabled = false
            stopButton.isEnabled = false
            
        } else {
            
            playButton.isEnabled = true
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
 
    @IBAction func onPlayButton(_ sender: UIButton) {
        
        var options: MediaPlaybackOptions
        
        if isLive {
            options = MediaPlaybackOptions.liveStream(self.playBackView) as! MediaPlaybackOptions
        } else {
            options = MediaPlaybackOptions.recordStream(self.playBackView) as! MediaPlaybackOptions
        }
        
        options.orientation = .up
        options.isRealTime = isLive
        
        player = backendless?.mediaService.playbackStream(streamNameTextField.text, tube: VIDEO_TUBE, options: options, responder: self)
        
        playButton.isEnabled = false
        streamNameTextField.isEnabled = false
        
        spinner.startAnimating()
    }
    
    @IBAction func onStopButton(_ sender: UIButton) {
        
        stopMedia()
    }
    
    func stopMedia() {
        
        if player != nil {
            
            player?.disconnect()
            player = nil;
        }
        
        spinner.stopAnimating()
    }
    
    // MARK: UITextFieldDelegate protocol methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
    // MARK: IMediaStreamerDelegate protocol methods to handle stream state changes and errors
    
    public func streamStateChanged(_ sender: Any!, state: Int32, description: String!) {
        
        switch state {
            
        case 0: //CONN_DISCONNECTED
            
            stopMedia()
            
        case 1: break //CONN_CONNECTED
            
        case 2: //CONN_CREATED
            
            stopButton.isEnabled = true
            
        case 3: //STREAM_PLAYING
            
            spinner.stopAnimating()
            
            if self.player != nil {
                
                if description == "NetStream.Play.StreamNotFound" {
                    stopMedia()
                    
                    print("NetStream.Play.StreamNotFound")
                    
                    // turn on play button
                    playButton.isEnabled = true
                    stopButton.isEnabled = false 
                    
                    return
                }
                
                if description != "NetStream.Play.Start" {
                    
                    print("NetStream.Play.Start")
                    return
                }
                
                MPMediaData.routeAudioToSpeaker()
                
                playBackView.isHidden = false
                
                spinner.stopAnimating()
            }
            
            return
            
        case 4: //STREAM_PAUSED
            
            stopMedia()
            
        default:
            print("streamStateChanged unhandled state: \(state)");
            return
        }
    }
    
    func streamConnectFailed(_ sender: Any!, code: Int32, description: String!) {
        
        print("<IMediaStreamerDelegate> streamConnectFailed: \(code) = \(description)");
        
        stopMedia()
    }


}
