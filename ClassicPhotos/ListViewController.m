//
//  ListViewController.m
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import "ListViewController.h"

@implementation ListViewController
@synthesize photos = _photos;
@synthesize pendingOperations = _pendingOperations;

#pragma mark -
#pragma mark - Lazy instantiation


- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}


- (NSMutableArray *)photos {
    
    if (!_photos) {
        
        // 1: Create a NSURL and a NSURLRequest to points to the location of the data source.
        NSURL *datasourceURL = [NSURL URLWithString:kDatasourceURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
        
        // 2: Use AFHTTPRequestOperation class, alloc and init it with the request.
        AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        // 3: Give the user feedback, while downloading the data source by enabling network activity indicator.
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // 4: By using setCompletionBlockWithSuccess:failure:, you can add two blocks: one for the case where the operation finishes successfully, and one for the case where it fails.
        [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 5: In the success block, download the property list as NSData, and then by using toll-free bridging for data into CFDataRef and CFPropertyList, convert it into NSDictionary.
            NSData *datasource_data = (NSData *)responseObject;
            CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)datasource_data, kCFPropertyListImmutable, NULL);
            
            NSDictionary *datasource_dictionary = (__bridge NSDictionary *)plist;
            
            // 6: Create a NSMutableArray and iterate through all objects and keys in the dictionary, create a PhotoRecord instance, and store it in the array.
            NSMutableArray *records = [NSMutableArray array];
            
            for (NSString *key in datasource_dictionary) {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.URL = [NSURL URLWithString:[datasource_dictionary objectForKey:key]];
                record.name = key;
                [records addObject:record];
                record = nil;
            }
            
            // 7: Once you are done, point the _photo to the array of records, reload the table view and stop the network activity indicator. You also release the “plist” instance variable.
            self.photos = records;
            
            CFRelease(plist);
            
            [self.tableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            // 8: In case you are not successful, you display a message to notify the user.
            // Connection error message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            alert = nil;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        // 9: Finally, add “datasource_download_operation” to “downloadQueue” of PendingOperations.
        [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
    }
    return _photos;
}


#pragma mark -
#pragma mark - Life cycle


- (void)viewDidLoad {
    self.title = @"Classic Photos";
    self.tableView.rowHeight = 80.0;
    [super viewDidLoad];
}


- (void)viewDidUnload {
    [self setPhotos:nil];
    [self setPendingOperations:nil];
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning {
    [self cancelAllOperations];
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark - UITableView data source and delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.photos.count;
    return count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cell’s accessory view.
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
        
    }
    
    // 2: The data source contains instances of PhotoRecord. Get a hold of each of them based on the indexPath of the row.
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    // 3: Inspect the PhotoRecord. If its image is downloaded, display the image, the image name, and stop the activity indicator.
    if (aRecord.hasImage) {
        
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;
        
    }
    // 4: If downloading the image has failed, display a placeholder to display the failure, and stop the activity indicator.
    else if (aRecord.isFailed) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";
        
    }
    // 5: Otherwise, the image has not been downloaded yet. Start the download and filtering operations (they’re not yet implemented), and display a placeholder that indicates you are working on it. Start the activity indicator to show user something is going on.
    else {
        
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        
        if (!tableView.dragging && !tableView.decelerating) {
            [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
        }
    }
    
    return cell;
}


#pragma mark -
#pragma mark - Operations

// 1: To keep it simple, you pass in an instance of PhotoRecord that requires operations, along with its indexPath.
- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    // 2: You inspect it to see whether it has an image; if so, then ignore it.
    if (!record.hasImage) {
        
        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). You’ll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
        
    }
    
    if (!record.isFiltered) {
        [self startImageFiltrationForRecord:record atIndexPath:indexPath];
    }
}


- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        
        // 2: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        // Start downloading
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}


- (void)startImageFiltrationForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    // 3: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
        
        // 4: If not, start one by using the designated initializer.
        // Start filtration
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        
        // 5: This one is a little tricky. You first must check to see if this particular indexPath has a pending download; if so, you make this filtering operation dependent on that. Otherwise, you don’t need dependency.
        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if (dependency)
            [imageFiltration addDependency:dependency];
        
        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
    }
}


#pragma mark -
#pragma mark - ImageDownloader delegate


- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    // 2: Get hold of the PhotoRecord instance.
    PhotoRecord *theRecord = downloader.photoRecord;
    
    // 3: Replace the updated PhotoRecord in the main data source (Photos array).
    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
    
    // 4: Update UI.
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // 5: Remove the operation from downloadsInProgress (or filtrationsInProgress).
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}


#pragma mark -
#pragma mark - ImageFiltration delegate


- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration {
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    PhotoRecord *theRecord = filtration.photoRecord;
    
    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}


#pragma mark -
#pragma mark - UIScrollView delegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 1: As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
    [self suspendAllOperations];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2: If the value of decelerate is NO, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 3: This delegate method tells you that table view stopped scrolling, so you will do the same as in #2.
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}



#pragma mark -
#pragma mark - Cancelling, suspending, resuming queues / operations


- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
}


- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}


- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}


- (void)loadImagesForOnscreenCells {
    
    // 1: Get a set of visible rows.
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    // 2: Get a set of all pending operations (download and filtration).
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3: Rows (or indexPaths) that need an operation = visible rows – pendings.
    [toBeStarted minusSet:pendingOperations];
    
    // 4: Rows (or indexPaths) that their operations should be cancelled = pendings – visible rows.
    [toBeCancelled minusSet:visibleRows];
    
    // 5: Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    
    // 6: Loop through those to be started, and call startOperationsForPhotoRecord:atIndexPath: for each.
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
    
}




@end
