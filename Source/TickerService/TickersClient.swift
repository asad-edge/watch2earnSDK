//
//  File.swift
//  
//
//  Created by Asad Iqbal on 21/12/2022.
//

import Foundation


public struct Ticker:Codable{
    public var price: Double
    public var change24h: Double
    public var time: Double? = 0
}
struct RequestBody: Encodable {
    let sdkAPIKey: String
    // Add more properties as needed
}


class TickersClient: NSObject {
    private var tickerThread:Thread?
    private static var oldPrice: Ticker? = nil
    private static var currentPrice: Ticker? = nil
    
    func Lerp(val1:Double, val2:Double, f:Double) -> Double
    {
        let fs = max(0.0, min(1.0, f));
        return (val1 * (1.0-fs)) + (val2 * fs);
    }
    
    func getPrice() -> Ticker {
        var currentTicker = Ticker(price: 0.0, change24h: 0.0)
        if TickersClient.oldPrice != nil && TickersClient.currentPrice != nil{
            let lerpFactor =  (Date().timeIntervalSince1970 - (TickersClient.oldPrice?.time ?? 0.0) ) / ((TickersClient.currentPrice?.time ?? 0.0) - (TickersClient.oldPrice?.time ?? 0.0) );
            
            let price = Lerp(val1: TickersClient.oldPrice!.price, val2: TickersClient.currentPrice!.price, f: lerpFactor)
            let change24 = Lerp(val1: TickersClient.oldPrice!.change24h, val2: TickersClient.currentPrice!.change24h, f: lerpFactor)
            
            currentTicker = Ticker(price: price, change24h: change24)
        }
        
        return currentTicker;
    }
    
    func startTickerTask()  {
        tickerThread = Thread(target: self, selector: #selector(self.callTickersAPI), object: nil)
        tickerThread?.start();
    }
    func stopTickerTask()  {
        tickerThread?.cancel();
    }
    
    @objc func callTickersAPI()  {
        while(true){
            tickersAPI()
            sleep(60)
        }
    }
    
    func tickersAPI() {
        var apiHandler = APIHandler()
        TickersClient.oldPrice = TickersClient.currentPrice
        if  TickersClient.oldPrice != nil {
            TickersClient.oldPrice?.time = Date().timeIntervalSince1970
        }
        let url = URL(string: "https://eat.edgevideo.com/get_price")!
        apiHandler.getAPICall(url: url, completionHandler: { (data, response, error) in
            
            if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let ticker = try decoder.decode(Ticker.self, from: data)
                    
                    TickersClient.currentPrice = ticker
                    TickersClient.currentPrice?.time = Date().timeIntervalSince1970+60.0
                    
                    if TickersClient.oldPrice == nil {
                        print("If old data doesn't exsit run once the time")
                        TickersClient.oldPrice = ticker
                        TickersClient.oldPrice?.change24h = 0.0
                        TickersClient.oldPrice?.time = Date().timeIntervalSince1970
                    }
                    
                    
                }catch{
                    print(error)
                }
            }
        })
        
    }
    func getcallLogoApi(apiKey: String){
        var apiHandler = APIHandler()
        let requestBody = RequestBody(sdkAPIKey: apiKey)
        let url = URL(string: "https://studio-api.edgevideo.com/loadSdkLogo")!

        apiHandler.postAPICall(url: url, requestBody: requestBody, completionHandler: { (data, response, error) in

            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []){
                print(json)
                let jsonData = json as AnyObject
                let rows = jsonData["data"] as AnyObject
                let data = rows[0] as AnyObject
                let logo = data["logo_url"];
                if logo as? Any.Type != NSNull.self {
                    print("logo api called", logo as Any)
                }else{
                    print("logo api called", logo as Any)
                    W2EManager.w2eSdk.tvLogo = URL(string: logo as! String)!
                    W2EManager.overlay.logo.load(url: URL(string: logo as! String)!)
                }
            }
        })
        }
        
    }

