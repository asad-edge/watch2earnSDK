//
//  StakingDataStore.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 30/09/2022.
//

import Foundation

public struct StakingResult:Codable{
    public var estimate: Double
    public var minutes: Double
    public var balance: Double
    public var earned: Double
    public var hoursUntilStaking: Double
    public var maxBalance: Double
    public var time: Double? = 0.0
}

    struct Stake: Codable {
        var result: StakingResult
    }

public class StakingDataStore {
    private var _estimate: Double = 0.0
    private var _minutes: Double = 0
    private var _balance: Double = 0.0
    private var _maxBalance: Double = 0.0
    private var _earned: Double = 0.0
    private var _hoursUntilStaking: Double = 0.0
    private var _stakeAmount: Double = 0.0
    private var _stakePercentage: Double = 0.0
    private var _estimateAPY: Double = 0.0
    private var _time: Int64 = 0


    public init(estimate: Double, minutes: Double,balance: Double,maxBalance: Double,earned: Double,hoursUntilStaking:Double, stakeAmount: Double, stakePercentage:Double, estimateAPY:Double, time:Int64 ) {
        self._estimate = estimate
        self._minutes = minutes
        self._balance = balance
        self._maxBalance = maxBalance
        self._earned = earned
        self._hoursUntilStaking = hoursUntilStaking
        self._stakeAmount = stakeAmount
        self._stakePercentage = stakePercentage
        self._estimateAPY = estimateAPY
        self._time = time
    }

    public var estimate: Double {
        get {
            return self._estimate;
        }
        set {
            self._estimate = newValue
        }
    }
        
        public var time: Int64 {
            get {
                return self._time;
            }
            set {
                    self._time = newValue
            }
    }
    public var minutes: Double {
        get {
            return self._minutes;
        }
        set {
                self._minutes = newValue
            
        }
    }
    public var balance: Double {
        get {
            return self._balance;
        }
        set {
                self._balance = newValue
            
        }
    }
    public var maxBalance: Double {
        get {
            return self._maxBalance;
        }
        set {
                self._maxBalance = newValue
            
        }
    }
    public var earned: Double {
        get {
            return self._earned;
        }
        set {
                self._earned = newValue
            
        }
    }
    public var hoursUntilStaking: Double {
        get {
            return self._hoursUntilStaking;
        }
        set {
                self._hoursUntilStaking = newValue
            
        }
    }
    
    public var stakeAmount: Double {
        get {
            return self._stakeAmount;
        }
        set {
                self._stakeAmount = newValue
            
        }
    }
    public var stakePercentage: Double {
        get {
            return self._stakePercentage;
        }
        set {
                self._stakePercentage = newValue
            
        }
    }
    public var estimateAPY: Double {
        get {
            return self._estimateAPY;
        }
        set {
                self._estimateAPY = newValue
            
        }
    }
   
    
}
