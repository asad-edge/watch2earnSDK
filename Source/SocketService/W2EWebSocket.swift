//
//  W2EWebSocket.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 21/09/2022.
//

import Foundation
import Combine
import UIKit

@available(iOS 13.0, *)
@available(tvOS 13.0, *)
class W2EWebSocket: NSObject, URLSessionWebSocketDelegate {
    private var walletHandler = WalletHandler();
    public static var stores: W2EDataStore  = W2EDataStore(earning: 0.100, reward: 0.0, lastReward: 0.0, offchainBalance: 0.0, periodDuration: 0.0, lastRewardTime: "", w2eValues: (0,0,0,0,0,0) as AnyObject);
    private var apiKey: String!
    private var channelWallet: String!
    var isConnected = false
        var isConnecting = false
        var retryCount = 0
        var maxRetryCount = 5
        let retryInterval: TimeInterval = 5.0
    
    private let reachability = try? Reachability()
    
    public init(DataStore: W2EDataStore) {
        W2EWebSocket.stores = DataStore
    }

    private var session: URLSession!
    static private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    
    deinit {
        close()
    }
    
    func getW2ESocketData() -> W2EDataStore  {
        return W2EWebSocket.stores;
        }
    
    func connect(apiKey: String) {
        guard !isConnected && !isConnecting else {
                    return
                }
                
                self.apiKey = apiKey
                self.retryCount = 0
                self.close()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        W2EWebSocket.webSocketTask = session.webSocketTask(with: URL(string: "wss://faices-api.edgevideo.com/")!)
        W2EWebSocket.webSocketTask?.resume()
        startMonitoringReachability()
        print("web socket Connected..")
        
        listen()

    }
    
    // Start monitoring network reachability
        private func startMonitoringReachability() {
            reachability?.whenReachable = { [weak self] reachability in
                DispatchQueue.main.async {
                    print("Network is reachable")
                    if !self!.isConnected {
                        self?.connect(apiKey: self?.apiKey ?? "")
                    }
                }
            }
            
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    print("Network is unreachable")
                }
            }
            
            do {
                try reachability?.startNotifier()
            } catch {
                print("Failed to start reachability notifier")
            }
        }
    
    func send(text: String) {
        print("w2e socket msg: ",text)
        guard isConnected else {
                    print("Not connected. Retry or handle accordingly.")
                    return
                }
        let message = text;
        W2EWebSocket.webSocketTask?.send(.string(message)){ error in
            if let error = error {
                
                print("Error sending w2e message", error)
            }
        }
    }
    
    
    func listen() {
        
        W2EWebSocket.webSocketTask?.receive { [weak self] in
            print("web socket Listing..")
            switch $0 {
            case .success(let message):
                defer {
                    self?.listen()
                }
                switch message {
                case .data:
                    break
                case .string(let text):
                    print(text)
                    if text.contains("reward") {
                        let rewardObj: AnyObject? = text.jsonObjParse
                        print("Updated Reward")
//                        print(rewardObj ?? "")

                        let reward = rewardObj?["reward"] as! Double
                        W2EWebSocket.stores.reward = reward;
                    }
                    if text.contains("[") {
                        let jsonArray: AnyObject? = text.parseJSONArray
                        //print(jsonArray ?? "");
                        W2EWebSocket.stores.w2eValues = jsonArray!;
                        
                    }
                    if text.contains("justRewarded") {
                        let rewardedObj: AnyObject? = text.jsonObjParse
//                        print("wallet just Rewared")
//                        print(rewardedObj ?? "")
                        let lastReward = rewardedObj?["justRewarded"] as! Double
                        W2EWebSocket.stores.lastReward = lastReward;
                        let date = Date()
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = df.string(from: date)
                        W2EWebSocket.stores.lastRewardTime = dateString;
                        
                        let earn = W2EWebSocket.stores.reward * W2EWebSocket.stores.getRewardProportion;
                        W2EWebSocket.stores.earning = earn * 60;
                    }
                    if text.contains("offchainBalance") {
                        let offchainObj: AnyObject? = text.jsonObjParse

                        let offchainBalance = offchainObj?["offchainBalance"] as? Double
                        W2EWebSocket.stores.offchainBalance = offchainBalance ?? 0.0;
                    }
                    if text.contains("periodDuration") {
                        let durationObj: AnyObject? = text.jsonObjParse
                        
                        let periodDuration = durationObj?["periodDuration"] as! Double
                        W2EWebSocket.stores.periodDuration = periodDuration;
                    }
                    
                @unknown default:
                    break
                }
            case .failure(let error):
                print("failed error",error)
                self?.handleConnectionFailure(with: error)
            }
        }
    }
    
    func close() {
        timer?.invalidate()
        W2EWebSocket.webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func resetDatastore() {
        W2EWebSocket.stores.earning = 0.100
    }
    
    func ping() {
        W2EWebSocket.webSocketTask?.sendPing { error in
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                self.ping()
            }
        }
    }
    
    // Retry connection
        private func retryConnection() {
            guard retryCount < maxRetryCount else {
                print("Exceeded maximum retry attempts.")
                return
            }
            isConnected = false
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
                self?.connect(apiKey: self?.apiKey ?? "")
                
            }
        }
        
        // Handle connection failure
        private func handleConnectionFailure(with error: Error) {
            print("Connection failure:", error)
            retryCount += 1
            retryConnection()
        }
        
        // Handle connection reset by peer
        private func handleConnectionResetByPeer() {
            print("Connection reset by peer. Reconnecting...")
            retryConnection()
        }
    
    // Called when the WebSocket connection is successfully established
         func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
            print("WebSocket connection opened")
             isConnected = true
                 W2EManager.w2eSdk.sendWalletData(type: "wallet", value: W2EManager.w2eSdk.getWallet().public, version: "2.3")
                         W2EManager.w2eSdk.sendApiAndAppData(apiKey: self.apiKey)
                         W2EManager.w2eSdk.sendChannelData(type: "channel", value: "0x6E130D41C66559B5DC63CC32E233D907ABE457BF")
        }
        
        // Called when an error occurs during WebSocket connection
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                print("WebSocket connection failed with error:", error)
                handleConnectionFailure(with: error)
            } else {
                print("WebSocket connection closed")
                // Add any specific actions or logic to perform when the connection is closed
                isConnected = false
            }
        }
    
}
extension String {
    
    var jsonObjParse : AnyObject?{
        do{
            if let json = self.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
        
                    return jsonData as AnyObject;
                }
            }
        }catch {
            print(error.localizedDescription)
            return nil;
        }
        return nil;
    }

    
    var parseJSONArray: AnyObject?
    {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)

        if let jsonData = data
        {
            // Will return an object or nil if JSON decoding fails
            do
            {
                let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
                if let jsonResult = message as? NSMutableArray
                {

                    return jsonResult //Will return the json array output
                }
                else
                {
                    return nil
                }
            }
            catch let error as NSError
            {
                print("An error occurred: \(error)")
                return nil
            }
        }
        else
        {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}



