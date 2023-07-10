//
//  PopupPlayerView.swift
//  FreebieTV
//
//  Created by Asad Iqbal on 19/01/2023.
//

import Foundation
import AVKit
import UIKit

class PopupPlayerView: UIView {
    
    static var skipButton = SkipViewController();
    private var avPlayerController = AVPlayerViewController()
    private (set) var avPlayer = AVPlayer()
    private var timeObserverToken: CMTime? = nil;
    private var timer = Timer();
    
    private (set) var isPlaying: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   
    
    //========== LAYOUT SUBVIEWS =================================
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //avPlayerLayer.frame = self.bounds
        let playerFrame = CGRect(x: 100, y: 100, width: self.frame.width-300, height: self.frame.height-300)
//        self.updateIndicatorLayout(frame: playerFrame)
        
        self.avPlayerController.view.frame = playerFrame
    }
    
    //========== DEINIT ==================================
    deinit {
        stopPlay()
    }
    
    func initPlayer(mediaSource: String) {
        
        if let url = URL(string: mediaSource) {
            let playerItem = AVPlayerItem(url: url)
            self.avPlayer.replaceCurrentItem(with: playerItem)
            self.avPlayerController.player = self.avPlayer
            self.avPlayerController.presentSkipOverlay()
            self.addSubview(self.avPlayerController.view)
        }
//            self.addIndicatorView(false)
//            self.startIndicatorView()
        }


        //========= PLAY STREAM ==========================
        func startPlay() {
            
            if self.avPlayer.timeControlStatus == .playing {
                return
            }
            self.avPlayer.play() // Start the playback
        }
        
        //========== STOP PLAY ==================
        func stopPlay() {
            self.avPlayer.pause()
            self.isPlaying = false
//            self.stopIndicatorView()
            self.avPlayer.replaceCurrentItem(with: nil)
        }
      
}

extension AVPlayerViewController {
    
    func presentSkipOverlay() {
        let skipOverlayViewController = SkipViewController()
        
        skipOverlayViewController.onSkip = {
            [weak self] in
            
            // Skip the intro here. For the example skip 60 seconds
            self?.player?.seek(to: CMTime(seconds: 60.0, preferredTimescale: 1))
        }
        
        skipOverlayViewController.modalPresentationStyle = .overCurrentContext
        skipOverlayViewController.accessibilityViewIsModal = true
        present(skipOverlayViewController, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                skipOverlayViewController.dismiss(animated: true, completion: nil)
            }
        })
    }
}
