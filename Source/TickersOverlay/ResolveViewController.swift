//
//  ResolveViewController.swift
//  watch2earn-applesdk
//
//  Created by Asad Iqbal on 16/05/2023.
//

import UIKit

class ResolveViewController: UIView {
    
    @IBOutlet public var resolveView: UIView!
    @IBOutlet public var resolve_question: UILabel!
    @IBOutlet public var correct_ans: UILabel!
    @IBOutlet public var right_ans: UILabel!
    @IBOutlet public var results: UILabel!
    @IBOutlet public var wager_points: UILabel!
    @IBOutlet public var activeBorder: UILabel!
    @IBOutlet public var loading: UIImageView!
    
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

        }

        func loadViewFromNib() -> UIView {

            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "ResolveViewController", bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
            return view
        }
    
    func configure(with poll: Poll) {
        
        resolveView.roundCorners(corners: [.bottomLeft], radius: 50)
        correct_ans.roundCorners(corners: [.bottomLeft], radius: 40)

//        activeBorder.isInteractiveLabel = true
//        activeBorder.borderCorners = .bottomLeft
        resolve_question.text = poll.poll
        resolve_question.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 5)
        correct_ans.text = poll.choices[poll.selected!]
        correct_ans.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 3)
        if(poll.correct != nil){
            //wager_points.isHidden = true
            loading.isHidden = true
            if(poll.correct!.last! > 0){
                right_ans.text = "Correct"
                right_ans.textColor = .systemGreen
                right_ans.adjustFontSizeToFitWidth()
                results.isHidden = true
                right_ans.isHidden = false
            }else{
                results.text = "Wrong"
                results.textColor = .systemRed
                results.isHidden = false
                print("correct ans: ",poll.choices[poll.correct!.first!] )
                right_ans.text = poll.choices[poll.correct!.first!]
                right_ans.adjustFontSizeToFitWidth()
                right_ans.isHidden = false
            }
        }
        
        loading.loadGif(name: "dots_loading")
    }
    

}
