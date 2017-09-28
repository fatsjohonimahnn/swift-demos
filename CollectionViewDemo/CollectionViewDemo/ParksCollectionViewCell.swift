//
//  ParksCollectionViewCell.swift
//  CollectionViewDemo
//
//  Created by Jonathon Fishman on 9/26/17.
//  Copyright © 2017 fatsjohonimahnn. All rights reserved.
//

import UIKit

class ParksCollectionViewCell: UICollectionViewCell {
    
    var parkImageView: UIImageView!
    
    override func awakeFromNib() {
        parkImageView = UIImageView(frame: contentView.frame)
        parkImageView.contentMode = .scaleAspectFill
        parkImageView.clipsToBounds = true
        contentView.addSubview(parkImageView)
    }
}
