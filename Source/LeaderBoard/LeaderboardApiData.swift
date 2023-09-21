//
//  LeaderboardApiData.swift
//  watch2earnSDK
//
//  Created by Asad Iqbal on 19/09/2023.
//

//
//  File.swift
//
//
//  Created by Asad Iqbal on 09/01/2023.
//

import Foundation


public struct Players:Codable{
    public var id: Int32
    public var screen_name: String
    public var country_code: String
    public var points: String
}

class LeaderboardApiData: NSObject {
    var apiHandler = APIHandler()
    
    func getTopPlayers(completionHandler: @escaping ([Players]?,URLResponse? , Error?) -> Void ) {
                
        let url = URL(string: "http://localhost:3000/gaimify/GetLeaderBoardByCountry/All/ba08370c-0362-462d-b299-97cc36973340/All")!
        
        apiHandler.getAPICall(url: url, completionHandler: {(data, response, error) in
            
            if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let parsedChannels = try decoder.decode([Players].self, from: data)
                    print("Top Players Data: ", parsedChannels)
                    completionHandler(parsedChannels, nil, nil)
                }catch{
                    print("Details error: ",error)
                    completionHandler(nil, nil, error)
                }
            }
            
        })
    }
}

