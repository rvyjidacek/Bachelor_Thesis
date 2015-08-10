//
//  edgeDetection.c
//  bachelortehsis
//
//  Created by Roman Vyjídáček on 01.07.15.
//  Copyright (c) 2015 Roman Vyjídáček. All rights reserved.
//

#include "edgeDetection.h"


unsigned char* edge_detection(int width, int height, unsigned char* raw, int* edgePx) {
    unsigned char *edgeRaw = malloc(width * height * sizeof(unsigned char));
    unsigned char minValue = 255;
    char conditon;
    
    unsigned char probe[5][5] = {{0, 0, 255, 0, 0},
        {0, 255, 255, 255, 0},
        {255, 255, 255, 255, 255},
        {0, 255, 255, 255, 0},
        {0, 0, 255, 0, 0}};
    
    //Iteration over Photo
    for (int y = 0; y < height; y++) {
        long rowIndex = width * y;
        for (int x = 0; x < width; x++) {
            long index = rowIndex + x;
            
            //Iteration over Probe
            for (int i = -2; i <= 2; i++) {
                int rowInd = width * (y + i);
                for (int j = -2; j <= 2; j++) {
                    int ind = rowInd + (x + j);
                    int row = y + i;
                    int col = x + j;
                    
                    conditon = (col >= 0) && (col < width) && (row >= 0) && (row < height);
                    
                    if (conditon) {
                        unsigned char probeVal = probe[2 + i][2 + j];
                        unsigned char imgVal = raw[ind];
                        unsigned char lukasiewicz = MIN(255,255 - probeVal + imgVal);
                        minValue = minValue > lukasiewicz ? lukasiewicz : minValue;
                    }
                }
            }
            unsigned char tmp =  MIN(255 - minValue, raw[index]); //255 - minValue = negative of pixel
            
            //Transform grayscale image with edges into black-white.
            if (tmp > 130) {
                edgeRaw[index] = 255;
                edgePx++;
            } else {
                edgeRaw[index] = 0;
            }
            minValue = 255;
        }
    }
    return edgeRaw;
    
}




















