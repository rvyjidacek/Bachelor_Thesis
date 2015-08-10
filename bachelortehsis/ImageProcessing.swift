//
//  ImageProcessing.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 18.03.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

import Foundation
import UIKit

enum Position {case Top, Left, Right, Bottom}

class ImageProcessing {

    var image: Image
    var iterCount: Int
    
    init(image: UIImage, iterCount: Int) {
        self.image = Image(image: image)
        self.iterCount = iterCount
    }
    
    
    func compare(image: Image) -> Int {
        var imgToCompareRaw = image.edgeRaw
        var navigationRaw = UnsafeMutablePointer<UInt8>.alloc(image.rawLength)
        var width = image.width;
        var height = image.height;
        var same = 0;
        var position: Position
        var founded = false
        
        //Iteration over image
        for var y = 0; y < height; y++ {
            for var x = 0; x < width; x++ {
                var index = width * y + x; //Pixel index in Image
                var currentPx = self.image.rawData[index]; //Pixel at index in Original image

                if currentPx == 255 { //Test if pixel is an edge
                    founded = false
                    
                    for var iterRow = -iterCount; iterRow <= iterCount; iterRow++ {
                        for var iterCol = -iterCount; iterCol <= iterCount; iterCol++ {
                            var ind = width * (y + iterRow) + (x + iterCol);
                            var row = y + iterRow;
                            var col = x + iterCol;
                            
                            var conditon = (col >= 0) && (col < width) && (row >= 0) && (row < height);
                            
                            if conditon {
                                if imgToCompareRaw[ind] == currentPx {
                                    same++
                                    founded = true
                                    break
                                }
                            }
                        }
                        if founded {
                            break
                        }
                    }
                }
            }
        }
        return same
    }
    
    
    
    
    
}
