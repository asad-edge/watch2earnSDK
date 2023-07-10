import Foundation
import AVKit
import UIKit

@available(tvOS 13.0, *)

class NotificationObserver: NSObject {

    let listener: (Notification) -> Void

    init(listener: @escaping (Notification) -> Void) {
        self.listener = listener
    }

    func observe(_ notification: Notification) {
        listener(notification)
    }
}

public class EarnifySDK {
    
    private let stakingClient = StakingClient();
    private let playerOverlay = PlayerOverlayView();
    private let webSocket = W2EWebSocket(DataStore: W2EDataStore(earning: 0.300, reward: 0.0, lastReward: 0.0, offchainBalance: 0.0, periodDuration: 0.0, lastRewardTime: "", w2eValues: (0,0,0,0,0,0) as AnyObject));
    private var walletHandler = WalletHandler();
    private var tickerService = TickersClient();
    private var remoteSocket = RemoteSocketService();
    private var gamifySocket = GamificationSocket();
    private var messagesHandler = MessagesHandler();
    private (set) var isBoosted: Bool = false
    private (set) var avPlayer:AVPlayer?
    private (set) var avPlayerControl:UIViewController?
    private var notificationThread: Thread!
    private var isPlaying: Bool = false
    private var isGameReceived: Bool = false
    private var isRateSend: Bool = false
    private var timeObserverToken: CMTime? = nil;
    static var animateFigure = AnimateFigures();
    private var channelHandler = ChannelHandler();
    
    var timer: Timer = Timer();
    var cacheStore = CacheStorage()
    var gamificationViewController: GamificationViewController!
    var tvLogo: URL!
    
    public init() {
        
    }
    
    public func showGamifyTicketWhenPollRecieved(){
        print("Show Poll Received")
//        self.gamificationViewController.view.isHidden = false
        self.isGameReceived = true
        self.changeGamifyFrame(gamify: self.gamificationViewController.view, toOriginX: self.gamificationViewController.view.frame.origin.x, toOriginY: 0, duration: 2)
    }
    
    public func showHideGamifyTicketWhenWinLoseRecieved(){
        print("Show Winlose Received")
//        self.gamificationViewController.view.isHidden = false
        self.changeGamifyFrame(gamify: self.gamificationViewController.view, toOriginX: self.gamificationViewController.view.frame.origin.x, toOriginY: 0, duration: 2)
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false){_ in
            self.isGameReceived = false
            self.changeGamifyFrame(gamify: self.gamificationViewController.view, toOriginX: self.gamificationViewController.view.frame.origin.x, toOriginY: -135, duration: 2)
        }
    }
    
    public func getTickerOverlay() -> PlayerOverlayView{
        return playerOverlay
    }
    
    public func getSettingScreen() -> SettingsViewController{
        
        let storyboard = UIStoryboard(name: "SettingsViewController", bundle: Bundle(for: SettingsViewController.self))
        let VC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        return VC
    }
    
    public func getGamificationUI() -> GamificationViewController{
        
        return GamificationViewController(nibName: "GamificationViewController", bundle: Bundle(for: GamificationViewController.self))
    }
    
    var progressPre: Float = 0.0
    var earningPre: Double = 0.0
    var gamifiedChannel = false;
    
    public func playerViewControl(avPlayerController: AVPlayerViewController, channelName: String) {
//        let points = cacheStore.getDouble(_key: "WinPoints")
        //EarnifySDK.animateFigure.updateBalance(newBalance: W2EManager.w2eSdk.getW2EDataStore().offchainBalance + points, animationTime: 20.0)
        W2EManager.w2eSdk.setLogoTicker(sdkAPIKey:W2EManager.sdkKey! )
        channelHandler.getChannelDetails(apiKey: W2EManager.sdkKey!, completionHandler: {(data, response, error) in
            W2EManager.channelWallets = data
        })
        self.avPlayer = avPlayerController.player
        self.avPlayerControl = avPlayerController;
        if(!W2EManager.optW2e){
            W2EManager.w2eSdk.startStaking()
            // Filter the array based on the channel name
            let filteredArray = W2EManager.channelWallets?.filter { ($0.channelName) == channelName }

            // Check if the filtered array is not empty
            if let firstResult = filteredArray?.first {
//                        let channelAddress = firstResult.channelAddress
                        W2EManager.w2eSdk.sendRateData(type: "rate", value: 600)
//                      W2EManager.w2eSdk.sendChannelData(type: "channel", value: channelAddress)
                    let isGamified = firstResult.isGamified
                    gamifiedChannel = isGamified
                    if isGamified {
                        print("is_gamified true: \(isGamified)")
                        showGamificationView()
                        
                        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPause(gesture:)))
                        touchRecognizer.numberOfTapsRequired = 1
                        touchRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
                        avPlayerControl?.view.addGestureRecognizer(touchRecognizer)
                        
                        let playerLeftRecognizer = UITapGestureRecognizer(target: self, action: #selector(LeftNavigationPressed(gesture:)))
                        playerLeftRecognizer.numberOfTapsRequired = 1
                        playerLeftRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.leftArrow.rawValue)]
                        avPlayerControl?.view.addGestureRecognizer(playerLeftRecognizer)
                        
                        let playerRightRecognizer = UITapGestureRecognizer(target: self, action: #selector(RightNavigationPressed(gesture:)))
                        playerRightRecognizer.numberOfTapsRequired = 1
                        playerRightRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.rightArrow.rawValue)]
                        avPlayerControl?.view.addGestureRecognizer(playerRightRecognizer)
                        W2EManager.w2eSdk.connectGamifySocket(channelId: firstResult.channelID)
                        
                        //                        gamificationViewController.view.isHidden = false
                        self.changeGamifyFrame(gamify: gamificationViewController.view, toOriginX: gamificationViewController.view.frame.origin.x, toOriginY: 0, duration: 2)
                        playerStart()
                    }else{
                        print("is_gamified false: \(isGamified)")
                        //ticker overlay view
                        avPlayerControl?.view.addSubview(W2EManager.overlay.view)
                        self.timer.invalidate();
                        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true);
                        addPeriodicTimeObserver()
                        
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false){_ in
                            if(W2EManager.optW2e) {
                                //W2EManager.overlay.view.isHidden = true
                            }else{
                                self.notificationThread = Thread(target: self, selector: #selector(self.tickersMsg), object: nil)
                                self.notificationThread.start()
                                
                                W2EManager.overlay.view.isHidden = false
                                self.changeW2eFrame(w2ebar: W2EManager.overlay.view, toOriginX: W2EManager.overlay.view.frame.origin.x, toOriginY: 0, duration: 2)
                                self.playerStart()
                            }
                        }
                    }
                    let playerTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerMenuPressed(gesture:)))
                    playerTouchRecognizer.numberOfTapsRequired = 1
                    playerTouchRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
                    avPlayerControl?.view.addGestureRecognizer(playerTouchRecognizer)
                    
                    let playerRecognizer = UITapGestureRecognizer(target: self, action: #selector(AutoHideW2ETickerPressed(gesture:)))
                    playerRecognizer.numberOfTapsRequired = 1
                    playerRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.upArrow.rawValue)]
                    avPlayerControl?.view.addGestureRecognizer(playerRecognizer)
                  
                    observePlayerSeeking(player: avPlayer!)
                    
            } else {
                print("Channel name not found in the array")
            }
        }
        W2EManager.w2eSdk.getRemoteMessage{ result in
                switch result {
                case .success(let message):
                    print("Received message: \(message)")
                    DispatchQueue.main.sync {
                      switch message{
                        case "DISCONNECTED":
                            self.isBoosted = false
                          self.hideShowQrCode()
                             W2EManager.w2eSdk.sendRateData(type: "rate", value: 600)
                        case "PLAY":
                            self.avPlayer?.play()
                        case "PAUSE":
                            self.avPlayer?.pause()
                        case "MUTE":
                            self.avPlayer?.isMuted = true
                            break
                        case "UNMUTE":
                            self.avPlayer?.isMuted = false
                        case "BOOST":
                            if(!self.isBoosted){
                            W2EManager.w2eSdk.sendRateData(type: "rate", value: 4*600)
                            self.isBoosted = true
                                self.hideShowQrCode()
//                                W2EManager.w2eSdk.sendRemoteMessage(msg: #"{"type": "channel","name": "Newsmax"}"# )
//                                W2EManager.w2eSdk.sendRemoteMessage(msg: #"{"type": "gamification", "enabled": true}"#)
                            }
                            break
                            
                        default: break
                            //self.avPlayer.play()
                        }
                    }
                case .failure(let error):
                    print("Error receiving message: \(error)")
                }
            }

    }
    private var observation: NSKeyValueObservation?
    
    func observePlayerSeeking(player: AVPlayer) {
        print("Start observing seeking")
            // Observe the `status` and `timeControlStatus` properties of the player's current item
            observation = player.currentItem?.observe(\.status, options: [.new, .old], changeHandler: { (item, change) in
                if item.status == .readyToPlay {
                    // Player is ready to play

                    // Observe the `isPlaybackLikelyToKeepUp` and `isPlaybackBufferEmpty` properties
                    self.observation = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new, .old], changeHandler: { (item, change) in
                        if let isPlaybackLikelyToKeepUp = change.newValue {
                            if !isPlaybackLikelyToKeepUp {
                                    // Player is seeking
                                    print("Player is seeking")
                                if !self.gamifiedChannel {
                                    self.hideShowBar()
                                }else {
                                    self.hideShowGamifyBar()
                                }
                                
                            }
                        }
                    })
                }
            })
        }
    
    @objc func playPause(gesture: UITapGestureRecognizer){

        if gesture.state == UIGestureRecognizer.State.ended {
            print("Play/Pause touch Detected ")

            if self.isPlaying {
                self.avPlayer?.pause()
            }else{
                self.avPlayer?.play()
            }
        }

    }

    @objc func PlayerMenuPressed(gesture: UITapGestureRecognizer){

        if gesture.state == UIGestureRecognizer.State.ended {
            print("Gamification Menu touch Detected ")
//            showGamificationView()
            if gamifiedChannel {
                gamificationViewController.dismiss(animated: true)
            }
            avPlayer?.replaceCurrentItem(with: nil)
            self.avPlayerControl?.dismiss(animated: true)
            playerFinished()
            
        }

    }
    
    @objc func LeftNavigationPressed(gesture: UITapGestureRecognizer){

        if gesture.state == UIGestureRecognizer.State.ended {
            print("Gamification Left touch Detected ")
            skipBackward()
        }

    }
    
    @objc func RightNavigationPressed(gesture: UITapGestureRecognizer){

        if gesture.state == UIGestureRecognizer.State.ended {
            print("Gamification Right touch Detected ")
             skipForward()
        }

    }
    @objc func AutoHideW2ETickerPressed(gesture: UITapGestureRecognizer){

        if gesture.state == UIGestureRecognizer.State.ended {
            print("W2E autohide touch Detected ")
            if gamifiedChannel {
                hideShowGamifyBar()
            }else {
                hideShowBar()
            }
        }

    }
    
    
    func skipBackward() {
        
        // Subtract the skip duration from the current playback time
        let currentTime = avPlayer?.currentTime()
        let newTime = currentTime! - CMTime(seconds: 10, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let bufferTime = CMTime(seconds: 10, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        avPlayer?.seek(to: newTime, toleranceBefore: bufferTime, toleranceAfter: bufferTime)
    }

    func skipForward() {
        let currentTime = avPlayer?.currentTime()
        let newTime = currentTime! + CMTime(seconds: 10, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        // Start buffering
        avPlayer?.seek(to: newTime, toleranceBefore: newTime, toleranceAfter: newTime)
    }
    
    private func showGamificationView(){
        gamificationViewController = W2EManager.w2eSdk.getGamificationUI()
        gamificationViewController.modalPresentationStyle = .overFullScreen
        gamificationViewController.accessibilityViewIsModal = true
        gamificationViewController.didMove(toParent: avPlayerControl.self);
        //avPlayerController.addChild(gamificationViewController)
        //self.avPlayerControl?.present(gamificationViewController, animated: true)
        
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPause(gesture:)))
        touchRecognizer.numberOfTapsRequired = 1
        touchRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        gamificationViewController.view.addGestureRecognizer(touchRecognizer)
        
        let menuTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerMenuPressed(gesture:)))
        menuTouchRecognizer.numberOfTapsRequired = 1
        menuTouchRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        gamificationViewController.view.addGestureRecognizer(menuTouchRecognizer)
        
        let playerLeftRecognizer = UITapGestureRecognizer(target: self, action: #selector(LeftNavigationPressed(gesture:)))
        playerLeftRecognizer.numberOfTapsRequired = 1
        playerLeftRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.leftArrow.rawValue)]
        gamificationViewController.view.addGestureRecognizer(playerLeftRecognizer)
        
        let playerRightRecognizer = UITapGestureRecognizer(target: self, action: #selector(RightNavigationPressed(gesture:)))
        playerRightRecognizer.numberOfTapsRequired = 1
        playerRightRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.rightArrow.rawValue)]
        gamificationViewController.view.addGestureRecognizer(playerRightRecognizer)
        
    }
    
    
    func hideShowQrCode() {
        if self.isBoosted {
            if W2EManager.overlay.qr_code.isHidden {
            W2EManager.overlay.gamificationView.isHidden = false
            W2EManager.overlay.qr_code.isHidden = false
                UIView.animate(withDuration: 2, animations: { [] in
                    W2EManager.overlay.qr_code.alpha = 1.0
                })
                {_ in
                    W2EManager.overlay.qr_code.isHidden = false
                }
            }
            if self.isPlaying && !W2EManager.overlay.qr_code.isHidden {
                    Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false){_ in
                        if self.isPlaying {
                            UIView.animate(withDuration: 2, animations: { [] in
                                W2EManager.overlay.qr_code.alpha = 0.0
                            })
                            {_ in
                                W2EManager.overlay.qr_code.isHidden = true
                            }
                        }
                }
            }
        }else {
            W2EManager.overlay.gamificationView.isHidden = true
            W2EManager.overlay.qr_code.isHidden = true
        }
    }
    
    func qrCodeAnimation(qrCode: UIImageView, duration: TimeInterval){
             }
    
    
    
    @objc func tickersMsg(){
        print("Notification Thread: ",self.notificationThread.isCancelled )
        if !self.notificationThread.isCancelled {
            
            let stakingData = W2EManager.w2eSdk.getStakingData();
            let socketData = W2EManager.w2eSdk.getW2EDataStore();
            
            if !W2EManager.w2eSdk.getWallet().private.isEmpty{
                DispatchQueue.main.sync {
                    W2EManager.overlay.w2eMsg.text = W2EManager.w2eSdk.getServerMessages().wallet_not_forwarded
                    self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: 3, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                }
                sleep(60)
            }
            if socketData.periodDuration > 0 {
                DispatchQueue.main.sync {
                    W2EManager.overlay.w2eMsg.text = W2EManager.w2eSdk.getServerMessages().watch_2_earn_active
                    self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: 3, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                }
                sleep(10)
            }
            if self.isBoosted
            {
                DispatchQueue.main.sync {
                    W2EManager.overlay.w2eMsg.text = "BOOST: Active"
                    
                    self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: 3, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                }
                sleep(10)
            }
            if(stakingData.balance < stakingData.maxBalance){
                DispatchQueue.main.sync {
                    W2EManager.overlay.w2eMsg.text = "STAKING: Will resume in " + stakingData.hoursUntilStaking.formatHours()
                    self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: 3, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                }
                sleep(10)
            }else if stakingData.balance != 0.0 && stakingData.maxBalance != 0.0
            {
                DispatchQueue.main.sync {
                    W2EManager.overlay.w2eMsg.text = W2EManager.w2eSdk.getServerMessages().staking_active
                    
                    self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: 3, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                }
                sleep(10)
            }
            
            tickersMsg()
        }else{
            print("Notification Thread exist")
            Thread.exit()
        }
    }
    
    
    func changeW2eFrame(w2ebar: UIView,
                            toOriginX newOriginX: CGFloat,
                            toOriginY newOriginY: CGFloat,
                            duration: TimeInterval)
    {

        UIView.animate(withDuration: duration, animations: { [self] in
            //w2ebar.transform = transform
            if(newOriginY >= 0){
                w2ebar.alpha = 1.0
            }else{
                if isPlaying && !W2EManager.optW2e && W2EManager.hideW2eBar{
                    w2ebar.alpha = 0.0
                }
            }
        }) { [self] _ in
//            w2ebar.transform = .identity
//            w2ebar.frame = newFrame
            if(newOriginY >= 0){
                W2EManager.overlay.view.isHidden = false
            }else{
                if isPlaying && !W2EManager.optW2e && W2EManager.hideW2eBar {
                    W2EManager.overlay.view.isHidden = true
                }
            }

        }
    }
    
    func changeGamifyFrame(gamify: UIView,
                            toOriginX newOriginX: CGFloat,
                            toOriginY newOriginY: CGFloat,
                            duration: TimeInterval)
    {
        UIView.animate(withDuration: duration, animations: { [self] in
            //w2ebar.transform = transform
            if(newOriginY >= 0){
                gamify.alpha = 1.0
            }else{
                if isPlaying && !W2EManager.optW2e && W2EManager.hideGamifyBar && !isGameReceived{
                    gamify.alpha = 0.0
                }
            }
        }) { [self] _ in
//            w2ebar.transform = .identity
//            w2ebar.frame = newFrame
            if(newOriginY >= 0){
                if let _ = gamificationViewController?.presentingViewController {
                    print("gamify already presented")
                    }
                else {
                    print("gamify already not presented")
                    DispatchQueue.main.async {
                    self.gamificationViewController?.beginAppearanceTransition(true, animated: true)
                    self.gamificationViewController?.endAppearanceTransition()
                    self.avPlayerControl?.present(self.gamificationViewController, animated: true)
                        
                    self.gamificationViewController.view.isHidden = false
                    }
                }
            }else{
                if isPlaying && !W2EManager.optW2e && W2EManager.hideGamifyBar && !isGameReceived {
                    if let _ = gamificationViewController?.presentingViewController {
                        print("gamify already presented 2")
                        DispatchQueue.main.async {
                            self.gamificationViewController.view.isHidden = true
                            self.gamificationViewController.dismiss(animated: true) {
                                print("gamify dismissed 2")
                            }
                        }
                    } else {
                        print("gamify already not presented 2")
                    }

                }
            }

        }
    }
    
    func changeFrame(label: UILabel,
                            toOriginX newOriginX: CGFloat,
                            toOriginY newOriginY: CGFloat,
                            toWidth newWidth: CGFloat,
                            toHeight newHeight: CGFloat,
                            duration: TimeInterval)
    {
        let oldFrame = label.frame
        let newFrame = CGRect(x: newOriginX, y: newOriginY, width: newWidth, height: newHeight)

        let translation = CGAffineTransform(translationX: newFrame.midX - oldFrame.midX,
                                            y: newFrame.midY - oldFrame.midY)
        let scaling = CGAffineTransform(scaleX: newFrame.width / oldFrame.width,
                                        y: newFrame.height / oldFrame.height)

        let transform = translation.concatenating(scaling)
            
            UIView.animate(withDuration: duration, animations: {
                        label.transform = transform
            }) { _ in
                
                label.transform = .identity
                label.frame = newFrame
                if W2EManager.overlay.w2eMsg.frame.origin.y >= 0 {
                    if ((W2EManager.overlay.w2eMsg.text?.contains("edgevideo.com/activate")) == true) {
                        Timer.scheduledTimer(withTimeInterval: 55.0, repeats: false){_ in
                            self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: -30, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                        }
                        
                    }else{
                        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){_ in
                            self.changeFrame(label: W2EManager.overlay.w2eMsg, toOriginX: W2EManager.overlay.w2eMsg.frame.origin.x, toOriginY: -30, toWidth: W2EManager.overlay.w2eMsg.frame.width, toHeight: W2EManager.overlay.w2eMsg.frame.height, duration: 2)
                        }
                        
                    }
                }
            }
        
    }
    
    func hideShowBar(){
        if(W2EManager.hideW2eBar && !W2EManager.optW2e && W2EManager.overlay.view.isHidden) {
            W2EManager.overlay.view.isHidden = false
            self.changeW2eFrame(w2ebar: W2EManager.overlay.view, toOriginX: W2EManager.overlay.view.frame.origin.x, toOriginY: 0, duration: 2)
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){_ in
                self.changeW2eFrame(w2ebar: W2EManager.overlay.view, toOriginX: W2EManager.overlay.view.frame.origin.x, toOriginY: -135, duration: 2)
            }

        }
    }
    
    func hideShowGamifyBar(){
        if(W2EManager.hideGamifyBar && !W2EManager.optW2e && gamificationViewController.view.isHidden) {
//            gamificationViewController.view.isHidden = false
            self.changeGamifyFrame(gamify: gamificationViewController.view, toOriginX: gamificationViewController.view.frame.origin.x, toOriginY: 0, duration: 2)
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){_ in
                self.changeGamifyFrame(gamify: self.gamificationViewController.view, toOriginX: self.gamificationViewController.view.frame.origin.x, toOriginY: -135, duration: 2)
            }

        }
    }
    
    
public func addPeriodicTimeObserver() {
    // Invoke callback every half second
    let interval = CMTime(seconds: 0.05,
                          preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    // Add time observer. Invoke closure on the main queue.
    timeObserverToken =
    self.avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [self] time in
        if isPlaying && !isRateSend{
            W2EManager.w2eSdk.sendRateData(type: "rate", value: 600)
            isRateSend = true
        }
        updatingOverlay()
    } as? CMTime
}
    
    public func playerStop(){
        self.isPlaying = false
        hideShowQrCode()
        if !W2EManager.optW2e {
            W2EManager.w2eSdk.sendRateData(type: "rate", value: 0)
            isRateSend = false
            W2EManager.w2eSdk.socketStoreRest()
            earningPre = 0.0
            if gamifiedChannel {
                self.changeGamifyFrame(gamify: gamificationViewController.view, toOriginX: gamificationViewController.view.frame.origin.x, toOriginY: 0, duration: 2)
            }else{
                W2EManager.overlay.view.isHidden = false
                self.changeW2eFrame(w2ebar: W2EManager.overlay.view, toOriginX: W2EManager.overlay.view.frame.origin.x, toOriginY: 0, duration: 2)
            }
        }
    }
    public func playerStart(){
        self.isPlaying = true
        hideShowQrCode()
        if !W2EManager.optW2e {
            if(self.isBoosted){
                W2EManager.w2eSdk.sendRateData(type: "rate", value: 4*600)
            }else{
                W2EManager.w2eSdk.sendRateData(type: "rate", value: 600)
            }
            isRateSend = true
            W2EManager.w2eSdk.startStaking()
            W2EManager.w2eSdk.socketStoreRest()
            if gamifiedChannel {
                Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){_ in
                    
                    self.changeGamifyFrame(gamify: self.gamificationViewController.view, toOriginX: self.gamificationViewController.view.frame.origin.x, toOriginY: -135, duration: 2)
                }
            }else{
                Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){_ in
                    
                    self.changeW2eFrame(w2ebar: W2EManager.overlay.view, toOriginX: W2EManager.overlay.view.frame.origin.x, toOriginY: -135, duration: 2)
                }
            }
            
        }
    }
    public func playerFinished(){
        self.isPlaying = false
        if !W2EManager.optW2e {
            self.notificationThread?.cancel()
        }
        W2EManager.w2eSdk.sendRateData(type: "rate", value: 0)
        W2EManager.w2eSdk.stopStaking();
        W2EManager.w2eSdk.disconnectGamifySocket();
        self.timer.invalidate();
        EarnifySDK.animateFigure.stopBalanceAnimation()
        self.isBoosted = false;
    }
    
    @objc func updatingOverlay() {
               let stakingData = W2EManager.w2eSdk.getStakingData();
               let socketData = W2EManager.w2eSdk.getW2EDataStore();
               
               let earning = socketData.earning
               let diffEarning = earning - earningPre;
               let earningPerSec = diffEarning/400;
               earningPre += earningPerSec;
               
               let apy = String(format:"%.2f",stakingData.estimateAPY)+"%"
               let staked = String(format:"%.2f",stakingData.stakePercentage)+"%"
               let _estEarn = stakingData.estimate + earningPre
               let estEarning = String(format:"%.3f",_estEarn)
               
               W2EManager.overlay.perHour.text = estEarning
               let progress = Float(60000-socketData.getTimeRemainingInPeriod)/60000
                   let progressPerSec = progress/500;
                   progressPre += progressPerSec
               W2EManager.overlay.staked.text = staked
               W2EManager.overlay.estApy.text = apy
               if(progressPre > 1.0){
                   progressPre = 0.0
               }
               if(progressPre < (W2EManager.overlay.progress_bar.progress)){
                   W2EManager.overlay.progress_bar.setProgress(progressPre, animated: false)
               }else{
                   DispatchQueue.main.asyncAfter(deadline: .now()) {
                       UIView.animate(withDuration: 0.1) {
                           W2EManager.overlay.progress_bar.setProgress(self.progressPre, animated: true)
                       }
                   }
               }
               
    }
    
    @objc func timerAction(){
            let stakingData = W2EManager.w2eSdk.getStakingData();
            let socketData = W2EManager.w2eSdk.getW2EDataStore();
            let ticker = W2EManager.w2eSdk.getAllTickers();
            let points = socketData.offchainBalance
            let eatBalance = stakingData.balance
            var price = "0.00"
            var usdBalance = "0.00"
            var change24h = "0.00"
        
        if ticker.price > 0.0 {
            usdBalance = "$"+(eatBalance*ticker.price).delimiter
                price = String(format:"$%.4f",ticker.price)
                
                
                if ticker.change24h < 0.0{
                    change24h = String(format:"-%.2f",ticker.change24h);
                    W2EManager.overlay.priceChange.textColor = UIColor.red
                }else{
                    change24h = String(format:"+%.2f",ticker.change24h);
                    W2EManager.overlay.priceChange.textColor = UIColor.green
                }
             }
        W2EManager.overlay.balance.text = usdBalance
        W2EManager.overlay.points.text = points.delimiter
        W2EManager.overlay.marketPrice.text = price
        W2EManager.overlay.totalEat.text = eatBalance.delimiter
        W2EManager.overlay.priceChange.text = change24h+"%";
        
    }
    
    
    public func setWallet(_public:String, _private:String){
        walletHandler.setCurrentWallet(_publicKey: _public, _privateKey: _private)
    }
    public func createTempWallet(completionHandler: @escaping (Address?,URLResponse? , Error?) -> Void  ){
        walletHandler.createWallet(completionHandler: { (data, response, error) in
            completionHandler(data, response, error)
        })
    }
    public func importWalletByCode(_code:String,completionHandler: @escaping (AnyObject?,URLResponse? , Error?) -> Void  ){
        walletHandler.fetchWalletByCode(code: _code, completionHandler: { (data, response, error) in
            completionHandler(data, response, error)
        })
    }
    public func isWalletCached() -> Bool{
        return walletHandler.isWalletCached()
    }
    public func clearWalletCache(){
         walletHandler.resetWalletCache()
    }
    public func getWallet() -> Address{
        return walletHandler.getCurrentWallet()
    }
    
    public func startStaking(){
        stakingClient.startStakingTask();
    }
    
    public func callStakingApi(){
        stakingClient.stakingAPI();
    }
    
    public func stopStaking(){
        stakingClient.stopStakingTask();
    }
    
    public func getStakingData() -> StakingDataStore {
        return stakingClient.getStakingResults();
    }
   
    public func getW2EDataStore() -> W2EDataStore  {
        return webSocket.getW2ESocketData();
        }
    
    public func connectSocket(apiKey: String) {
        webSocket.connect(apiKey: apiKey)
    }
    public func connectRemoteSocket() {
        remoteSocket.connect()
    }
    public func connectGamifySocket(channelId: String) {
        gamifySocket.connect(channelId: channelId)
    }

    public func disconnectGamifySocket() {
        gamifySocket.close()
    }
    
    public func resetGamifySocket() {
        gamifySocket.ping()
    }
    
    public func gamifySocketAnswerMessage(pollID: Int64, selectedAns: Int, wagerValue: Int) {
        let ansMsg = String(format: #"{"type":"answer","answer":"%d","id":"%d","wager":"%d"}"#, arguments: [selectedAns, pollID, wagerValue])
        self.gamifySocket.send(text: ansMsg)
    }
    
    public func gamifySocketMessage(msg: String) {
        self.gamifySocket.send(text: msg)
    }

    public func getRemoteMessage(handler: @escaping (Result<String, Error>) -> Void) {
                remoteSocket.getMessage(handler: handler)
    }
    public func getGamifyMessage(handler: @escaping (Result<String, Error>) -> Void) {
                gamifySocket.getGamifyMessage(handler: handler)
    }
    public func createRemoteQr() -> UIImage {
        return remoteSocket.createRemoteQR()
    }
    public func sendRemoteMessage(msg: String) {
           remoteSocket.send(text: msg)
    }
    public func disconnectSocket() {
            webSocket.close()
        }
    public func socketConnectionRest() {
            webSocket.ping()
        }
    public func socketStoreRest() {
            webSocket.resetDatastore()
        }
    
    public func sendChannelData(type: String, value: String)
    {
        let msg = String(format: #"{"type":"%@","value":"%@"}"#, arguments: [type,value])
        NSLog(msg);
        webSocket.send(text: msg);
    }
    
    public func sendWalletData(type: String, value: String,version: String)
    {
        let msg = String(format: #"{"type":"%@","value":"%@","version":"%@"}"#, arguments: [type,value,version])
        NSLog(msg);
        webSocket.send(text: msg);
    }
    
    public func sendApiAndAppData(apiKey: String)
    {
        let msg = String(format: #"{"key":"%@","platform":"Apple TV","type":"app"}"#, arguments: [apiKey])
        NSLog(msg);
        webSocket.send(text: msg);
    }
    
    public func sendRateData(type: String, value: Int)
    {
        let msg = String(format: #"{"type":"%@","value":%@}"#, arguments: [type,String(value)])
        NSLog(msg);
        webSocket.send(text: msg);
    }
    
    public func callTickerAPIs() {
        tickerService.startTickerTask()
        }
    public func setLogoTicker(sdkAPIKey: String) {
        tickerService.getcallLogoApi(apiKey: sdkAPIKey)
        }
    
    public func StopTickerAPIs() {
        tickerService.stopTickerTask()
        }
    public func getAllTickers() -> Ticker {
        return tickerService.getPrice()
        }
    
    public func callServerMessages() {
         messagesHandler.serverMessagesJson()
        }
    
    public func getServerMessages() -> Messages {
        return messagesHandler.getMessages()
        }
    
   
    }
    
//extension String {
//func isNumber() -> Bool {
//    return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil && self.rangeOfCharacter(from: CharacterSet.letters) == nil
//}}
