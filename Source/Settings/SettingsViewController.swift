//
//  SettingsTabView.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 09/11/2022.
//

import UIKit
import _AVKit_SwiftUI

public class SettingsViewController: UIViewController {

    static var stStatus = "Connecting..";
    static var w2eStatus = "Connecting..";
    static var videoFlag = true;
    @IBOutlet var heading_1: UILabel!
    @IBOutlet var heading_3: UILabel!
    @IBOutlet var heading_2: UILabel!
    @IBOutlet weak var codeInput: UITextField!
    @IBOutlet var errorMsg: UILabel!
    @IBOutlet var w2eStatus: UILabel!
    @IBOutlet weak var stakeStatus: UILabel!
    @IBOutlet var loadingMsg: UILabel!
    @IBOutlet weak var eatGif: UIImageView!
    @IBOutlet weak var hideMark: UIButton!
    @IBOutlet weak var gamifyMark: UIButton!
    @IBOutlet weak var w2eOpt: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    @IBOutlet weak var watchIntro: UIButton!
    
    var timer: Timer = Timer();
    
    var jsonData: AnyObject?
    private var playerViewController: PopupViewController?

    public override func viewDidAppear(_ animated: Bool) {
        if(SettingsViewController.videoFlag){
            self.playIntroVideo()
        }
        errorMsg.text = ""
                W2EManager.w2eSdk.callStakingApi();
                self.changeFrame(label: heading_3, toOriginX: 40, toOriginY: heading_3.frame.origin.y, toWidth: heading_3.frame.width, toHeight: heading_3.frame.height, duration: 5.0)
                
                if(!W2EManager.hideGamifyBar){
                    gamifyMark.setImage(UIImage(systemName: "square"), for: UIControl.State.normal)
                }else{
                    gamifyMark.setImage(UIImage(systemName: "checkmark.square"), for: UIControl.State.normal)
                }
        if(!W2EManager.hideW2eBar){
            hideMark.setImage(UIImage(systemName: "square"), for: UIControl.State.normal)
        }else{
            hideMark.setImage(UIImage(systemName: "checkmark.square"), for: UIControl.State.normal)
        }
                if(!W2EManager.optW2e){
                    w2eOpt.setImage(UIImage(systemName: "square"), for: UIControl.State.normal)
                }else{
                    w2eOpt.setImage(UIImage(systemName: "checkmark.square"), for: UIControl.State.normal)
                }
                
                 super.viewDidAppear(true)
        
                
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){_ in
//                    if(W2EManager.w2eSdk.getRemoteMessage() == "DISCONNECTED"){
//                        self.remoteMsg.text = "Second Screen: DISCONNECTED";
//                    }else{
//                        self.remoteMsg.text = "Second Screen: CONNECTED";
//                    }
                    
                        self.stakeStatus.text = SettingsViewController.stStatus
                        self.stakeStatus.textColor = UIColor.green
            
                        self.w2eStatus.text = SettingsViewController.w2eStatus
                        self.w2eStatus.textColor = UIColor.green

                }
                eatGif.loadGif(name: "eatAnimated")
                if W2EManager.w2eSdk.isWalletCached(){
                    if W2EManager.w2eSdk.getWallet().private.isEmpty{
        //                self.heading_1.text = "Your app has been connected with wallet address:";
                        self.heading_2.text = "Your app has been connected with wallet address: "+W2EManager.w2eSdk.getWallet().public;
                        
                        codeInput.isHidden = true;
                        switchBtn.isHidden = false;
                    }else{
                        codeInput.isHidden = false;
                        switchBtn.isHidden = true;
                    }
                }else{
                    codeInput.isHidden = false;
                    switchBtn.isHidden = true;
                    W2EManager.w2eSdk.createTempWallet(completionHandler: { (data, response, error) in
                        W2EManager.w2eSdk.sendWalletData(type: "wallet", value: data!.public, version: "2.3")
                    });
                }
                // Do any additional setup after loading the view.
    }
    
    public override func viewDidLoad() {

        super.viewDidLoad()
        print("Setting screen loaded")
        self.timer.invalidate();
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true);
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        self.timer.invalidate();
    }
    
    
    @objc func timerAction(){
            let stakingData = W2EManager.w2eSdk.getStakingData();
            let socketData = W2EManager.w2eSdk.getW2EDataStore();

        if socketData.periodDuration > 0 {
            SettingsViewController.w2eStatus = "Active"
        }else{
            SettingsViewController.w2eStatus = "Connecting.."
        }
        
        if stakingData.balance == 0.0 && stakingData.maxBalance == 0.0
        {
            SettingsViewController.stStatus = "Connecting.."
        }else if(stakingData.balance < stakingData.maxBalance){
            SettingsViewController.stStatus = "Will resume in " + stakingData.hoursUntilStaking.formatHours()
        }else {
            SettingsViewController.stStatus = "Active"
        }
        
    }
    
    
    func playIntroVideo(){
        self.playerViewController = PopupViewController(nibName: "PopupViewController", bundle: Bundle(for: PopupViewController.self))
        self.playerViewController?.videoURL = URL(string: "https://edgevideopublic.s3.amazonaws.com/edge-intro-video-streams.m3u8")
        self.playerViewController?.modalPresentationStyle = .overCurrentContext
        self.playerViewController?.accessibilityViewIsModal = true
        self.playerViewController?.didMove(toParent: self);
//        self.addChild(self.playerViewController!)
        self.present(self.playerViewController!, animated: true)
        
        NotificationCenter.default.addObserver(self,selector: #selector(videoEnded) ,name: .AVPlayerItemDidPlayToEndTime, object: playerViewController?.player?.currentItem)
        SettingsViewController.videoFlag = false
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

        let transform = scaling.concatenating(translation)

        UIView.animate(withDuration: duration, animations: {
            label.transform = transform
        }) { _ in
            label.transform = .identity
            label.frame = newFrame
        }
    }

    @IBAction func textFieldEditingDone(_ sender: Any) {
        
        let code = String(codeInput.text ?? "");
        if code != "" {
            //        self.heading_1.text = ""
            self.heading_2.text = ""
            errorMsg.text = ""
            eatGif.isHidden = false
            loadingMsg.isHidden = false
            self.importWalletByCode(code)
        }
    }
    
    @IBAction func watch2earnIntro(_ sender: Any) {
        
        self.playIntroVideo()
    }
    
    
    @IBAction func switchWallet(_ sender: Any) {
        switchBtn.isHidden = true;
        codeInput.isHidden = false;
    }
    
//    @IBAction func skipVideo(_ sender: Any) {
//        player?.stopPlay()
//        player.isHidden = true
//    }
    
    @IBAction func autoHideOverlay(_ sender: Any) {
        hideMark.imageView?.contentMode = .scaleAspectFit
        if(W2EManager.hideW2eBar){
            hideMark.setImage(UIImage(systemName: "square"), for: UIControl.State.normal)
            W2EManager.hideW2eBar = false
        }else{
            hideMark.setImage(UIImage(systemName: "checkmark.square"), for: UIControl.State.normal)
            W2EManager.hideW2eBar = true;
        }
    }
    
    @IBAction func autoHideGamify(_ sender: Any) {
        gamifyMark.imageView?.contentMode = .scaleAspectFit
        if(W2EManager.hideGamifyBar){
            gamifyMark.setImage(UIImage(systemName: "square"), for: UIControl.State.normal)
            W2EManager.hideGamifyBar = false
        }else{
            gamifyMark.setImage(UIImage(systemName: "checkmark.square"), for: UIControl.State.normal)
            W2EManager.hideGamifyBar = true;
        }
    }
    @IBAction func w2eOptAction(_ sender: Any) {
        w2eOpt.imageView?.contentMode = .scaleAspectFit
        if(W2EManager.optW2e){
            w2eOpt.setImage(UIImage(systemName: "square"), for: UIControl.State.normal)
            W2EManager.w2eSdk.callStakingApi();
            W2EManager.optW2e = false
        }else{
            w2eOpt.setImage(UIImage(systemName: "checkmark.square"), for: UIControl.State.normal)
            W2EManager.w2eSdk.sendRateData(type: "rate", value: 0)
            W2EManager.w2eSdk.stopStaking();
            W2EManager.optW2e = true;
        }
    }
    
    
    func importWalletByCode(_ code: String) {
        print("code entered",code)
        W2EManager.w2eSdk.importWalletByCode(_code: code, completionHandler: { [self] (data, response, error) in
            let json = data as AnyObject
            let keys = json.allKeys;
            if(keys?.first as! String == "error"){
                DispatchQueue.main.async { [self] in
                    eatGif.isHidden = true
                    loadingMsg.isHidden = true
                    errorMsg.text = json["error"] as? String
                    if((errorMsg.text?.contains("ip address")) == true){
                    }
                }
            }else{
                DispatchQueue.main.async { [self] in
                    eatGif.isHidden = true
                    loadingMsg.isHidden = true
                    switchBtn.isHidden = false;
                    codeInput.isHidden = true;
                    errorMsg.text = ""
                    self.heading_1.text = "";
                    self.heading_2.text = String(format: #"Your app has been connected with wallet address: %@"#, arguments: [json["wallet_address"] as! String])
                    W2EManager.w2eSdk.sendWalletData(type: "wallet", value: json["wallet_address"] as! String, version: "2.3")
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false){_ in
                        W2EManager.w2eSdk.callStakingApi()
                    }
                    codeInput.text = ""
                    self.showToast(message: "Wallet is switched successfully.", font: .systemFont(ofSize: 32.0))
                    
                }
            }
        })
    }
    
    @objc private func videoEnded() {
        playerViewController?.player?.currentItem?.seek(to: CMTime.zero) { (finished) in
               if finished {
                   OperationQueue.main.addOperation { [weak self] in
                       self?.playerViewController?.player?.pause()
                       self?.playerViewController?.player?.replaceCurrentItem(with: nil)
                       self?.playerViewController?.topVC.dismiss(animated: true, completion: nil)
                       self?.playerViewController?.skipOverlayViewController.dismiss(animated: true, completion: nil)
                       self?.playerViewController?.dismiss(animated: true, completion: nil)
                       
                   }
               }
           }
       }
}

