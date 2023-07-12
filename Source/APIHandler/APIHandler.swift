//
//  APIHandler.swift
//  watch2earnSDK
//
//  Created by Asad Iqbal on 11/07/2023.
//

import Foundation

class APIHandler: NSObject {
    
    func getJSONAPICall(url:URL, completionHandler: @escaping (AnyObject?,URLResponse? , Error?) -> Void ) {
        
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
                }
                completionHandler(jsonData, nil, nil)
            }
            
        })
        task.resume()
    }
    
    func getAPICall(url:URL, completionHandler: @escaping (Data?,URLResponse? , Error?) -> Void ) {
        
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
            
            if let data = data{
                completionHandler(data, nil, nil)
            }
        })
        task.resume()
    }
    
    func postAPICall(url: URL, requestBody: Encodable,  completionHandler: @escaping (Data?,URLResponse? , Error?) -> Void ) {
        
//        let requestBody = channelRequestBody(apiKey: apiKey)
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(requestBody) else {
            // Handle encoding error
            return
        }
                var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response data, response status code, and error
            if let error = error {
                print("Error with posting details: \(error)")
                completionHandler(nil, nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                completionHandler(nil, response, nil)
                return
            }
            
            if let data = data{
                     completionHandler(data, nil, nil)
                    }
        }
        task.resume()
        
    }

    
}
