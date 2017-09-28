//
//  ViewController.swift
//  Animation Tests
//
//  Created by Jonathon Fishman on 10/18/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Constraint Animations
    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var menuPlusButton: UIButton!
    // Wire this to MenuView > Constraints Height = 60
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    // Wire this to MenuView > Constraints trailing = MenuButton
    @IBOutlet weak var closeButtonTrailing: NSLayoutConstraint!
    
    // Class Properties
    var isMenuExpanded = false
    var slider: HorizontalScrollView!
    var items = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider = HorizontalScrollView(inView: view)
        slider.didSelectItem = { item in
            self.transitionCloseMenu(item)
            self.showItem(item.tag)
        }
        slider.alpha = 0
        self.menuTitleLabel.superview!.addSubview(slider)
    }
    
    
    // MARK: Actions with Animations
    
    // Expand/contract the MenuView
    @IBAction func onMenuPlusButton(_ sender: AnyObject) {
        isMenuExpanded = !isMenuExpanded
        
        menuHeightConstraint.constant = isMenuExpanded ? 200.0 : 60.0
        closeButtonTrailing.constant = isMenuExpanded ? 16.0 : 8.0
        menuTitleLabel.text = isMenuExpanded ? "ExpandedMenuLabel" : "ShortMenuLabel"
        
        // Update constraints dynamically using identifier
        // Move the titleLabel to the left when menu opens
        for constraint in menuTitleLabel.superview!.constraints {
            // In SB click the view object > sizeIn > find constraint to change(align center x to superview) > add identifier
            if constraint.identifier == "TitleCenterX" {
                // change constraint for titleLabel horizontal alignment (x)
                constraint.constant = isMenuExpanded ? -100.0 : 0.0
            }
            // search and replace
            // change vertical alignment
            if constraint.identifier == "TitleCenterY" {
                // kill the constraint
                constraint.isActive = false
                
                let newConstraint = NSLayoutConstraint(item: menuTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: menuTitleLabel.superview!, attribute: .centerY, multiplier: isMenuExpanded ? 0.67 : 1.0, constant: 5.0)
                newConstraint.identifier = "TitleCenterY"
                newConstraint.isActive = true
            }
        }
        
        // Add the spring animation
        // notice very similar to the regular animation commented out below
        // Damping: closer to 1: no bouncing, closer to 0: lots of bouncing (will need more duration)
        // initialSpringVelocity: how forceful the animation looks 0, low force, 100 high force
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: [.curveEaseOut], animations: {
        
//        UIView.animate(withDuration: 0.33, delay: 0, options: [.curveEaseOut], animations: {
            
            // call layoutIfNeeded to make changes with animations
            self.view.layoutIfNeeded()
            // rotate plus sign to an x
            let angle = self.isMenuExpanded ? CGFloat(M_PI_4) : 0
            self.menuPlusButton.transform = CGAffineTransform(rotationAngle: angle)
            // fades in and out the slider control when the menu opens and closes
            self.slider.alpha = self.isMenuExpanded ? 1 : 0
        }, completion: nil)
    }
    
    // Create an animated preview of the icon when selected
    func showItem(_ index: Int) {
        //show the selected image in a preview
        let imageView  = UIImageView(image:
            UIImage(named: "randomicon_0\(index).png"))
        imageView.backgroundColor = UIColor(red: 0.15, green: 0.15,
                                            blue: 0.7, alpha: 0.5)
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        // create a horizontal alignment constraint, centering the imageView:
        let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        // create a vertical constraint to position the imageView in the parent view, leaving some margin
        let conBottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: imageView.frame.height)
        // set the imageView's width 1/3 of the view controller's width, minus 50
        let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33, constant: -50.0)
        // set the imageViews Height
        let conHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        
        // activate the constraints
        NSLayoutConstraint.activate([conX, conBottom, conWidth, conHeight])
        view.layoutIfNeeded()
        
        // animation code
        conBottom.constant = -imageView.frame.size.height/2
        conWidth.constant = 0.0
        UIView.animate(withDuration: 0.6, delay: 0.0,
            // add spring animation to a normal animation as before
            usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0,
            options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
//        UIView.animate(withDuration: 0.67, delay: 2.0, options: [], animations: {
//            conBottom.constant = imageView.frame.size.height
//            conWidth.constant = -50.0
//            self.view.layoutIfNeeded()
//        }, completion: {_ in
//            imageView.removeFromSuperview()
//        })
        
        // View transitions
        // Transition properties and methods that trigger a transition: isHidden, addSubview(), removeFromParent()
        // helper func found in appdelegate to keep the icon on screen
        delay(seconds: 1.0, completion: {
            
            UIView.transition(with: imageView, duration: 1.0,
                options: [UIViewAnimationOptions.transitionFlipFromBottom], animations: {
                    // need trigger code to create a transition
                    imageView.isHidden = true
                                
            }, completion: {_ in
                imageView.removeFromSuperview()
            })
        })
    }

    
    // Show PopUpViewController
    @IBAction func onPopUpButton(_ sender: UIButton) {
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoPopUpMenu") as! PopUpViewController
        
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    // Close menu with flip animation
    func transitionCloseMenu(_ item: UIView) {
        //add a view transition when close the menu
        delay(seconds: 0.35, completion: {
            self.onMenuPlusButton(self)
        })
        
        let titleBar = slider.superview!
        UIView.transition(with: titleBar, duration: 0.5, options: [.curveEaseOut, .transitionFlipFromBottom], animations: {
            // trigger the transition inside this animations closure
            // since titleBar is the parent view of slider, this will trigger the transition animation
            self.slider.removeFromSuperview()
        }, completion: {_ in
            // we don't want to permanently remove the slider
            // add it back to the view hierarchy once the animation is complete
            titleBar.addSubview(self.slider)
        })
    }

}

