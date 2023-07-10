//
//  File.swift
//  
//
//  Created by Asad Iqbal on 04/01/2023.
//

import Foundation

class RemoteMessages {
    
    private var _msgState = "1"
    
    public var msgState: String {
        get {
            var _state = "";
            switch self._msgState {
            case "0":
                _state = "CONNECTED"
            case "1":
                _state = "DISCONNECTED"
            case "2":
                _state = "PLAY"
            case "3":
                _state = "PLAYING"
            case "4":
                _state = "PAUSE"
            case "5":
                _state = "PAUSED"
            case "6":
                _state = "MUTE"
            case "7":
                _state = "MUTED"
            case "8":
                _state = "UNMUTE"
            case "9":
                _state = "UNMUTED"
            case "16":
                _state = "BOOST"
            default:
                _state = "DISCONNECTED"
            }
            return _state;
        }
        set {
                self._msgState = newValue
        }
        
    }
}
