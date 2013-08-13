//
//  ImageFiltration.h
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//


// 1: Since you need to perform filtering on the UIImage instance, you need to import both UIKit and CoreImage frameworks. You also need to import PhotoRecord. Similar to ImageDownloader, you want the caller to alloc and init using the designated initializer.
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "PhotoRecord.h"

// 2: Declare a delegate to notify the caller once its operation is finished.
@protocol ImageFiltrationDelegate;

@interface ImageFiltration : NSOperation

@property (nonatomic, weak) id <ImageFiltrationDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate;

@end

@protocol ImageFiltrationDelegate <NSObject>
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration;
@end