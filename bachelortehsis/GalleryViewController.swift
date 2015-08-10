//
//  GalleryViewController.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 14.04.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

import Foundation


class GalleryViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FullSizeImageDeleteDelegate {
    
    private let reuseCellIdentifier = "PhotoCell"
    var imageArray: Array<UIImage>!

    
    
    @IBOutlet weak var imageCollectioView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCollectioView.reloadData()
        self.navigationController?.navigationBarHidden = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.imageCollectioView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: PhotoViewColCell = collectionView.dequeueReusableCellWithReuseIdentifier(self.reuseCellIdentifier, forIndexPath: indexPath) as! PhotoViewColCell
        
        cell.setImage(imageArray[indexPath.item])
        cell.index = indexPath.item
        
        return cell
    }
    
    
    func updateCellsAfterDeleteImageOnIndex(index: Int) {
        self.imageArray.removeAtIndex(index)
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fullSizeImage" {
            let senderCell = sender as! PhotoViewColCell
            let destinationVC = segue.destinationViewController as! FullSizeImageViewController
            destinationVC.images = self.imageArray
            destinationVC.delegate = self
            destinationVC.chosenImageIndex = senderCell.index
        }
    }
}
