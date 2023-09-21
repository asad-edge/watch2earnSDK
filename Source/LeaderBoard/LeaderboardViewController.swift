//
//  LeaderboardViewController.swift
//  watch2earnSDK
//
//  Created by Asad Iqbal on 18/09/2023.
//

import UIKit

public class LeaderboardViewController: UIViewController {
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var players: UIView!
    let playersScrollView  = UIScrollView()
    let playersContentView = UIStackView()
    
    let topPlayerApi = LeaderboardApiData()
    
    var topPlayers:[Players] = []

    public override func viewDidLoad() {
        super.viewDidLoad()

        titleView.roundViewCorners(corners: [.allCorners], radius: 25)
        // Convert hex colors to UIColor
                guard let color1 = UIColor(hex: "#FF9966"),
                      let color2 = UIColor(hex: "#CC3333")
                else {
                    fatalError("Invalid hex color")
                }
        setupScrollView()
        setupContentView()
        fillDemoData()
        titleView.setGradientBackground(colors: [color1, color2])
    }
    
    private func fillDemoData() {
        
        topPlayerApi.getTopPlayers(completionHandler: {(data, response, error) in
            self.topPlayers = data!
            DispatchQueue.main.async {
                self.populatePlayers()
            }
        })
    }
    
    
    private func setupScrollView() {

        //setup polls scroll view and manage its constraints
        
        playersScrollView.backgroundColor = .clear
        players.addSubview(playersScrollView)
        playersScrollView.translatesAutoresizingMaskIntoConstraints = false
        playersScrollView.leadingAnchor.constraint(equalTo: players.leadingAnchor).isActive = true
        playersScrollView.trailingAnchor.constraint(equalTo: players.trailingAnchor).isActive = true
        playersScrollView.topAnchor.constraint(equalTo: players.topAnchor).isActive = true
        playersScrollView.bottomAnchor.constraint(equalTo: players.bottomAnchor).isActive = true
        }

        private func setupContentView() {

            //setup polls stack view and manage its constraints
            
            playersContentView.axis            = .vertical
            playersContentView.distribution    = .fill
            playersContentView.alignment       = .fill
            playersScrollView.addSubview(playersContentView)
            playersContentView.translatesAutoresizingMaskIntoConstraints = false
            playersContentView.leadingAnchor.constraint(equalTo: players.leadingAnchor).isActive = true
            playersContentView.trailingAnchor.constraint(equalTo: players.trailingAnchor).isActive = true
            playersContentView.topAnchor.constraint(equalTo: playersScrollView.topAnchor).isActive = true
            playersContentView.bottomAnchor.constraint(equalTo: playersScrollView.bottomAnchor).isActive = true
        }
    
    func populatePlayers() {
        
            playersContentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for player in topPlayers{
            let playerbar = PlayerBarViewController()
            playerbar.heightAnchor.constraint(equalToConstant: 90).isActive = true
            playersContentView.addArrangedSubview(playerbar)
            playerbar.configure(with: player)
        }
           
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
extension UIView{
    @objc func roundViewCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func setGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint = CGPoint(x: 1.0, y: 0.0)) {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            
            layer.insertSublayer(gradientLayer, at: 0)
        }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexNumber & 0x0000FF) / 255.0

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }

        return nil
    }
}
