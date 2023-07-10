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
        TickersClient.oldPrice = TickersClient.currentPrice
        if  TickersClient.oldPrice != nil {
            TickersClient.oldPrice?.time = Date().timeIntervalSince1970
        }
        let url = URL(string: "https://eat.edgevideo.com/get_price")!
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
        task.resume()
        
    }
    func getcallLogoApi(apiKey: String){
        let requestBody = RequestBody(sdkAPIKey: apiKey)
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(requestBody) else {
            // Handle encoding error
            return
        }
        
        let url = URL(string: "https://studio-api.edgevideo.com/loadSdkLogo")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response data, response status code, and error
            if let error = error {
                print("Error with fetching logo: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []){
                print(json)
                let jsonData = json as AnyObject
                let rows = jsonData["data"] as AnyObject
                let data = rows[0] as AnyObject
                let logo = data["logo_url"];
                W2EManager.w2eSdk.tvLogo = URL(string: logo as! String)!
                W2EManager.overlay.logo.load(url: URL(string: logo as! String)!)
            }
        }
            task.resume()
        }
        
    }

