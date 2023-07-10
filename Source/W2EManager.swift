//
//  W2EManager.swift
//  FreebieTV
//
//  Created by Asad Iqbal on 03/01/2023.
//

import Foundation
import UIKit

public class W2EManager {
    
    var timer: Timer = Timer();
    public static let w2eSdk = EarnifySDK()
    public static var channelWallets: [Channel]? = nil
    public static let settings = SettingsViewController()
    public static let overlay = w2eSdk.getTickerOverlay()
    private var channelHandler = ChannelHandler();
    private let cache = CacheStorage()
    public static var hideW2eBar: Bool = true
    public static var hideGamifyBar: Bool = true
    public static var optW2e: Bool = false
    public static var sdkKey: String?
    public init(sdkToken: String) {
        W2EManager.sdkKey = sdkToken;
            W2EManager.w2eSdk.setLogoTicker(sdkAPIKey:sdkToken )
        channelHandler.getChannelDetails(apiKey: sdkToken, completionHandler: {(data, response, error) in
                W2EManager.channelWallets = data
            })
         W2EManager.w2eSdk.callServerMessages()
//        W2EManager.w2eSdk.clearWalletCache();
//         W2EManager.w2eSdk.setWallet(_public: "0xDf515C6cA683773Ef6Cd93d5Ae3D21F951433771", _private: "")
    
          W2EManager.w2eSdk.connectRemoteSocket()

         W2EManager.w2eSdk.callTickerAPIs();
        NSLog("W2E manager app launched...");
        if (W2EManager.w2eSdk.isWalletCached()) {
//            W2EManager.w2eSdk.sendWalletData(type: "wallet", value: W2EManager.w2eSdk.getWallet().public, version: "2.3")
            print("Cached Wallet private:",W2EManager.w2eSdk.getWallet())
        }else{
            print("Creating wallet")
            W2EManager.w2eSdk.createTempWallet(completionHandler: {(data, response, error) in
                W2EManager.w2eSdk.sendWalletData(type: "wallet", value: data!.public, version: "2.3")
            });
        }
        W2EManager.w2eSdk.connectSocket(apiKey: sdkToken )
            }
   
    var timeIntervalLeft: Int = 0
    var stakingPercentagePre: Double = 0.0
    var offBalancePre: Double = 0.0
    var estimatePre: Double = 0.0
    var progressPre: Float = 0.0
    
    func loadStakingResults() {
        let data = W2EManager.w2eSdk.getStakingData();
            if(data.estimate != 0.0){
                print("Estimate",data.estimate);
                print("Minutes",data.minutes);
                print("Earned",data.earned);
                print("MaxBalance",data.maxBalance);
                print("HoursUntilStaking",data.hoursUntilStaking);
                print("Balance",data.balance);
                print("StakeAmount",data.stakeAmount);
                print("StakedPercentage",data.stakePercentage);
                print("EstimatedAPY",data.estimateAPY);

                
                print("--------------------------------------");
            }

        }
    
    @objc func showSocktsData() {
        while(true){
            let data = W2EManager.w2eSdk.getW2EDataStore();
                print("Period Id",data.getPeriodId);
                print("liveScore",data.getLiveScore);
                print("liveRankNumerator",data.getLiveRankNumerator);
                print("liveRankDenominator",data.getLiveRankDenominator);
                print("rewardProportion",data.getRewardProportion);
                print("timeRemainingInPeriod",data.getTimeRemainingInPeriod);
                print("lastReward",data.lastReward);
                print("lastRewardTimeAndDate",data.lastRewardTime);
                print("reward",data.reward);
                print("offchainBalance",data.offchainBalance);
                print("periodDuration",data.periodDuration);
                print("earning",data.earning);
                print("---------------------------------------------------");
               loadStakingResults()
            
            sleep(10)
        }
    }
}
extension String {
func isNumber() -> Bool {
    return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil && self.rangeOfCharacter(from: CharacterSet.letters) == nil
}
      func toInt64() -> Int64? {
        let number = Int64(self, radix: 10)
        if number == nil {
          return nil
        }
        return number
      }
}

extension Double {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter
    }()

    var delimiter: String {
        return Double.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    public func formatHours() -> String
        {
            let n = self
            if(n > 24)
            {
                let c = n/24.0
                return String(format: "%.2f DAYS", arguments: [c])
            }
            else if(n > 1)
            {
                return String(format: "%.2f HOURS", arguments: [n])
            }
            else
            {
                let c = n * 60.0
                return String(format: "%.2f MINUTES", arguments: [c])
            }
        }

}

extension UIViewController {
func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 225, y: self.view.frame.size.height-200, width: 550, height: 50))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UIView{
    @objc func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
extension UIButton {
    @objc override func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UILabel {
    static var activeBorderLayer = CAShapeLayer()
    static var borderLayer = CAShapeLayer()
    func roundCorner(corners: UIRectCorner, radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, isFocused: Bool) {
            let maskPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: CGSize(width: radius, height: radius))
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
        if isFocused {
            UILabel.activeBorderLayer.frame = bounds
            UILabel.activeBorderLayer.path = maskPath.cgPath
            UILabel.activeBorderLayer.lineWidth = borderWidth
            UILabel.activeBorderLayer.strokeColor = borderColor.cgColor
            UILabel.activeBorderLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(UILabel.activeBorderLayer)
        }else{
            UILabel.activeBorderLayer.removeFromSuperlayer()
        }
        }
    
    func adjustFontSizeToFitWidth() {
        guard let text = text else { return }
                
                let maxFontSize: CGFloat = 48 // Define the maximum font size
                let minFontSize: CGFloat = 22 // Define the minimum font size
                
                var fontSize = maxFontSize
                
                let labelSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
                var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
                
                while true {
                    let estimatedSize = text.boundingRect(with: labelSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                    
                    // Check if the estimated size fits within the label's bounds
                    if estimatedSize.height <= bounds.height && estimatedSize.width <= bounds.width {
                        break
                    }
                    
                    // Reduce the font size and update the attributes
                    fontSize -= 1
                    if fontSize < minFontSize {
                        fontSize = minFontSize
                        break
                    }
                    // Load the custom font
                    if let customFont = UIFont(name: "ProximaNova-Bold", size: fontSize) {
                        // Set the custom font for the label
                        attributes[NSAttributedString.Key.font] = customFont
                    } else {
                        // Fallback to system font if the custom font fails to load
                        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize:fontSize)
                    }
                }
    
        // Load the custom font
        if let customFont = UIFont(name: "ProximaNova-Bold", size: fontSize) {
            // Set the custom font for the label
            font = customFont
        } else {
            // Fallback to system font if the custom font fails to load
            font = UIFont.systemFont(ofSize:fontSize)
        }
            }
    
    func adjustFontToFitWidth(withLineBreakMode lineBreakMode: NSLineBreakMode = .byTruncatingTail, numberOfLines: Int = 5) {
            guard numberOfLines > 0 else {
                return
            }
            
            let originalFontSize = self.font.pointSize
            var currentFontSize = originalFontSize
            
            var textRect = self.textRect(forBounds: self.bounds, limitedToNumberOfLines: numberOfLines)
            while currentFontSize > self.minimumScaleFactor && textRect.size.width > self.bounds.size.width {
                currentFontSize -= 1.0
                self.font = self.font.withSize(currentFontSize)
                textRect = self.textRect(forBounds: self.bounds, limitedToNumberOfLines: numberOfLines)
            }
            
            self.numberOfLines = numberOfLines
            self.lineBreakMode = lineBreakMode
        }
}

