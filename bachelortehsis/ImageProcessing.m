//
//  ImageProcessing.m
//  EdgeDetectionSwift
//
//  Created by Roman Vyjídáček on 10.12.14.
//  Copyright (c) 2014 Roman Vyjídáček. All rights reserved.
//

#import "ImageProcessing.h"
#define EDGE_VALUE 255
#define ITERATION_COUNT 15

@implementation ImageProcessing

@synthesize image = _image;

    /** CONSTRUCTORS **/

- (id) initWithImage:(UIImage*) image {
    self->_image = [[MyImage alloc] initWithImage:image];
    self->_iterCount = ITERATION_COUNT;
    [self initNavVectorArray];
    return self;
}

-(id) init {
    [self initNavVectorArray];
    return self;
}

    /** CLASS METHODS **/

/**
    Alloc 2D array of size constast ITERATION_COUNT.
 */
- (void) initNavVectorArray {
    self->_navVectorArray = calloc(self->_iterCount, sizeof(UInt8*));
    
    for (int i = 0; i < self->_iterCount; i++) {
        self->_navVectorArray[i] = calloc(self->_iterCount, sizeof(UInt8));
    }
}


/**
    Fill 2D array of vectors with zeros.
 */
- (void) clearNavVectorArray {
    for (int row = 0; row < self->_iterCount; row++) {
        for (int col = 0; col < self->_iterCount; col++) {
            self->_navVectorArray[row][col] = 0;
        }
    }
}


/**
    Check if point have coordiantes the same as center point with tolerance +/- 3.
    @param point coordinates of direction vector.
    @return bool value.
 
 */
- (bool) isPointArroundCenter:(CGPoint) point {
    CGPoint center =  CGPointMake((int)(self->_iterCount), (int)(self->_iterCount / 2));
    CGPoint movePoint = CGPointMake(point.x / 5, point.y / 5);

    for (int row = -3; row <= 3; row++) {
        for (int col = -3; col <= 3; col++) {
            CGPoint newPoint = CGPointMake(center.x + col, center.y + row);
            if (CGPointEqualToPoint(newPoint, movePoint)) {
                return true;
            }
        }
    }
    
    return false;
}



/**
    Compute direction to move with iPhone.
    @return CGPoint with direction coordinates.
 */
- (CGPoint) computeNaviagtion {
    int maximum = 0;
    int x = 0, y = 0;
    
    for (int row = 0; row < self->_iterCount; row++) {
        for (int col = 0; col < self->_iterCount; col++) {
            int actualVector = self->_navVectorArray[row][col];
            if (actualVector > maximum) {
                maximum = actualVector;
                x = col;
                y = row;
            } else if (actualVector == maximum && [self isPointArroundCenter:CGPointMake(col, row)]) {
                x = col;
                y = row;
            }
        }
    }
    [self clearNavVectorArray];
    return CGPointMake(x * 5, y * 5);

}

/**
    Compare image from library with image from camera.
    @param image Object MyImage from camera.
    @return CGPoint with direction coordinates.
 */
- (CGPoint) compare:(MyImage *)image {
    UInt8* imgToCompareRaw = image.edgeRaw;
    int width = image.width;
    int height = image.height;
    int center = self->_iterCount / 2;
    
    //Iteration over image
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            long index = width * y + x; //Pixel index in Image
            UInt8 currentPx = _image.edgeRaw[index]; //Pixel at index in Original image
            
            if (currentPx == EDGE_VALUE) { //Test if pixel is an edge
                
                //iteration over Navigation vector array
                for (int iterRow = - center; iterRow <= center; iterRow++) {
                    for (int iterCol = - center; iterCol <= center; iterCol++) {
                        int navInd  = width * (y + iterRow) + (x + iterCol);
                        int rowIndex = (y + iterRow);
                        int colIndex = (x + iterCol);
                        
                        Boolean conditon = (colIndex >= 0) && (colIndex < width) && (rowIndex >= 0) && (rowIndex < height);
                        
                        if (conditon) {
                            if (imgToCompareRaw[navInd] == currentPx) {
                                self->_navVectorArray[center + iterRow][center + iterCol]++;
                            }
                            
                        }
                    }
                }
            }
        }
    }
    return [self computeNaviagtion];
}

@end
