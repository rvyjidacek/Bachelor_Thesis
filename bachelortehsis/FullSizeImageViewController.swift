//
//  FullSizeImageViewController.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 14.04.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

import Foundation

protocol FullSizeImageDeleteDelegate: class {
    func updateCellsAfterDeleteImageOnIndex(index: Int)
}


class FullSizeImageViewController : UIViewController {
    
    var images: Array<UIImage>!
    var chosenImageIndex: Int!
    var delegate: GalleryViewController?
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = images[chosenImageIndex]
        self.imageView.userInteractionEnabled = true
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipeGestureOnImageView:"))
        var swiperight = UISwipeGestureRecognizer(target: self, action: Selector("swipeGestureOnImageView:"))
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        swiperight.direction = UISwipeGestureRecognizerDirection.Right
        
        self.imageView.addGestureRecognizer(swipeLeft)
        self.imageView.addGestureRecognizer(swiperight)
    }
    
    
    @IBAction func deleteImage(sender: AnyObject) {
        images.removeAtIndex(chosenImageIndex)
        if  !images.isEmpty {
            chosenImageIndex = (chosenImageIndex + 1) % images.count
            self.imageView.image = images[chosenImageIndex]
            self.delegate?.updateCellsAfterDeleteImageOnIndex(chosenImageIndex)
        } else {
            self.imageView.image = nil
            self.delegate?.updateCellsAfterDeleteImageOnIndex(0)
        }
    }
    
    
    private func swipeRight() {
        chosenImageIndex = chosenImageIndex - 1
        if chosenImageIndex > 0 {
            chosenImageIndex = images.count - 1
            imageView.image = images[chosenImageIndex]
        } else {
            chosenImageIndex = 0
        }
    }
    
    private func swipeLeft() {
        chosenImageIndex = chosenImageIndex + 1
        if chosenImageIndex <= images.count - 1 {
            imageView.image = images[chosenImageIndex]
        } else {
            chosenImageIndex = images.count - 1
        }
    }
    
    
    func swipeGestureOnImageView(swipe: UISwipeGestureRecognizer) {
        if swipe.direction == UISwipeGestureRecognizerDirection.Left {
            self.swipeLeft()
        }
        
        if swipe.direction == UISwipeGestureRecognizerDirection.Right{
            self.swipeRight()
        }
        
    }

    

    
    @IBAction func saveImage(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(images[chosenImageIndex], nil, nil, nil)
        var alert = UIAlertView(title: "Uloženo", message: "Fotografie uložena", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
}