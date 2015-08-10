//
//  edgeDetection.h
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 01.07.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

#ifndef __bachelortehsis__edgeDetection__
#define __bachelortehsis__edgeDetection__

#include <stdio.h>
#include <stdlib.h>

#define MIN(a,b) (((a)<(b))?(a):(b))


#endif /* defined(__bachelortehsis__edgeDetection__) */


unsigned char* edge_detection(int width, int height,unsigned char* raw, int* edgePx);