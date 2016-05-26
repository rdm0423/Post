//
//  Post.swift
//  Post
//
//  Created by Ross McIlwaine on 5/25/16.
//  Copyright © 2016 Ross McIlwaine. All rights reserved.
//

import Foundation

struct Post {
    
    private let usernameKey = "username"
    private let textKey = "text"
    private let timestampKey = "timestamp"
    private let uuidKey = "uuid"
    
    let username: String
    let text: String
    let timestamp: NSTimeInterval
    let identifier: NSUUID
    
    var endpoint: NSURL? {
        return PostController.baseURL?.URLByAppendingPathComponent(self.identifier.UUIDString).URLByAppendingPathExtension("json")
    }
    
    var jsonValue: [String: AnyObject] {
        
        let json: [String: AnyObject] = [
            usernameKey: self.username,
            textKey: self.text,
            timestampKey: self.timestamp,
            ]
        
        return json
    }
    
    var jsonData: NSData? {
        
        return try? NSJSONSerialization.dataWithJSONObject(self.jsonValue, options: NSJSONWritingOptions.PrettyPrinted)
    }
    
    init(username: String, text: String, identifier: NSUUID = NSUUID()) {
        
        self.username = username
        self.text = text
        self.timestamp = NSDate().timeIntervalSince1970
        self.identifier = identifier
    }
    
    init?(json: [String: AnyObject], identifier: String) {
        
        guard let username = json[usernameKey] as? String,
            let text = json[textKey] as? String,
            let timestamp = json[timestampKey] as? Double,
            let identifier = NSUUID(UUIDString: identifier) else {
                return nil
        }
        
        self.username = username
        self.text = text
        self.timestamp = NSTimeInterval(floatLiteral: timestamp)
        self.identifier = identifier
    }
    
}