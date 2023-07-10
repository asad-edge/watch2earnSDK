//
//  File.swift
//  
//
//  Created by Asad Iqbal on 04/01/2023.
//

import Foundation
import UIKit

@available(tvOS 13.0, *)
open class RemoteSocketService : NSObject {
    
    var messageHandler: ((Result<String, Error>) -> Void)?
    private let session = URLSession(configuration: .default)
    static private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    private var QRcode = QRcodeGenerator()
    private let qrRemoteCache = CacheStorage()
    private static var msg:RemoteMessages = RemoteMessages()
    
    deinit {
        close()
    }
    
    public override init() {
        
    }
    
    func getMessage(handler: @escaping (Result<String, Error>) -> Void){
        self.messageHandler = handler
    }
    
    func createRemoteQR() -> UIImage {
        
        return QRcode.generateQRCode(
            from: String(format: #"https://livesearch.edgevideo.com/qrRemote/?id=%@&wallet=%@"#, arguments: [qrRemoteCache.getString(_key: "SCREEN_ID"), qrRemoteCache.getString(_key: "PUBLIC_KEY")]))!
        
                }
    
    
    
    func connect() {
        let screenId = qrRemoteCache.getString(_key: "SCREEN_ID");
        RemoteSocketService.webSocketTask = session.webSocketTask(with: URL(string: "wss://qr.edgevideo.com")!)
        RemoteSocketService.webSocketTask?.resume()
        
        if(screenId.isEmpty){
            send(text: #"{"type": "create"}"#)
        }else{
            send(text: String(format: #"{"type":"set-screen","id":"%@"}"#, arguments: [screenId]))
        }
        listen()
    }
    
    func send(text: String) {
        let message = text;
        print(message)
        RemoteSocketService.webSocketTask?.send(.string(message)){ error in
            if let error = error {
                print("Error sending message", error)
            }
        }
    }
    
    func listen() {
        RemoteSocketService.webSocketTask?.receive { [weak self] in
            switch $0 {
            case .success(let message):
                defer {
                    self?.listen()
                }
                print("Remote Screen Message: ", message)
                switch message {
                case .data(let data):
                    print("returned data",data)
                    break
                case .string(let text):
                    print("returned string",text)
                    if text.contains("type") {
                        let parseObj: AnyObject? = text.jsonObjParse
//                        print("Updated Reward")
//                        print(rewardObj ?? "")

                        let screentId = parseObj?["id"] as! String
                        print("Save Screen ID",screentId )
                        self?.qrRemoteCache.saveString(_key: "SCREEN_ID", _value: screentId);
                    }else{
                        if text.isNumber() {
                            RemoteSocketService.msg.msgState = text;
                            self?.messageHandler?(.success(RemoteSocketService.msg.msgState))
                        }
                    }
                    
                @unknown default:
                    break
                }
            case .failure(let error):
                print("erereree",error)
                self?.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){ [self]_ in
                self?.connect()
                }
                self?.messageHandler?(.failure(error))
            }
        }
    }
    
    func close() {
        timer?.invalidate()
        RemoteSocketService.webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func ping() {
        RemoteSocketService.webSocketTask?.sendPing { error in
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                self.ping()
            }
        }
    }
}
