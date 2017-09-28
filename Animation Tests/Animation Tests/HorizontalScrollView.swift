//
//  HorizontalScrollView.swift
//  Animation Tests
//
//  Created by Jonathon Fishman on 1/20/17.
//  Copyright © 2017 fatsjohonimahnn. All rights reserved.
//

import UIKit

class HorizontalScrollView: UIScrollView {
    
    var didSelectItem: ((_ item: UIView)->())?
    
    let buttonWidth: CGFloat = 60.0
    let padding: CGFloat = 10.0
    
    convenience init(inView: UIView) {
        let rect = CGRect(x: 0, y: 120.0, width: inView.frame.width, height: 80.0)
        self.init(frame: rect)
        
        for i in 0 ..< 10 {
            let image = UIImage(named: "randomicon_0\(i).png")
            let imageView  = UIImageView(image: image)
            imageView.center = CGPoint(x: CGFloat(i) * buttonWidth + buttonWidth/2, y: buttonWidth/2)
            //imageView.backgroundColor = UIColor.red
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            addSubview(imageView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(HorizontalScrollView.didTapImage(_:)))
            imageView.addGestureRecognizer(tap)
        }
        
        contentSize = CGSize(width: padding * buttonWidth, height:  buttonWidth + 2*padding)
    }
    
    func didTapImage(_ tap: UITapGestureRecognizer) {
        didSelectItem?(tap.view!)
    }  
}
