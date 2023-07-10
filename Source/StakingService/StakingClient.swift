//
//  StakingClient.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 30/09/2022.
//

import Foundation

class StakingClient: NSObject {
    private static var stakeStore = StakingDataStore(estimate: 0.0, minutes: 0.0, balance: 0.0, maxBalance: 0.0, earned: 0.0, hoursUntilStaking: 0.0, stakeAmount: 0.0, stakePercentage: 0.0, estimateAPY: 0.0, time: 0);
    private static var currentData:StakingResult? = nil
    private static var oldData:StakingResult? = nil
    private var walletHandler = WalletHandler();
    private var stakingThread:Timer?
    private var currentWallet: String?
    public override init() {
    }
    
    func Lerp(val1:Double, val2:Double, f:Double) -> Double
        {
            let fs = max(0.0, min(1.0, f));
            return (val1 * (1.0-fs)) + (val2 * fs);
        }
    
    
    func getStakingResults() -> StakingDataStore  {
        
        if StakingClient.oldData != nil && StakingClient.currentData != nil{
//            print("old data time, ",StakingClient.oldData?.time)
//            print("current data time, ",StakingClient.currentData?.time)
//            print("current data diff, ",Date().timeIntervalSince1970 - StakingClient.oldData!.time!)
//            print("old data diff, ",(StakingClient.currentData?.time ?? 0.0) - (StakingClient.oldData?.time ?? 0.0))
            let lerpFactor =  (Date().timeIntervalSince1970 - (StakingClient.oldData?.time ?? 0.0) ) / ((StakingClient.currentData?.time ?? 0.0) - (StakingClient.oldData?.time ?? 0.0) );
//            print("lerpFactor time, ",lerpFactor)
            let earnedAmount = self.Lerp(val1: StakingClient.oldData!.earned, val2: StakingClient.currentData!.earned, f: lerpFactor);
            StakingClient.stakeStore.earned = earnedAmount
            
            if(StakingClient.currentData!.balance > StakingClient.currentData!.maxBalance)
            {
                let stakedPercentage = min(1440, self.Lerp(val1: StakingClient.oldData!.minutes, val2: StakingClient.currentData!.minutes, f: lerpFactor)) / 1440;
                
                let stakedAmount = stakedPercentage * self.Lerp(val1: StakingClient.oldData!.balance, val2: StakingClient.currentData!.balance, f: lerpFactor);
                let estimate = stakedPercentage * self.Lerp(val1: StakingClient.oldData!.estimate, val2: StakingClient.currentData!.estimate, f: lerpFactor);
//                print("estimate time, ",estimate)
//                var estApyHigh = 0.0;
//                var estApyLow = 0.0;
//                var estApy = 0.0;
//                if(stakedAmount > 0)
//                {
//                    estApyHigh = (estimate * 365) / stakedAmount;
//                    estApyLow = (estimate * 42.33334366) / stakedAmount;
//                    estApy = (estApyHigh - estApyLow)/2
//                }
                let hoursUntilStaking = self.Lerp(val1: StakingClient.oldData!.hoursUntilStaking, val2: StakingClient.currentData!.hoursUntilStaking, f: lerpFactor);
//                print("estApyHigh time, ",estApyHigh)
                StakingClient.stakeStore.estimate = estimate/24
                StakingClient.stakeStore.stakePercentage = stakedPercentage * 100
                StakingClient.stakeStore.stakeAmount = stakedAmount
                StakingClient.stakeStore.estimateAPY = (stakedPercentage * estimate * 365) / (stakedPercentage * stakedAmount)
                StakingClient.stakeStore.balance = StakingClient.currentData!.balance
                StakingClient.stakeStore.hoursUntilStaking = hoursUntilStaking
                StakingClient.stakeStore.maxBalance = StakingClient.currentData!.maxBalance
                StakingClient.stakeStore.minutes = StakingClient.currentData!.minutes
            }
            else{
                StakingClient.stakeStore.estimate = StakingClient.currentData!.estimate
                StakingClient.stakeStore.balance = StakingClient.currentData!.balance
                StakingClient.stakeStore.maxBalance = StakingClient.currentData!.maxBalance
                StakingClient.stakeStore.hoursUntilStaking = StakingClient.currentData!.hoursUntilStaking
                StakingClient.stakeStore.minutes = StakingClient.currentData!.minutes
            }
                            
        }
        
        return StakingClient.stakeStore
    }

    func startStakingTask()  {
        stopStakingTask()
        stakingAPI()
        stakingThread = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.stakingAPI), userInfo: nil, repeats: true);
    }
    func stopStakingTask()  {
        stakingThread?.invalidate();
        StakingClient.stakeStore = StakingDataStore(estimate: 0.0, minutes: 0.0, balance: 0.0, maxBalance: 0.0, earned: 0.0, hoursUntilStaking: 0.0, stakeAmount: 0.0, stakePercentage: 0.0, estimateAPY: 0.0, time: 0);
        StakingClient.oldData = nil
        StakingClient.currentData = nil
    }
    
    
    @objc func callStakingAPI()  {
        while(true){
            stakingAPI()
            sleep(60)
        }
    }
    
    @objc func stakingAPI() {
        print("Staking called")
        let currentWallet = walletHandler.getCurrentWallet().public
        StakingClient.oldData = StakingClient.currentData
        
        if  StakingClient.oldData != nil {
            StakingClient.oldData?.time = Date().timeIntervalSince1970
//            StakingClient.oldData?.estimate = 0.0
//            StakingClient.oldData?.minutes = 0.0
            print("If old data exsit just change the time")
        }
        
        let url = (URL(string: "https://staking.edgevideo.com:8080/get_staking_status/"+currentWallet)!)
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching wallet: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            let decoder = JSONDecoder()
            
            if let data = data{
                do{
                    let stake = try decoder.decode(Stake.self, from: data)
                    print(stake.result)
                    StakingClient.currentData = stake.result
                    StakingClient.currentData!.estimate = StakingClient.currentData!.estimate > 0.00000001 ? StakingClient.currentData!.estimate : 0;
                    StakingClient.currentData!.balance = StakingClient.currentData!.balance > 0.00000001 ? StakingClient.currentData!.balance : 0;
                    
                    StakingClient.currentData?.time = Date().timeIntervalSince1970+60.0
                    
                    if StakingClient.oldData == nil {
                        print("If old data doesn't exsit run once the time")
                        StakingClient.oldData = stake.result
                        StakingClient.oldData?.time = Date().timeIntervalSince1970
                        StakingClient.oldData?.estimate = 0.0
                        StakingClient.oldData?.minutes = 0.0
                        
                    }
                    
                }catch{
                    print(error)
                }
            }
        })
        task.resume()
        
    }
    
    }

