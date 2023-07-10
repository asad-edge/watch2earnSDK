//
//  File.swift
//  
//
//  Created by Asad Iqbal on 04/01/2023.
//

import Foundation

public class CacheStorage: NSObject {
    
    private let walletCache: UserDefaults?
    
    public override init() {
        self.walletCache = UserDefaults.standard
        
    }
    
    public func saveString(_key: String, _value: String) {
        
        walletCache?.setValue(_value, forKey: _key)
    }
    
    public func getString(_key: String) -> String {
        
        return (walletCache?.string(forKey: _key)) ?? ""
    }
    
    public func saveAnyObject(_key: String, _value: AnyObject) {
        
        walletCache?.setValue(_value, forKey: _key)
    }
    
    public func getAnyObject(_key: String) -> AnyObject {
        
        return (walletCache?.object(forKey: _key)) as AnyObject
    }

    public func saveDouble(_key: String, _value: Double) {
        
        walletCache?.setValue(_value, forKey: _key)
    }
    
    public func getDouble(_key: String) -> Double {
        
        return (walletCache?.double(forKey: _key)) ?? 0.0
    }
    
    public func saveBool(_key: String, _value: Bool) {
        
        walletCache?.setValue(_value, forKey: _key)
    }
    
    public func getBool(_key: String) -> Bool {
        
        return (walletCache?.bool(forKey: _key))!
    }
    
    public func saveFloat(_key: String, _value: Float) {
        
        walletCache?.setValue(_value, forKey: _key)
    }
    
    public func getFloat(_key: String) -> Float {
        
        return (walletCache?.float(forKey: _key)) ?? 0.0
    }
    
    public func resetValue(_key: String) {
        
        walletCache?.removeObject(forKey: _key)
    }
    
}
