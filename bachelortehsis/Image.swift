//
//  Image.swift
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 18.03.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

import Foundation
import UIKit

class Image {
    
    var image: UIImage
    var rawData: UnsafeMutablePointer<UInt8>!
    var edgeRaw: UnsafeMutablePointer<UInt8>!
    var width: Int
    var height: Int
    var rawLength: Int!

    
    init(image: UIImage) {
        self.image = image
        self.width = Int(image.size.width)
        self.height = Int(image.size.height)
        self.rawData = self.getRawData()
        self.edgeRaw = UnsafeMutablePointer<UInt8>.alloc(self.rawLength)
        self.edgeDetection()
    }
    
    
    private func rgb2Gray() -> CGImageRef {
        var imageRect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height);
        var colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceGray();
        var context: CGContextRef = CGBitmapContextCreate(nil, UInt(width), UInt(height), 8, 0, colorSpace, CGBitmapInfo(CGImageAlphaInfo.None.rawValue));
        
        CGContextDrawImage(context, imageRect, self.image.CGImage);
        var imageRef: CGImageRef = CGBitmapContextCreateImage(context);
        
        return imageRef;
    }
    
    
    private func getRawData() -> UnsafeMutablePointer<UInt8> {
        var imgRef = self.rgb2Gray()
        var imgData: CFDataRef = CGDataProviderCopyData(CGImageGetDataProvider(imgRef));
        var range: CFRange = CFRangeMake(0,CFDataGetLength(imgData));
        self.rawLength = range.length;
        var buffer = UnsafeMutablePointer<UInt8>.alloc(self.rawLength)
        CFDataGetBytes(imgData, range, buffer);
        
        return buffer;
    }
    
    
    


    private func edgeDetection() {
        var minValue: UInt8 = 255
        var condition: Bool = false
        
        var probe: [[UInt8]] = [[0,0,255,0,0], [0,255,255,255,0], [255,255,255,255,255], [0,0,255,0,0]]
        
        //iteration over image
        for var y = 0; y < height; y++ {
            for var x = 0; x < width; x++ {
                var index = width * y + x
                
                //iteration over probe
                for var i = -2; i <= 2; i++ {
                    for var j = -2; j <= 2; j++ {
                        var ind = width * (y + i) + (x + j)
                        var row: Int = y + i
                        var col: Int = x + j
                        
                        condition = (col >= 0) && (col < width) && (row >= 0) && (row < height)
                        
                        if condition {
                            var probeVal: UInt8 = probe[2 + i][2 + j]
                            var imgVal: UInt8 = rawData[ind]
                            var lukasiewicz: UInt8 = min(255, 255 - probeVal + imgVal)
                            minValue = minValue > lukasiewicz ? lukasiewicz : minValue
                        }
                    }
                }
                var tmp: UInt8 = min(255 - minValue, rawData[index]); //255 - minValue = negative of minValue
                edgeRaw[index] = tmp > 130 ? 255 : 0

            }
        }
    }
    
   
}