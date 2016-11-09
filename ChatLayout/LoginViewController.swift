//
//  LoginViewController.swift
//  ChatLayout
//
//  Created by haipt on 11/8/16.
//  Copyright © 2016 haipt. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTF.text = "haipt"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginTouched() {
        if nameTF.text != "" { // 1
            FIRAuth.auth()?.signInAnonymouslyWithCompletion({[unowned self] (user, error) in
                if let err = error { // 3
                    print(err.localizedDescription)
                    return
                }
                
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc = storyBoard.instantiateViewControllerWithIdentifier("ListUserViewController") as! ListUserViewController
                vc.setUser(self.nameTF.text!)
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }

}
