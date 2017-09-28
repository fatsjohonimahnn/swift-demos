//
//  ViewController.swift
//  UnwindSegueSave
//
//  Created by Jonathon Fishman on 9/18/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // We can override prepareForSegue in a UIViewController if we want to perform some
    // action before a Segue actually fires off. This is typically done to package up
    // some data that we wish to pass to the new UIViewControler that we're about to
    // move to.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "vcToVC2" {
            
            // Since we know that we're about to transition to VC2
            // we can use this moment to pass some data to it.
            let nextVC = segue.destination as! SecondViewController
            
            nextVC.currentName = userName.text
            nextVC.currentPhoto = userImage.image
            nextVC.navigationItem.title = userName.text
        }
    }

    @IBAction func onEditButton(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "vcToVC2", sender: sender)
    }
    
    @IBAction func unwindToPreviosVC(_ sender: UIStoryboardSegue) {
        
        if sender.source.isKind(of: SecondViewController.self) {
            
            // Since we know that we're transitioning back from the VC2
            // we can use this moment to retrieve some data from it.
            let prevVC = sender.source as! SecondViewController
            
            userName.text = prevVC.newName!
            userImage.image = prevVC.newPhoto!
        }
    }

}

