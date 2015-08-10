//
//  MyImage.h
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 20.03.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "edgeDetection.h"

@interface MyImage : NSObject


@property UInt8 *edgeRaw;
@property int width;
@property int height;
@property int rawLength;
@property int edgePx;

- (id)initWithImage: (UIImage*) image;
- (UIImage*)getEgdeImage;
- (void) freeRawData;

@end
