//
//  ImageProcessing.h
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 04.03.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MyImage.h"



/**
    Class that provides functionality for comparing images.
 */
@interface ImageProcessing : NSObject {
    MyImage *_image;
    int _iterCount;
    UInt8** _navVectorArray;
}

@property (nonatomic, retain) MyImage* image;

- (id) initWithImage:(UIImage*) image;
- (CGPoint) compare:(MyImage*) image;
- (bool) isPointArroundCenter:(CGPoint) point;
@end
