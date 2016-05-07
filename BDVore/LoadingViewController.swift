//
//  LoadingViewController.swift
//  BDVore
//
//  Created by Julien Frisch on 5/5/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import UIKit


class LoadingViewController: UIViewController {

    //We use viewDidAppear instead of ViewDidLoad to make sure the UIAlertController will be properly displayed
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        //we check that there is a network connection
        if NetworkOperation.isConnectedToNetwork(){
            performSegueWithIdentifier("loadingOver", sender: nil)
        } else {
            // Create the alert controller
            let alertController = UIAlertController(title: "Erreur réseau", message: "BDVore n'a pas pu se connecter à internet!", preferredStyle: .Alert)
            
            // Create the action
            let okAction = UIAlertAction(title: "Quitter l'application", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                exit(0)
            }
            
            // Add the actions
            alertController.addAction(okAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
