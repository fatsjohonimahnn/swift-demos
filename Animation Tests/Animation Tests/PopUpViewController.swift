//
//  PopUpViewController.swift
//  Animation Tests
//
//  Created by Jonathon Fishman on 10/18/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onDismissButton(_ sender: UIButton) {
        
        //self.view.removeFromSuperview()
        self.removeAnimate()
    }
    
    // MARK: Animations
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion: {(finished: Bool) in
                if (finished) {
                    self.view.removeFromSuperview()
                }
        });
    }
}
