//
//  ListUserViewController.swift
//  ChatLayout
//
//  Created by haipt on 11/8/16.
//  Copyright © 2016 haipt. All rights reserved.
//

import UIKit
import Firebase

class ListUserViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var listUser: [UserMsgModel] = []
    var userId: String?
    private var listUserRefId: UInt?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if userId != nil {
            self.title = "List friend of \(userId!)"
            //get list friend
            observerListFriend()
        } else {
            self.title = "List friend"
        }
    }
    
    func setUser(userId: String) {
        self.userId = userId
    }
    
    deinit {
        if listUserRefId != nil {
            ref.removeObserverWithHandle(listUserRefId!)
        }
    }
    
    func getListFriend() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ref.child("users").child(userId!).child("friends").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {[unowned self] (snapshot) in
            if let friends = snapshot.value as? [Dictionary<String, AnyObject>] {
                self.listUser.removeAll(keepCapacity: false)
                for friendDict in friends {
                    let user = UserMsgModel()
                    user.name = friendDict["name"] as! String
                    user.converId = friendDict["converid"] as! Int
                    user.numOfMsg = 0
                    self.listUser.append(user)
                }
            }
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func observerListFriend() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        listUserRefId = ref.child("users").child(userId!).child("friends").observeEventType(FIRDataEventType.Value, withBlock: {[unowned self] (snapshot) in
            if let friends = snapshot.value as? [Dictionary<String, AnyObject>] {
                self.listUser.removeAll(keepCapacity: false)
                for friendDict in friends {
                    let user = UserMsgModel()
                    if let name = friendDict["name"] as? String, converId = friendDict["converid"] as? Int {
                        user.name = name
                        user.converId = converId
                        user.numOfMsg = 0
                        self.listUser.append(user)
                    }
                }
            }
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ListUserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUser.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListUserCell", forIndexPath: indexPath) as! ListUserCell
        cell.loadData(listUser[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userData = listUser[indexPath.row]
        
        //call ChatView
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyBoard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        vc.setUser(self.userId!, friend: userData)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
