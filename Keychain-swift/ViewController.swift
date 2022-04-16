//
//  ViewController.swift
//  Keychain-swift
//
//  Created by Nilesh Kumar on 16/04/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        retreive()
        
    }
    
    func save(){
        do{
            try keychainManager.save(account: "test.com", service: "iOS Developer", password: "Password123".data(using: .utf8) ?? Data())
        }catch{
            print(error)
        }
    }
    
    func retreive(){
        guard let data = keychainManager.retrieve(account: "test.com", service: "iOS Developer") else {
            print("failed to retriev")
            return
        }
        
        let password = String(decoding: data, as: UTF8.self)
        print("password: \(password)")
    }


}

enum keychainErrors: Error{
    case duplicateItem
    case failedtoRetrieve
    case unknownError(OSStatus)
}

class keychainManager{
    
    static func save(
        account: String,
        service: String,
        password: Data
    ) throws{
        let query: [String: Any] = [
        
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: password as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecAttrService as String: service as AnyObject
            
        ]
        
       let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw keychainErrors.duplicateItem
        }
        
        guard status == errSecSuccess else {
            throw keychainErrors.unknownError(status)
        }
        
        print("saved")
    }
    
    static func retrieve(
        account: String,
        service: String
    ) -> Data?{
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject,
            kSecAttrService as String: service as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
            
        ]
        
        var result: AnyObject?
        
        let data = SecItemCopyMatching(query as CFDictionary, &result)
        
        
        return result as! Data
    }
}
