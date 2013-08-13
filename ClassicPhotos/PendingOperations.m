//
//  PendingOperations.m
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations
@synthesize downloadsInProgress = _downloadsInProgress;
@synthesize downloadQueue = _downloadQueue;

@synthesize filtrationsInProgress = _filtrationsInProgress;
@synthesize filtrationQueue = _filtrationQueue;


- (NSMutableDictionary *)downloadsInProgress {
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download Queue";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)filtrationsInProgress {
    if (!_filtrationsInProgress) {
        _filtrationsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _filtrationsInProgress;
}

- (NSOperationQueue *)filtrationQueue {
    if (!_filtrationQueue) {
        _filtrationQueue = [[NSOperationQueue alloc] init];
        _filtrationQueue.name = @"Image Filtration Queue";
        _filtrationQueue.maxConcurrentOperationCount = 1;
    }
    return _filtrationQueue;
}

@end
