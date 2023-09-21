import UIKit
import AVKit
import AVFoundation
import watch2earnSDK

class PlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playVideo()
        observePlayer()
    }

    func playVideo() {
        print("Player Starts", self.title!)
        player = AVPlayer(url: URL(string: "https://d2ac29vaob351i.cloudfront.net/v1/master/9d062541f2ff39b5c0f48b743c6411d25f62fc25/PokerNight-EdgeVideo/216.m3u8")!)
        player?.play()
        
        W2EManager.w2eSdk.playerViewControl(avPlayerController: self, channelName: self.title!)
    }

    func observePlayer() {
        player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate", let newRate = change?[NSKeyValueChangeKey.newKey] as? Float {
            if newRate == 0 {
                print(">>> stopped")
                W2EManager.w2eSdk.playerStop()
            } else if newRate == 1 {
                print(">>> playing")
                W2EManager.w2eSdk.playerStart()
            }
        }
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        W2EManager.w2eSdk.playerFinished()
        dismiss(animated: true, completion: nil)
    }
}
