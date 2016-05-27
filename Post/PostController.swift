//
//  PostController.swift
//  Post
//
//  Created by Ross McIlwaine on 5/25/16.
//  Copyright © 2016 Ross McIlwaine. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = NSURL(string: "https://devmtn-post.firebaseio.com/posts/")
    static let endpoint = baseURL?.URLByAppendingPathExtension("json")
    
    weak var delegate: PostControllerDelegate?
    
    var posts: [Post] = [] {
        didSet {
            delegate?.postsUpdated(posts)
        }
    }
    
    init() {
        fetchPosts()
    }
    
    // MARK: - Add Posts
    func addPost(username: String, text: String) {
        
        let post = Post(username: username, text: text)
        
        guard let requestURL = post.endpoint else {
            fatalError("URL is Broker")
        }
        
        NetworkController.performRequest(requestURL, httpMethod: .put, body: post.jsonData) { (data, error) in
            
            let responseStringData = NSString(data: data!, encoding: NSUTF8StringEncoding) ?? ""
            
            if error != nil {
                print(error)
            } else if responseStringData.containsString("error") {
                print(responseStringData)
            }
            
            self.fetchPosts()
        }
        
    }
    
    // MARK: - Request
    
    func fetchPosts(reset reset: Bool = true, completion: ((newPosts: [Post]) -> Void)? = nil) {
        
        guard let requestURL = PostController.endpoint else {
            fatalError("Post Endpoint url failed")
        }
        
        let queryEndInterval = reset ? NSDate().timeIntervalSince1970 : posts.last?.queryTimestamp ?? NSDate().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        NetworkController.performRequest(requestURL, httpMethod: .get, urlParameters: urlParameters) { (data, error) in
            
            let responseDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            guard let data = data,
                let postDictionaries = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? [String: [String: AnyObject]] else {
                    
                    print("Unable to serialize JSON \(responseDataString)")
                    if let completion = completion {
                        completion(newPosts: [])
                    }
                    return
            }
            
            let posts = postDictionaries.flatMap({Post(json: $0.1, identifier: $0.0)})
            let sortedPosts = posts.sort({$0.0.timestamp > $0.1.timestamp})
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.appendContentsOf(sortedPosts)
                }
                
                if let completion = completion {
                    completion(newPosts: sortedPosts)
                }
                return
            })
        }
    }
}

protocol PostControllerDelegate: class {
    
    func postsUpdated(posts: [Post])
}