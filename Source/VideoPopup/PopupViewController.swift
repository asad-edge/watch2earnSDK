//
//  PopupViewController.swift
//  FreebieTV
//
//  Created by Asad Iqbal on 19/01/2023.
//

import UIKit
import AVFoundation
import AVKit
class PopupViewController: UIViewController {
    
    @IBOutlet weak var popUpFrame: UIView!
    
       var player: AVPlayer!
       var playerLayer: AVPlayerLayer!
       var videoURL: URL!
       var skipOverlayViewController : SkipViewController!
       var topVC : UIViewController!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           player = AVPlayer(url: videoURL)
           playerLayer = AVPlayerLayer(player: player)
           presentSkipOverlay()
           // Set player layer frame
               playerLayer.frame = popUpFrame.bounds
               // Add player layer as a sublayer
               popUpFrame.layer.addSublayer(playerLayer)
           player.play()
       }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func topMostController() -> UIViewController {
    var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!

    while (topController.presentedViewController != nil) {
    topController = topController.presentedViewController!

    }

    return topController

    }
    
    func presentSkipOverlay() {
        self.skipOverlayViewController = SkipViewController()
        self.topVC = topMostController()
        skipOverlayViewController.onSkip = {
            [self] in
            
            // Skip the intro here. For the example skip 30 seconds
//            self?.player?.seek(to: CMTime(seconds: 30.0, preferredTimescale: 1))
            player.pause()
            player.replaceCurrentItem(with: nil)
            dismiss(animated: true, completion: nil)
            skipOverlayViewController.dismiss(animated: true, completion: nil)
            topVC.dismiss(animated: true, completion: nil)
        }
                skipOverlayViewController.modalPresentationStyle = .overCurrentContext
        skipOverlayViewController.accessibilityViewIsModal = true
        topVC.present(skipOverlayViewController, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                self.skipOverlayViewController.skipButton.isHidden = false;
                self.skipOverlayViewController.skipButton.isSelected = true
//                skipOverlayViewController.dismiss(animated: true, completion: nil)
            }
        })
    }
   }

