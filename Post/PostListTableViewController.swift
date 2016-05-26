//
//  PostListTableViewController.swift
//  Post
//
//  Created by Ross McIlwaine on 5/25/16.
//  Copyright © 2016 Ross McIlwaine. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    let postController = PostController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        postController.delegate = self
        
    }
    
    @IBAction func addNewPostButtonTapped(sender: AnyObject) {
        
        presentNewPostAlert()
    }
    
    @IBAction func refreshControlPulled(sender: AnyObject) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        postController.fetchPosts({ (newPosts) in
            sender.endRefreshing()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postController.posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath)

        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(NSDate(timeIntervalSince1970: post.timestamp))"

        return cell
    }

    // MARK: ALERT CONTROLLERs - Add Post and Error
    
    func presentNewPostAlert() {
        
        let alertController = UIAlertController(title: "Make Post", message: "Add A New Post To Caleb's Database", preferredStyle: .Alert)
        var userNameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextFieldWithConfigurationHandler { (username) in
            username.placeholder = "Database Display Name"
            userNameTextField = username
        }
        alertController.addTextFieldWithConfigurationHandler { (message) in
            message.placeholder = "Your Message Here"
            messageTextField = message
        }
        
        let postAction = UIAlertAction(title: "TO THE CLOUD!!", style: .Default) { (action) in
            
            guard let username = userNameTextField?.text where !username.isEmpty,
                let text = messageTextField?.text where !text.isEmpty else {
                    self.presentErrorAlert()
                    return
            }
            self.postController.addPost(username, text: text)
        }
        let cancelAction = UIAlertAction(title: "Can't Commit to Cloud", style: .Cancel, handler: nil)
        
        alertController.addAction(postAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        
        let alertController = UIAlertController(title: "ISSUE", message: "Be sure all fields have been entered and/or check that network is connected", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Gotcha", style: .Cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension PostListTableViewController: PostControllerDelegate {
    
    func postsUpdated(posts: [Post]) {
        
        tableView.reloadData()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}