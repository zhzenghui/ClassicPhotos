//
//  ImageDownloader.h
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

// 1: Import PhotoRecord.h so that you can independently set the image property of a PhotoRecord once it is successfully downloaded. If downloading fails, set its failed value to YES.
#import "PhotoRecord.h"

// 2: Declare a delegate so that you can notify the caller once the operation is finished.
@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation

@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

// 3: Declare indexPathInTableView for convenience so that once the operation is finished, the caller has a reference to where this operation belongs to.
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

// 4: Declare a designated initializer.
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate;

@end

@protocol ImageDownloaderDelegate <NSObject>

// 5: In your delegate method, pass the whole class as an object back to the caller so that the caller can access both indexPathInTableView and photoRecord. Because you need to cast the operation to NSObject and return it on the main thread, the delegate method can’t have more than one argument.
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
@end