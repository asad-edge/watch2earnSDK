//
//  MessagesHandler.swift
//  
//
//  Created by Asad Iqbal on 09/01/2023.
//


import Foundation


 public struct Messages:Codable{
     public let not_staking_no_balance: String
     public let not_staking_low_balance: String
     public let watch_2_earn_active: String
     public let staking_active: String
     public let wallet_not_forwarded: String
     public let landing_page_message_1: String
     public let catagory_page_message_1: String
}

public class MessagesHandler: NSObject {
    var apiHandler = APIHandler()

    private static var messages: Messages = Messages(not_staking_no_balance: "", not_staking_low_balance: "", watch_2_earn_active: "", staking_active: "", wallet_not_forwarded: "", landing_page_message_1: "", catagory_page_message_1: "")
    
    func getMessages() -> Messages {
        
        return MessagesHandler.messages;
    }

    func serverMessagesJson() {
        let url = URL(string: "https://livesearch.edgevideo.com/ticker-server/messages.json")!
        apiHandler.getAPICall(url: url, completionHandler: { (data, response, error) in
            
            if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let msgParse = try decoder.decode(Messages.self, from: data)
                    MessagesHandler.messages = msgParse
                    print("Messages: ",msgParse)
                    
                }catch{
                    print(error)
                }
            }
        })
            }
   
    }

