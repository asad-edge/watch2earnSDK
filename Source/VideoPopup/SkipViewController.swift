//
//  SkipViewController.swift
//  FreebieTV
//
//  Created by Asad Iqbal on 20/01/2023.
//

import UIKit

class SkipViewController: UIViewController {
    
       var onSkip: (() -> Void)?
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setUpView()
       }
       
       // MARK: - Private
       
       lazy var skipButton: UIButton = {
           let skipButton = UIButton(type: .system)
           skipButton.isHidden = true
           skipButton.setTitleColor(.black, for: .normal)
           skipButton.setTitle("Skip", for: .normal)
           skipButton.sizeToFit()
           skipButton.addTarget(self, action: #selector(skipButtonWasPressed), for: .primaryActionTriggered)
           return skipButton
       }()
       
       private func setUpView() {
               view.addSubview(skipButton)
           skipButton.frame = CGRect(x: 1510, y: 870, width: 155, height: 60)
           
       }
       
       // MARK: - Actions
       
       @objc
       func skipButtonWasPressed() {
           onSkip?()
       }
   }
