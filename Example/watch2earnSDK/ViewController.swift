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
        _ = W2EManager(sdkToken: "3bf76d424eeb0a1dcbdef11da9d148d8")
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

