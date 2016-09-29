/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var msgLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBOutlet weak var username: UITextField!
    
    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" {
            msgLBL.text = "Enter a username"
        }
        
        else {
        
        PFUser.logInWithUsernameInBackground(username.text!, password: "password") { (user, error) in
            
            if let error = error {
                
                var user = PFUser()
                
                user.username = self.username.text!
                user.password = "password"
                user.signUpInBackgroundWithBlock({ (success, error) in
                    
                    if let error = error {
                        
                        self.msgLBL.text = (error.userInfo["error"]! as! String)
                        
                    }
                    
                    else {
                        print("Signed up")
                        self.performSegueWithIdentifier("showUserTable", sender: self)
                    }
                    
                })
                
            }
            
            else {
                print("Logged in")
                self.performSegueWithIdentifier("showUserTable", sender: self)
            }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil && PFUser.currentUser()?.objectId != nil {
            self.performSegueWithIdentifier("showUserTable", sender: self)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.hidden = true
    }
    
    
}