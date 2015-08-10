//
//  PhotoViewColCell.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 14.04.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

import Foundation
import UIKit


class PhotoViewColCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var index: Int!
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
    
    func getImage() -> UIImage {
        return self.imageView.image!
    }
    
    
    
}