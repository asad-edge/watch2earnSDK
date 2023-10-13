//
//  ViewController.swift
//  watch2earnSDK
//
//  Created by asad926 on 07/10/2023.
//  Copyright (c) 2023 asad926. All rights reserved.
//

import UIKit
import watch2earnSDK
import AVFoundation
import AVKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        let manager = W2EManager(sdkToken: "976985bd857e79cc08f98bbe3a4fb290")
//        let VC = W2EManager.w2eSdk.getLeaderboardController();
        let VC = W2EManager.w2eSdk.getSettingScreen();
        super.viewDidLoad()
        self.view.addSubview(VC.view)
        self.addChildViewController(VC)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        let playerView = PlayerViewController()
//        playerView.title = "PokerNight"
//        present(playerView, animated: true, completion: nil)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

