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
    public var wallet_address: String
    public var screen_name: String
    public var country_code: String
    public var points: String
    public var icon: String
}

class LeaderboardApiData: NSObject {
    var apiHandler = APIHandler()
    
    func getTopPlayers(completionHandler: @escaping ([Players]?,URLResponse? , Error?) -> Void ) {
                
        let url = URL(string: "https://studio-api.edgevideo.com/gaimify/GetLeaderBoardByCountry/All/3bf76d424eeb0a1dcbdef11da9d148d8/All")!
        
        apiHandler.getAPICall(url: url, completionHandler: {(data, response, error) in
            
            if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let parsedChannels = try decoder.decode([Players].self, from: data)
                    completionHandler(parsedChannels, nil, nil)
                }catch{
                    print("Details error: ",error)
                    completionHandler(nil, nil, error)
                }
            }
            
        })
    }
}

