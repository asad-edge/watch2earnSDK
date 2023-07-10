//
//  AnimateFigures.swift
//  watch2earn-applesdk
//
//  Created by Asad Iqbal on 23/05/2023.
//

import Foundation
import QuartzCore
import UIKit

class AnimateFigures {
    var currentBalance: Double = 0.0
    var targetBalance: Double = 0.0
    
    var points: UILabel?
 
    
    var displayTimer: Timer?
    var animationStartTime: TimeInterval = 0.0
    var animationDuration: TimeInterval = 20.0

    
    func updateBalance(newBalance: Double, animationTime: Double, pointsUI: UILabel) {
        animationDuration = animationTime
        targetBalance = newBalance
        points = pointsUI
        startBalanceAnimation()
    }
    
    func startBalanceAnimation() {
        animationStartTime = CACurrentMediaTime()
        
        displayTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleBalanceAnimation), userInfo: nil, repeats: true)
    }

    @objc func handleBalanceAnimation() {
        print("New Balance updating: ")
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - animationStartTime
        
        if elapsedTime >= animationDuration {
            // Animation completed, update the current balance to the target balance
            currentBalance = targetBalance
            print("New Balance updated: ")
            W2EManager.overlay.points.textColor = .white
            displayTimer?.invalidate()
            displayTimer = nil
        } else {
            // Calculate the interpolated balance value based on the elapsed time
            let progress = elapsedTime / animationDuration
            currentBalance = interpolate(start: currentBalance, end: targetBalance, progress: progress)
        }
        
        updateBalanceUI()
    }

    func interpolate(start: Double, end: Double, progress: Double) -> Double {
        return start + (end - start) * progress
    }

    func updateBalanceUI() {
        // Update the UI elements with the current balance value
        // For example, update a UILabel with the balance
        points?.text = String(format: "%.2f", currentBalance)
    }
    
    func stopBalanceAnimation() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

}
