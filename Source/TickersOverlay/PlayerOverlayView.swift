//
//  PlayerOverlayView.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 06/10/2022.
//

import UIKit
 
@IBDesignable public class PlayerOverlayView: UIView {
    
    @IBOutlet public var stakingStats: UILabel!
    @IBOutlet public var totalEat: UILabel!
    @IBOutlet public var marketPrice: UILabel!
    @IBOutlet public var priceChange: UILabel!
    @IBOutlet public var balance: UILabel!
    @IBOutlet public var staked: UILabel!
    @IBOutlet public var estApy: UILabel!
    @IBOutlet public var points: UILabel!
    @IBOutlet public var perHour: UILabel!
    @IBOutlet public var w2eMsg: UILabel!
    @IBOutlet public var gamificationMsg: UILabel!
    @IBOutlet public var gamificationView: UIView!
    @IBOutlet public var pollViews: UIView!
    @IBOutlet public var logo: UIImageView!
    @IBOutlet public var eat_logo: UIImageView!
    @IBOutlet public var qr_code: UIImageView!
    @IBOutlet public var progress_bar: UIProgressView!
    
    @IBOutlet public var pollQuestionsViews: UIView!
    @IBOutlet public var poll_q: UILabel!
    @IBOutlet public var opt_1: UIButton!
    @IBOutlet public var opt_2: UIButton!
    @IBOutlet public var opt_3: UIButton!
    @IBOutlet public var opt_4: UIButton!
    
    @IBOutlet public var pollAnsViews: UIView!
    @IBOutlet public var poll_q_r: UILabel!
    @IBOutlet public var opt_1_r: UIButton!
    @IBOutlet public var loading: UIImageView!
    
    // Our custom view from the XIB file
    public var view: UIView!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            xibSetup()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            xibSetup()
        }

        //FIXME:- Set up
        func xibSetup() {
            
            view = loadViewFromNib()
            view.frame = bounds
            view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            addSubview(view)
//            setupRemoteContoller()
            
//            pollQuestionsViews.roundCorners(corners: [.bottomRight], radius: 30)
//            opt_1.roundCorners(corners: [.bottomRight], radius: 20)
//            opt_2.roundCorners(corners: [.bottomRight], radius: 20)
//            opt_3.roundCorners(corners: [.bottomRight], radius: 20)
//            opt_4.roundCorners(corners: [.bottomRight], radius: 20)
//            pollAnsViews.becomeFirstResponder()
//            pollQuestionsViews.isUserInteractionEnabled = true
//            pollQuestionsViews.isAccessibilityElement = true
//
//            pollAnsViews.roundCorners(corners: [.bottomLeft], radius: 30)
//            opt_1_r.roundCorners(corners: [.bottomLeft], radius: 20)
//            loading.loadGif(name: "eatAnimated")

        }

        func loadViewFromNib() -> UIView {

            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "PlayerOverlayViews", bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
            return view
        }
    
//    func setupRemoteContoller() {
//        let menuPressRecognizer = UITapGestureRecognizer()
//        menuPressRecognizer.addTarget(self, action: #selector(menuButtonAction))
//        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue),
//                                                 NSNumber(value: UIPress.PressType.downArrow.rawValue)]
//        self.view.addGestureRecognizer(menuPressRecognizer)
//    }
//
//    @objc func menuButtonAction() {
//        print("The ovelay menu button is pressed")
//
//        func handleTap() {
//                view.isHidden = !view.isHidden
//
//                if !view.isHidden {
//                    // Set the focus to the poll menu view
//                    view.becomeFirstResponder()
//                } else {
//                    // Set the focus back to the AV player
//                    view.becomeFirstResponder()
//                }
//            }
//
//    }
    

        }
