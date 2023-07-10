//
//  File 2.swift
//  
//
//  Created by Asad Iqbal on 21/12/2022.
//

import Foundation

public struct Address:Codable{
    public var `public`: String
    public var `private`: String
}

class WalletHandler {

    struct Wallet: Codable {
        var result: Address
    }
    private static var currentWallet = Address.init(public: "", private: "")
    private let walletCache = CacheStorage()
    
    func setCurrentWallet(_publicKey: String, _privateKey: String){
        WalletHandler.currentWallet = Address(public: _publicKey, private: _privateKey)
        self.walletCache.saveString(_key: "PUBLIC_KEY",_value: _publicKey)
        self.walletCache.saveString(_key: "PRIVATE_KEY",_value: _privateKey)
        print("SDK Current Wallet", self.getCurrentWallet())
     }
    
    func resetWalletCache(){
        walletCache.resetValue(_key: "PUBLIC_KEY");
        walletCache.resetValue(_key: "PRIVATE_KEY");
     }
    
    func getCurrentWallet() -> Address{
//        print("SDK WALLET",self.walletCache.string(forKey: "public"))

        return Address(public: self.walletCache.getString(_key: "PUBLIC_KEY"), private: self.walletCache.getString(_key: "PRIVATE_KEY"));
    }
    func isWalletCached() -> Bool{
        
        if ((self.walletCache.getString(_key: "PUBLIC_KEY").isEmpty) == false) {
            return true
        }
        else{
            return false
        }
    }
    
    func createWallet(completionHandler: @escaping (Address?,URLResponse? , Error?) -> Void ){
        
        guard let url = URL(string: "https://eat.edgevideo.com:8081/createWallet") else{
            return
        }

        
        let task = URLSession.shared.dataTask(with: url){
               data, response, error in
            
            if let error = error {
                    print("Error with creating wallet: \(error)")
                completionHandler(nil, nil ,error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                completionHandler(nil, response, nil)
                return
            }
               
               let decoder = JSONDecoder()

               if let data = data{
                   do{
                       let wallet = try decoder.decode(Wallet.self, from: data)
                       self.setCurrentWallet(_publicKey: wallet.result.public, _privateKey: wallet.result.private)
                       completionHandler(Address(public: wallet.result.public, private: wallet.result.private), nil, nil)
                   }catch{
                       print(error)
                   }
               }
           }
           task.resume()
    }
    
    func fetchWalletByCode(code:String, completionHandler: @escaping (AnyObject?,URLResponse? , Error?) -> Void ) {
        
        
        let url = URL(string:  "https://eat.edgevideo.com:8080/get_wallet/"+code)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                    print("Error with fetching wallet: \(error)")
                completionHandler(nil, nil ,error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                completionHandler(nil, response, nil)
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []){
                print(json)
                let jsonData = json as AnyObject
                let keys = jsonData.allKeys;
                if(keys?.first as! String == "error"){
                    print(jsonData["error"] as? String? as Any)
                    
                }else{
                    if WalletHandler.currentWallet.private != "" {
                        self.forwardingWalletAPI(pubKey: jsonData["wallet_address"] as! String)
                    } else{
                        self.setCurrentWallet(_publicKey: jsonData["wallet_address"] as! String, _privateKey: "")
                    }
                }
                
                completionHandler(jsonData, nil, nil)
            }
            
        })
        task.resume()
    }
    
    func forwardingWalletAPI(pubKey: String){
        print("Forwarding the wallet: ",pubKey)
        guard let url = URL(string: "https://eat.edgevideo.com:8081/forwardWallet") else{
            return
        }
        
        let req = URLRequest(url: url);
        
        // declare the parameter as a dictionary that contains string as key and value combination. considering inputs are valid
        let privKey = WalletHandler.currentWallet.private;
        let parameters: [String: Any] = ["privateKey": privKey, "toAddress": pubKey]

          // now create the URLRequest object using the url object
          var request = URLRequest(url: url)
          request.httpMethod = "POST" //set http method as POST
          
          // add headers for the request
          request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
          request.addValue("application/json", forHTTPHeaderField: "Accept")
          
          do {
            // convert parameters to Data and assign dictionary to httpBody of request
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
          } catch let error {
            print(error.localizedDescription)
            return
          }
          

        let task = URLSession.shared.dataTask(with: req){
               data, response, error in
               
            if let data = data{
                print(data)
                print("Forwarding the wallet: ",pubKey)
                self.setCurrentWallet(_publicKey: pubKey, _privateKey: "")
                
            }
           }
           task.resume()
    }

}
