//
//  PlayerBarViewController.swift
//  watch2earnSDK
//
//  Created by Asad Iqbal on 19/09/2023.
//

import UIKit

class PlayerBarViewController: UIView {

    @IBOutlet var playerBar: UIView!
    @IBOutlet var rank: UILabel!
    @IBOutlet var starRank: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var flag: UIImageView!
    @IBOutlet var points: UILabel!
    
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
        let nib = UINib(nibName: "PlayerBarViewController", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func configure(with player: Players) {
        
        if(player.id == 1) {
            starRank.isHidden = false
            rank.isHidden = true
        }else{
            starRank.isHidden = true
            rank.isHidden = false
            rank.text = String(player.id)
        }
        
        name.text = player.screen_name
        let countryCode = player.country_code
        print("Country Code: ", countryCode)
        let bundle = FlagKit.assetBundle
        let countryFlag = Flag(countryCode: countryCode)!
        let styledImage = countryFlag.image(style: .circle)
        flag.isHidden = false
        flag.image = styledImage
        points.text = String(player.points) + " PTS"
        
        
        playerBar.roundViewCorners(corners: [.allCorners], radius: 25)
        // Convert hex colors to UIColor
                guard
                      let color1 = UIColor(hex: "#666666"),
                      let color2 = UIColor(hex: "#666633")
                else {
                    fatalError("Invalid hex color")
                }
        playerBar.setGradientBackground(colors: [color1, color2])
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
