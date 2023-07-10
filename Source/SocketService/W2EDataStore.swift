//
//  W2EDataStore.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 22/09/2022.
//

import Foundation

public class W2EDataStore {
    private var _earning: Double = 0.0
    private var _reward: Double = 0.0
    private var _lastReward: Double = 0.0
    private var _offchainBalance: Double = 0.0
    private var _periodDuration: Double = 0.0
    private var _lastRewardTime: String = ""
    private var _w2eValues: AnyObject = (0,0,0,0,0,0) as AnyObject


    public init(earning: Double, reward: Double,lastReward: Double,offchainBalance: Double,periodDuration: Double,lastRewardTime: String,w2eValues: AnyObject ) {
        self._earning = earning
        self._reward = reward
        self._lastReward = lastReward
        self._lastRewardTime = lastRewardTime
        self._w2eValues = w2eValues
        self._offchainBalance = offchainBalance
        self._periodDuration = periodDuration
    }

    public var earning: Double {
        get {
            return self._earning;
        }
        set {
                self._earning = newValue
            
        }
    }
    public var reward: Double {
        get {
            return self._reward;
        }
        set {
                self._reward = newValue
            
        }
    }
    public var lastReward: Double {
        get {
            return self._lastReward;
        }
        set {
                self._lastReward = newValue
            
        }
    }
    public var lastRewardTime: String {
        get {
            return self._lastRewardTime;
        }
        set {
                self._lastRewardTime = newValue
            
        }
    }
    public var w2eValues: AnyObject {
        get {
            return self._w2eValues;
        }
        set {
                self._w2eValues = newValue
            
        }
    }
    public var offchainBalance: Double {
        get {
            return self._offchainBalance;
        }
        set {
                self._offchainBalance = newValue
            
        }
    }
    public var periodDuration: Double {
        get {
            return self._periodDuration;
        }
        set {
                self._periodDuration = newValue
            
        }
    }
    public var getPeriodId: Int {
        get {
            let id = self._w2eValues[0] ?? 00000
            return id as! Int ;
        }
    }
    public var getLiveScore: Double {
        get {
            let score = self._w2eValues[1] ?? 0000.0000
            return score as! Double;
        }
    }
    public var getLiveRankNumerator: Int {
        get {
            let rankN = self._w2eValues[2] ?? 00000
            return rankN as! Int;
        }
    }
    public var getLiveRankDenominator: Int {
        get {
            let rankD = self._w2eValues[3] ?? 00000
            return rankD as! Int;
        }
    }
    public var getRewardProportion: Double {
        get {
            let rewardP = self._w2eValues[4] ?? 0000.0000
            return rewardP as! Double;
        }
    }
    public var getTimeRemainingInPeriod: Int {
        get {
            let period = self._w2eValues[5] ?? 00000
            return period as! Int;
        }
    }
    
}
