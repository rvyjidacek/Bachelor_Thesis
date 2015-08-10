//
//  MyImage.m
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 20.03.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

#import "MyImage.h"

@implementation MyImage


- (id)initWithImage: (UIImage*) image {
    @autoreleasepool {
        CGRect bounds = CGRectMake(0, 0, 1024, 768);
        
        UIGraphicsBeginImageContext(bounds.size);
        [image drawInRect: CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
        UIImage *scaled = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self->_width = scaled.size.width;
        self->_height = scaled.size.height;
        self->_edgePx = 0;
        self->_edgeRaw = [self edgeDetection:scaled];
        return self;
    }
    
    
}

/**
    Convert coloful image into grayscale.
    @param photo is UIImage which you want convert to grayscale.
    @return CGImageRef of grayscale parameter photo.
 */
- (CGImageRef)rgb2gray: (UIImage*) photo {
    CGRect imageRect = CGRectMake(0, 0, photo.size.width, photo.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, photo.size.width, photo.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    CGContextDrawImage(context, imageRect, [photo CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return imageRef;
    
}


/**
    Get grayscale raw data from photo.
    @param photo is UIImage from which you vant get raw data.
    @return array of type UInt8.
 */
- (UInt8*)getRawData:(UIImage*) photo{
    @autoreleasepool {
        CGImageRef imgRef = [self rgb2gray:photo];
        CFDataRef imgData = CGDataProviderCopyData(CGImageGetDataProvider(imgRef));
        CFRange range = CFRangeMake(0,CFDataGetLength(imgData));
        self->_rawLength = (int) range.length;
        UInt8 *rawData = (UInt8*) calloc(range.length, sizeof(UInt8));
        
        CFDataGetBytes(imgData, range, rawData);
        
        return rawData;
    }
}


/**
    Detect edges in image.
    @param image is UIImage for detect edges.
    @return array of UInt8 with edges.
 */
- (UInt8*)edgeDetection: (UIImage*) image{
    @autoreleasepool {
        UInt8 *rawData = [self getRawData:image];
        return edge_detection(self->_width, self->_height, rawData, &self->_edgePx);
    }
    
}


/**
    Create UIImage from edges raw data.
    @return UIImage which contains edges.
 */
- (UIImage*)getEgdeImage {
    @autoreleasepool {
        CFDataRef data = CFDataCreate(NULL, _edgeRaw, _rawLength);
        
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
        CGColorSpaceRef colors = CGColorSpaceCreateDeviceGray();
        
        CGImageRef imageRef = CGImageCreate(_width, _height, 8, 8, _width, colors,
                                            kCGBitmapByteOrderDefault,
                                            provider, NULL, NO, kCGRenderingIntentDefault);
        
        UIImage *newImage = [UIImage imageWithCGImage:imageRef];
        return newImage;
    }
}


- (void) freeRawData {
    free(self->_edgeRaw);
}

@end
