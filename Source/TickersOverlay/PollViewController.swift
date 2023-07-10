//
//  PollViewController.swift
//  watch2earn-applesdk
//
//  Created by Asad Iqbal on 15/05/2023.
//

import UIKit

class PollViewController: UIView {

    @IBOutlet public var pollQuestionsViews: UIView!
    @IBOutlet public var poll_q: UILabel!
    @IBOutlet public var opt_1: UILabel!
    @IBOutlet public var opt_2: UILabel!
    @IBOutlet public var opt_3: UILabel!
    @IBOutlet public var opt_4: UILabel!
    @IBOutlet public var gamified_tv: UILabel!
    
    @IBOutlet public var view_opt_1: UIView!
    @IBOutlet public var view_opt_2: UIView!
    @IBOutlet public var view_opt_3: UIView!
    @IBOutlet public var view_opt_4: UIView!
    public var view: UIView!
    
    // Create a focus guide to control the focus movement within the poll view
        private var focusGuide: UIFocusGuide!

        // An array of focusable elements within the poll view
        private var focusableElements: [UIFocusEnvironment] = []
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            xibSetup()
            setupFocusGuide()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            xibSetup()
            setupFocusGuide()
        }

        //FIXME:- Set up
        func xibSetup() {
            
            view = loadViewFromNib()
            view.frame = bounds
            view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            addSubview(view)

        }
    
    private func setupFocusGuide() {
            focusGuide = UIFocusGuide()
            addLayoutGuide(focusGuide)

            // Set the focus guide's layout constraints to match the poll view's bounds
            focusGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            focusGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            focusGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
            focusGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

            // Make the focus guide focusable
            focusGuide.preferredFocusEnvironments = [self]

            // Assign appropriate focus movement properties for the focus guide
            focusGuide.preferredFocusEnvironments = focusableElements
            focusGuide.isEnabled = true
        }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
            return focusableElements
        }

        // Add your poll elements (labels, buttons, etc.) to the focusableElements array
        func addFocusableElement(_ element: UIFocusEnvironment) {
            focusableElements.append(element)
        }

        func loadViewFromNib() -> UIView {

            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "PollViewController", bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
            return view
        }
    
       func configure(with poll: Poll) {
           pollQuestionsViews.roundCorners(corners: [.bottomRight], radius: 50)
//           opt_1.roundCorner(corners: .bottomRight, radius: 30, borderWidth: 2.0, borderColor: .systemRed)
           view_opt_1.roundCorners(corners: [.bottomRight], radius: 40)
//           opt_2.roundCorners(corners: [.bottomRight], radius: 30)
           view_opt_2.roundCorners(corners: [.bottomRight], radius: 40)
//           opt_3.roundCorners(corners: [.bottomRight], radius: 30)
           view_opt_3.roundCorners(corners: [.bottomRight], radius: 40)
//           opt_4.roundCorners(corners: [.bottomRight], radius: 30)
           view_opt_4.roundCorners(corners: [.bottomRight], radius: 40)
           
           poll_q.text = poll.poll
           poll_q.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 5)
           opt_1.text = poll.choices[0]
           opt_1.isInteractiveLabel = true
           opt_1.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 3)
           opt_2.text = poll.choices[1]
           opt_2.isInteractiveLabel = true
           opt_2.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 3)
           opt_3.text = poll.choices[2]
           opt_3.isInteractiveLabel = true
           opt_3.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 3)
           opt_4.text = poll.choices[3]
           opt_4.isInteractiveLabel = true
           opt_4.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 3)
           gamified_tv.isInteractiveLabel = true
           
        }
    

}
