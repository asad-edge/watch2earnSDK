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
    @IBOutlet var icon: UIImageView!
    @IBOutlet var pointer: UIImageView!
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
        
        if(player.wallet_address == W2EManager.w2eSdk.getWallet().public){
            pointer.isHidden = false
            rank.isHidden = true
            starRank.isHidden = true
        }
        else if(player.id == 1) {
            starRank.isHidden = false
            rank.isHidden = true
        }else{
            starRank.isHidden = true
            rank.isHidden = false
            rank.text = String(player.id)
        }
        
        name.text = player.screen_name.uppercased()
        let countryCode = player.country_code
        print("Country Code: ", countryCode)
        let bundle = FlagKit.assetBundle
        let originalImage = UIImage(named: countryCode, in: bundle, compatibleWith: nil)
        flag.isHidden = false
        flag.image = originalImage
        flag.roundCorners(corners: [.allCorners], radius: 50)
        
        icon.load(url: URL(string:player.icon)!)
        icon.roundCorners(corners: [.allCorners], radius: 50)
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
