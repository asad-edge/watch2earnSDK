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
    let isLive: Bool
    let promptText: String
    let streamHLS: String
    
    private enum CodingKeys: String, CodingKey {
        case channelAddress = "channel_address"
        case channelID = "channel_id"
        case channelName = "channel_name"
        case isGamified = "is_gamified"
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
        isLive = try container.decode(Bool.self, forKey: .isLive)
        promptText = try container.decode(String.self, forKey: .promptText)
        streamHLS = try container.decode(String.self, forKey: .streamHLS)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channelAddress, forKey: .channelAddress)
        try container.encode(channelID, forKey: .channelID)
        try container.encode(channelName, forKey: .channelName)
        try container.encode(isGamified, forKey: .isGamified)
        try container.encode(isLive, forKey: .isLive)
        try container.encode(promptText, forKey: .promptText)
        try container.encode(streamHLS, forKey: .streamHLS)
    }
}

class ChannelHandler: NSObject {
    
    func getChannelDetails(apiKey: String, completionHandler: @escaping ([Channel]?,URLResponse? , Error?) -> Void ) {
        
        let requestBody = channelRequestBody(apiKey: apiKey)
        
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(requestBody) else {
            // Handle encoding error
            return
        }
        
        let url = URL(string: "https://studio-api.edgevideo.com/channel/GetChannelDetailsByApiKey")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response data, response status code, and error
            if let error = error {
                print("Error with fetching channel details: \(error)")
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
        }
        task.resume()
        
    }
}

