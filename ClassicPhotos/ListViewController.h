//
//  ListViewController.h
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//


// 1: You can delete CoreImage from ListViewController header, since you don’t need it anymore. However, you do need to import PhotoRecord.h, PendingOperations.h, ImageDownloader.h and ImageFiltration.h.
#import <UIKit/UIKit.h>
// #import <CoreImage/CoreImage.h> ... you don't need CoreImage here anymore.
#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"
// 2: Here’s the reference to the AFNetworking library.
#import "AFNetworking/AFNetworking.h"

#define kDatasourceURLString @"https://sites.google.com/site/soheilsstudio/tutorials/nsoperationsampleproject/ClassicPhotosDictionary.plist"

// 3: Make sure to make ListViewController compliant to ImageDownloader and ImageFiltration delegate methods.
@interface ListViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate>

// 4: You don’t need the data source as-is. You are going to create instances of PhotoRecord using the property list. So, change the class of “photos” from NSDictionary to NSMutableArray, so that you can update the array of photos.
@property (nonatomic, strong) NSMutableArray *photos; // main data source of controller

// 5: This property is used to track pending operations.
@property (nonatomic, strong) PendingOperations *pendingOperations;


@end