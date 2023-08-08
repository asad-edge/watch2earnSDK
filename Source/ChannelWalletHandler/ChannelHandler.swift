//
//  File.swift
//  
//
//  Created by Asad Iqbal on 09/01/2023.
//

import Foundation

struct channelRequestBody: Encodable {
    let apiKey: String
    // Add more properties as needed
}
public struct Channel: Codable {
    let channelAddress: String
    let channelID: String
    let channelName: String
    let isGamified: Bool
    let isW2E: Bool
    let isLive: Bool
    let streamHLS: String
    
    private enum CodingKeys: String, CodingKey {
        case channelAddress = "channel_address"
        case channelID = "channel_id"
        case channelName = "channel_name"
        case isGamified = "is_gamified"
        case isW2E = "is_w2e"
        case isLive = "live"
        case promptText = "prompt_text"
        case streamHLS = "stream_hls"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        channelAddress = try container.decode(String.self, forKey: .channelAddress)
        channelID = try container.decode(String.self, forKey: .channelID)
        channelName = try container.decode(String.self, forKey: .channelName)
        isGamified = try container.decode(Bool.self, forKey: .isGamified)
        isW2E = try container.decode(Bool.self, forKey: .isW2E)
        isLive = try container.decode(Bool.self, forKey: .isLive)
        streamHLS = try container.decode(String.self, forKey: .streamHLS)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channelAddress, forKey: .channelAddress)
        try container.encode(channelID, forKey: .channelID)
        try container.encode(channelName, forKey: .channelName)
        try container.encode(isGamified, forKey: .isGamified)
        try container.encode(isW2E, forKey: .isW2E)
        try container.encode(isLive, forKey: .isLive)
        try container.encode(streamHLS, forKey: .streamHLS)
    }
}

class ChannelHandler: NSObject {
    var apiHandler = APIHandler()
    
    func getChannelDetails(apiKey: String, completionHandler: @escaping ([Channel]?,URLResponse? , Error?) -> Void ) {
        
        let requestBody = channelRequestBody(apiKey: apiKey)
        
        let url = URL(string: "https://studio-api.edgevideo.com/channel/GetChannelDetailsByApiKey")!
        
        apiHandler.postAPICall(url: url, requestBody: requestBody, completionHandler: {(data, response, error) in
            
            if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let parsedChannels = try decoder.decode([Channel].self, from: data)
                    print("Channels Data: ", parsedChannels)
                    completionHandler(parsedChannels, nil, nil)
                }catch{
                    print("Details error: ",error)
                    completionHandler(nil, nil, error)
                }
            }
            
        })
    }
}
