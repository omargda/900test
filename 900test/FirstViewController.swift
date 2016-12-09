//
//  FirstViewController.swift
//  900test
//
//  Created by Omar Garcia De Alba on 10/26/16.
//  Copyright © 2016 Omar Garcia De Alba. All rights reserved.
//

import UIKit
import AWSSES

class FirstViewController: UIViewController, NHSBroadcastManagerDelegate {

    var broadcastManager: NHSBroadcastManager!
    var stream: NHSStream?
    var uploadTimer: Timer?
    
    var previewView: UIView!
    
    var recordContainer: UIView!
    var recordButton: UIButton!
    
    var isRecording = false
    var viewConfigured = false
    var liveLabel: UILabel!
    var isFrontCamera = false
    
    var streamDoneOverlay: UIView!
    var streamDoneLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //configureView()
        
        if !viewConfigured {
            streamDoneOverlay.removeFromSuperview()
            configureView()
        }
        super.viewWillAppear(animated)
    }
    
    func configureView() {
        viewConfigured = true
        let viewWidth: Double = Double(self.view.frame.width)
        let viewHeight: Double = Double(self.view.frame.height)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        broadcastManager = NHSBroadcastManager.shared()
        broadcastManager.qualityPreset = .preset640HighBitrate
        broadcastManager.delegate = self
        //broadcastManager.setupCamera(into: .back)
        
        self.view.backgroundColor = .clear
        previewView = self.broadcastManager.createPreviewView(with: self.view.frame)
        self.view.addSubview(previewView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapToFocus(_:)))
        self.previewView.addGestureRecognizer(recognizer)
        broadcastManager.startPreview()
        
        let recordContainer = UIView(frame: CGRect(x: Double((viewWidth / 2) - (viewWidth / 10)), y: Double(viewHeight - (viewWidth / 5)), width: Double(viewWidth / 5), height: Double(viewWidth / 5)))
        recordContainer.backgroundColor = UIColor.white
        recordContainer.alpha = 0.7
        recordContainer.layer.borderWidth = 1.0
        recordContainer.layer.cornerRadius = recordContainer.frame.width / 2
        self.view.addSubview(recordContainer)
        self.recordContainer = recordContainer
        
        let recordButton = UIButton(type: .system)
        recordButton.frame = CGRect(x: Double(recordContainer.frame.width / 4), y: Double(recordContainer.frame.width / 4), width: Double(recordContainer.frame.width / 2), height: Double(recordContainer.frame.width / 2))
        recordButton.addTarget(self, action: #selector(record(_:)), for: .touchUpInside)
        recordButton.backgroundColor = .red
        recordButton.alpha = 0.7
        recordButton.layer.borderWidth = 1.0
        recordButton.layer.cornerRadius = (recordButton.frame.width) / 2
        recordContainer.addSubview(recordButton)
        self.recordButton = recordButton
        
        let rotateCam = UIImageView(frame: CGRect(x: (viewWidth * (9 / 10)) - 5.0, y: 5.0, width: viewWidth / 10, height: viewWidth / 10))
        rotateCam.image = UIImage(named: "rotate-camera")
        rotateCam.clipsToBounds = true
        rotateCam.contentMode = .scaleAspectFill
        rotateCam.backgroundColor = .clear
        rotateCam.layer.borderWidth = 1.0
        rotateCam.layer.borderColor = UIColor.white.cgColor
        rotateCam.layer.cornerRadius = rotateCam.frame.width / 2
        rotateCam.isUserInteractionEnabled = true
        rotateCam.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchCamera(_:))))
        self.view.addSubview(rotateCam)
        
        let exitButton = UIButton(type: .system)
        exitButton.frame = CGRect(x: 5.0, y: viewHeight - (viewWidth / 10) - 5.0, width: viewWidth / 10, height: viewWidth / 10)
        exitButton.setTitle("X", for: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.addTarget(self, action: #selector(exitStream(_:)), for: .touchUpInside)
        exitButton.backgroundColor = .clear
        exitButton.alpha = 0.7
        exitButton.layer.borderWidth = 1.0
        exitButton.layer.borderColor = UIColor.white.cgColor
        exitButton.layer.cornerRadius = (exitButton.frame.width) / 2
        self.view.addSubview(exitButton)
        
        liveLabel = UILabel(frame: CGRect(x: Double(recordContainer.frame.origin.x) - Double(recordContainer.frame.width / 4) , y: viewHeight - Double(recordContainer.frame.width / 4), width: Double(recordContainer.frame.width / 2), height: Double(recordContainer.frame.width / 3)))
        liveLabel.text = "LIVE"
        liveLabel.textAlignment = .center
        liveLabel.adjustsFontSizeToFitWidth = true
        liveLabel.baselineAdjustment = .alignCenters
        liveLabel.textColor = .red
        liveLabel.backgroundColor = .black
        liveLabel.alpha = 0.5
        liveLabel.layer.borderWidth = 1.0
        liveLabel.layer.cornerRadius = liveLabel.frame.height / 2
        self.view.addSubview(liveLabel)
        liveLabel.isHidden = true
        
        streamDoneOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewHeight))
        streamDoneOverlay.backgroundColor = .black
        
        streamDoneLable = UILabel(frame: CGRect(x: streamDoneOverlay.frame.width / 4, y: (streamDoneOverlay.frame.width / 2) - (streamDoneOverlay.frame.height / 5), width: streamDoneOverlay.frame.width / 2, height: streamDoneOverlay.frame.height / 5))
        streamDoneLable.text = "STREAM DONE"
        streamDoneLable.textColor = .white
        streamDoneLable.adjustsFontSizeToFitWidth = true
        streamDoneLable.textAlignment = .center
        streamDoneLable.baselineAdjustment = .alignCenters
        streamDoneLable.backgroundColor = .clear
        streamDoneOverlay.addSubview(streamDoneLable)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func tapToFocus(_ sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            let tapPoint = sender.location(in: self.previewView)
            NHSBroadcastManager.shared().showFocusArea(at: tapPoint, withPreview: self.previewView)
        }
    }
    
    func switchCamera(_ sender: UIImageView) {
        if isFrontCamera {
            self.previewView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } else {
            self.previewView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        isFrontCamera = !isFrontCamera
        self.broadcastManager.setupCamera(into: .unspecified)
    }
    
    func exitStream(_ sender: UIButton) {
        viewConfigured = false
        stopAll()
    }

    func record(_ sender: UIButton) {
        if isRecording {
            viewConfigured = false
            stopAll()
        } else {
            self.recordContainer.isHidden = false
            self.recordButton.isHidden = false
            self.liveLabel.isHidden = false
            
            isRecording = true
            
            self.broadcastManager.startBroadcasting()
        }
    }
    
    func stopAll() {
        self.broadcastManager.stopPreview(true)
        self.broadcastManager.stopBroadcasting()
        self.view.addSubview(streamDoneOverlay)
            
        self.recordContainer.isHidden = true
        self.recordButton.isHidden = true
        
        self.liveLabel.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        isRecording = false
    }
    
    // MARK - Broadcast Delegate
    
    func broadcastManager(_ manager: NHSBroadcastManager!, didStartBroadcastWith stream: NHSStream!) {
        if (stream != nil) {
            print("Started streaming: \(stream)")
            
            self.stream = stream
            self.uploadTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(uploadTimerAction), userInfo: nil, repeats: true)
            RunLoop.main.add(self.uploadTimer!, forMode: .defaultRunLoopMode)
        }
    }
    
    func uploadTimerAction() {
        
    }
    
    func broadcastManager(_ manager: NHSBroadcastManager!, didCreatePreviewImageForStreamWithID streamID: String!, image previewImage: UIImage!) {
        print("Stream \(streamID) created preview image \(previewImage.size.width)x\(previewImage.size.height)")
    }
    
    func broadcastManager(_ manager: NHSBroadcastManager!, didUpdateLocationForStreamWithID streamID: String!, with location: CLLocation!) {
        print("Stream: \(streamID) at location: \(location) ")
    }
    
    func broadcastManagerDidFail(toCreateStream manager: NHSBroadcastManager!, withError error: Error!) {
        print("Failed to create stream: \(error)")
    }
    
    func broadcastManagerDidFail(toStartRecording manager: NHSBroadcastManager!) {
        print("Failed to start recording")
    }
    
    func broadcastManagerDidStopRecording(_ manager: NHSBroadcastManager!) {
        print("Stopped recording")
        self.recordButton.isSelected = false
    }
    
    func broadcastManager(_ manager: NHSBroadcastManager!, didStopBroadcastOf stream: NHSStream!) {
        print("Stopped broadcasting")
        self.uploadTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

