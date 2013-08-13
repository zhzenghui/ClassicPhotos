//
//  PhotoRecord.m
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord

@synthesize name = _name;
@synthesize image = _image;
@synthesize URL = _URL;
@synthesize hasImage = _hasImage;
@synthesize filtered = _filtered;
@synthesize failed = _failed;


- (BOOL)hasImage {
    return _image != nil;
}


- (BOOL)isFailed {
    return _failed;
}


- (BOOL)isFiltered {
    return _filtered;
}

@end