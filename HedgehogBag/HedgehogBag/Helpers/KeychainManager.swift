//
//  KeychainManager.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 05.10.2022.
//

import Foundation

class KeychainManager {
    
    enum KeychainError: Error {
        case duplicate
        case someError(OSStatus)
    }
    
    static func saveToken(token: String) throws {
        let query = [
            kSecValueData: token.data(using: .utf8)!,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService as String: "yaDisc"
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicate
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.someError(status)
        }
        
        print("saveToken finished with status: \(status)")
    }
    
    static func getToken() -> Data? {
        let query: [String: AnyObject] = [
            kSecAttrService as String: "yaDisc" as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var ref: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &ref)
        
        print("Read status: ", status)
        return ref as? Data
    }
    
    func tryReadToken() -> String? {
        guard let data = KeychainManager.getToken() else {
            print("Failed to read token")
            return nil
        }
        
        let token = String(decoding: data, as: UTF8.self)
        return token
    }
    
    func deleteToken() throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: "yaDisc" as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: kCFBooleanTrue
        ]
                
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.someError(status)
        }
        print("deleteToken Success")
    }
}
