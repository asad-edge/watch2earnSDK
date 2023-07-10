//
//  GamificationSocket.swift
//  watch2earn-applesdk
//
//  Created by Asad Iqbal on 03/05/2023.
//

import Foundation

import UIKit

public struct Poll:Codable{
    public var type: String
    public var poll: String
    public var mode: Int32
    public var id: Int64
    public var created: Int64
    public var correct: [Int]?
    public var selected: Int?
    public var choices: [String]
    
}

public struct Resolve:Codable{
    public var type: String
    public var id: Int64
    public var correct: [Int]?
    public var explanation: String
}

@available(tvOS 13.0, *)
open class GamificationSocket : NSObject, URLSessionWebSocketDelegate {
    public static var newPolls: [Poll] = []
    public static var resolve: [Resolve] = []
    var gamifyMessageHandler: ((Result<String, Error>) -> Void)?
    private var session: URLSession!
    static private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    private var channelID: String!
    var isConnected = false
        var isConnecting = false
        var retryCount = 0
        var maxRetryCount = 5
        let retryInterval: TimeInterval = 5.0
    
    private let reachability = try? Reachability()
    
    deinit {
        close()
    }
    
    public override init() {
    }
    
    func getGamifyMessage(handler: @escaping (Result<String, Error>) -> Void){
        self.gamifyMessageHandler = handler
    }
    
    
    
    func connect(channelId: String) {
        guard !isConnected && !isConnecting else {
                    return
                }
        self.close()
        self.retryCount = 0
        self.channelID = channelId
        print("Gamification Socket Connection!")
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        GamificationSocket.webSocketTask = session.webSocketTask(with: URL(string: "wss://gaimify.edgevideo.com")!)
        GamificationSocket.webSocketTask?.resume()
        listen()
    }
    
    // Start monitoring network reachability
        private func startMonitoringReachability() {
            reachability?.whenReachable = { [weak self] reachability in
                DispatchQueue.main.async {
                    print("Network is reachable")
                    if !self!.isConnected {
                        print("Gamified connect again")
                        self?.connect(channelId: self?.channelID ?? "")
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
        let message = text;
        guard isConnected else {
                    print("Not connected. Retry or handle accordingly.")
                    return
                }
        print("gamification msg:", message)
        GamificationSocket.webSocketTask?.send(.string(message)){ error in
            if let error = error {
                print("Error gaimify sending message", error)
            }
        }
    }
    
    func listen() {

        GamificationSocket.webSocketTask?.receive { [weak self] in
            switch $0 {
            case .success(let message):
                defer {
                    self?.listen()
                }
                switch message {
                case .data(_):
                    //print("returned data",data)
                    break
                case .string(let text):
                    print("Gamification msg recv: ", text)
                    if text.contains("type") {
                        print("gamify socket msg recieve: ", text)
                        let parseObj: AnyObject? = text.jsonObjParse
                        if(parseObj?["type"] as! String == "poll" ){
                            let pol = Poll(type: parseObj!["type"] as! String,
                                                        poll: parseObj!["poll"] as! String,
                                                        mode: parseObj!["mode"] as! Int32,
                                                        id: parseObj!["id"] as! Int64,
                                                        created: parseObj!["created"] as! Int64,
                                                        choices: parseObj!["choices"] as! [String])
//                            GamificationSocket.newPolls.removeAll(where: {$0.id == pol.id && $0.mode == pol.mode})
                            GamificationSocket.newPolls.removeAll()
                            GamificationSocket.newPolls.append(pol)
                            
                        }
                    }
                    self?.gamifyMessageHandler?(.success(text))
                    
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Gaimify Error",error)
                self?.handleConnectionFailure(with: error)
                self?.gamifyMessageHandler?(.failure(error))
            }
        }
    }
    
    func close() {
        timer?.invalidate()
        GamificationSocket.webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func ping() {
        GamificationSocket.webSocketTask?.sendPing { error in
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
                self?.connect(channelId: self?.channelID ?? "")
                
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
            print("Gaimify Connection reset by peer. Reconnecting...")
            retryConnection()
        }
    
    // Called when the WebSocket connection is successfully established
         public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
            print("Gaimify connection opened")
             isConnected = true
             startMonitoringReachability()
             let channelMsg = String(format: #"{"type":"channel","channel":"%@"}"#, arguments: [self.channelID])
             send(text: channelMsg)
             let walletMsg = String(format: #"{"type":"wallet","address":"%@"}"#, arguments: [W2EManager.w2eSdk.getWallet().public])
             send(text: walletMsg)
             
        }
        
        // Called when an error occurs during WebSocket connection
        public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                print("Gaimify connection failed with error:", error)
                handleConnectionFailure(with: error)
            } else {
                print("Gaimify connection closed")
                // Add any specific actions or logic to perform when the connection is closed
                isConnected = false
            }
        }
}
