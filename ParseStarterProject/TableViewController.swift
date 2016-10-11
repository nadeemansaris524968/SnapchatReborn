//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Nadeem Ansari on 9/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import ParseUI

class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var usernames = [String]()
    var recipientUsername = ""

    func checkForMessages() {
        
        print("checking")
        
        let query = PFQuery(className: "image")
        query.whereKey("recipientUsername", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (images, error) in
            
            if error != nil {
                print(error)
            }
            else {
                if let pfObject = images {
                    
                    if pfObject.count > 0 {
                    
                        let imageView:PFImageView = PFImageView()
                        imageView.file = pfObject[0]["photo"] as? PFFile
                        imageView.loadInBackground({ (photo, error) in
                            
                            if error != nil {
                                print(error)
                            }
                            
                            else {
                                
                                var senderUsername = "Unknown user"
                                
                                if let username = pfObject[0]["senderUsername"] as? String {
                                    
                                    senderUsername = username
                                }
                                
                                let myAlert = UIAlertController(title: "You have a message!", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                                myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                                    
                                    print("OK")
                                    
                                    let backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                    backgroundView.backgroundColor = UIColor.blackColor()
                                    backgroundView.alpha = 0.8
                                    backgroundView.tag = 10
                                    backgroundView.contentMode = UIViewContentMode.ScaleAspectFit
                                    self.view.addSubview(backgroundView)
                                    
                                    let displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                    displayedImage.image = photo
                                    displayedImage.tag = 10
                                    displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                    self.view.addSubview(displayedImage)
                                    
                                    pfObject[0].deleteInBackground()
                                    
                                    _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(TableViewController.hideMessage), userInfo: nil, repeats: false)
                                    
                                }))
                                
                                self.presentViewController(myAlert, animated: true, completion: nil)
                            }
                            
                        })
                        
                    }
                }
            }
        }
    }
    
    func hideMessage() {
        
        for subview in self.view.subviews {
            
            if subview.tag == 10 {
                
                subview.removeFromSuperview()
                
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(TableViewController.checkForMessages), userInfo: nil, repeats: true)
        
        
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        
        query?.findObjectsInBackgroundWithBlock({ (users, error) in
            
            if error != nil {
                print(error)
            }
            else {
                
                for user in users! as! [PFUser] {
                    
                    self.usernames.append(user.username!)
                    
                }
                
                self.tableView.reloadData()
            }
        })
        

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        recipientUsername = usernames[indexPath.row]
        
        let image:UIImagePickerController = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let imageToSend = PFObject(className: "image")
        imageToSend["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(image, 0.5)!)
        imageToSend["senderUsername"] = PFUser.currentUser()?.username
        imageToSend["recipientUsername"] = recipientUsername
        
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        
        imageToSend.ACL = acl
        imageToSend.saveInBackground()
        
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logout" {
            
            PFUser.logOutInBackground()
            
        }
    }

}
