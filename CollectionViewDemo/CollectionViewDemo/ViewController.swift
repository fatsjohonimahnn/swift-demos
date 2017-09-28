//
//  ViewController.swift
//  CollectionViewDemo
//
//  Created by Jonathon Fishman on 9/26/17.
//  Copyright © 2017 fatsjohonimahnn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var images = [UIImage(named:"Arches"), UIImage(named:"Bryce_Canyon"), UIImage(named:"Denali"), UIImage(named:"Great_Sand_Dunes"), UIImage(named:"Joshua_Tree"), UIImage(named:"Katmai"), UIImage(named:"Sequoia"), UIImage(named:"Yosemite"), UIImage(named:"Zion")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
    }
    // initialize CV and add it to VC current View
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        // by default the cells will show as small separated squares
        layout.minimumLineSpacing = 0 // handles space between top and bottom cells
        layout.minimumInteritemSpacing = 0 // handles space between cells left and right
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(ParksCollectionViewCell.self, forCellWithReuseIdentifier: "parkCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self // letting compiler know the delegate will come from this ViewController class
        collectionView.dataSource = self //
        view.addSubview(collectionView)
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // UICollectionViewDelegateFlowLayout handles sizing of the cells
    
    
    // Specify number of sections in the CV
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
        return 1
    }
    
    // specify number of cells in the given section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 {
//            return 3
//        } else {
//            return 4
//        }
        return images.count
    }
    
    // handles layout of cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // need custom cell class
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "parkCell", for: indexPath) as! ParksCollectionViewCell
        
        cell.awakeFromNib()
        return cell
    }
    
    // called after cellForItem but before cell is displayed
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // set data
        let parkCell = cell as! ParksCollectionViewCell
        parkCell.parkImageView.image = images[indexPath.row]
    }
    
    // UICollectionViewDelegateFlowLayout method, handles size of the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
}
