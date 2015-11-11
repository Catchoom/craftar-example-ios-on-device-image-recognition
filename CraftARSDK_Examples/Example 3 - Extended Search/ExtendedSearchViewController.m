// CraftARSDK_examples is free software. You may use it under the MIT license, which is copied
// below and available at http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 Catchoom Technologies S.L.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

#import "ExtendedSearchViewController.h"
#import <CraftAROnDeviceRecognitionSDK/CraftARSDK.h>
#import <CraftAROnDeviceRecognitionSDK/CraftAROnDeviceIR.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARCollectionManager.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARProtocols.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARCloudRecognition.h>
#import <CraftAROnDeviceRecognitionSDK/CrsConnect.h>

#define ON_DEVICE_COLLECTION_TOKEN @"imagerecognition"
#define CLOUD_COLLECTION_TOKEN     @"cloudrecognition"


@interface ExtendedSearchViewController () <CraftARSDKProtocol, CameraSearchController> {
    CraftARSDK *mSDK;
    CraftAROnDeviceIR *mOnDeviceIR;
    CraftARCollectionManager *mCollectionManager;
    CraftARCloudRecognition *mCloudRecognition;
    BOOL mReadyForCloudRecognition;
}

@end

@implementation ExtendedSearchViewController

#pragma mark view initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    
    // setup the CraftAR SDK
    mSDK = [CraftARSDK sharedCraftARSDK];
    
    // Become delegate of the SDK to receive capture initialization callbacks
    mSDK.delegate = self;
    
    // Initialize the video capture on our preview view.
    [mSDK startCaptureWithView:self._preview];
    self._previewOverlay.hidden = YES;
    self._scanningOverlay.hidden = YES;
}

#pragma mark -


#pragma mark Snap Photo mode implementation

- (void) didStartCapture {
    self._previewOverlay.hidden = NO;
    
    
    // Set this class as the CameraSearchController
    // with this, we will receive the events from the SDK when
    // the SingleShotSearch and FindeMode are used.
    [[CraftARSDK sharedCraftARSDK] setSearchControllerDelegate:myself];
    
    [self setUpOnDevice];
    [self cloudSetup];
}


#pragma mark On-device search setup

- (void) setUpOnDevice {
    // Get the Collection Manager
    mCollectionManager = [CraftARCollectionManager sharedCollectionManager];
    
    // Retrieve the collection if it is already in the device
    NSError* error;
    CraftAROnDeviceCollection* colleciton = [mCollectionManager getCollectionWithToken:ON_DEVICE_COLLECTION_TOKEN andError: &error];
    if (error != nil) {
        NSLog(@"Error getting collection: %@", error.localizedDescription);
    }
    
    if (colleciton) {
        // Load the collection found in the device
        [self loadCollection:colleciton];
    } else {
        // Add Collection bundle from the CraftAR Service
        ExtendedSearchViewController* myself = self;
        [mCollectionManager addCollectionWithToken:ON_DEVICE_COLLECTION_TOKEN withOnProgress:^(float progress) {
            NSLog(@"Add bundle progress: %f", progress);
        } andOnSuccess:^(CraftAROnDeviceCollection *collection) {
            // On success, we load the collection for recognition
            [myself loadCollection: collection];
        } andOnError:^(NSError *error) {
            NSLog(@"Error adding collection: %@", [error localizedDescription]);
        }];
    }
}

- (void) loadCollection: (CraftAROnDeviceCollection*) collection {
    // Get On Device Image Recognition class (for on-device searches)
    mOnDeviceIR = [CraftAROnDeviceIR sharedCraftAROnDeviceIR];
    
    // Load the collection before doing any searches
    ExtendedSearchViewController* myself = self;
    [mOnDeviceIR setCollection:collection setActive:YES withOnProgress:^(float progress) {
        NSLog(@"Load collection progress: %f", progress);
    } onSuccess:^{
        // Now the collection is ready to search
        NSLog(@"On-device collection is ready to search");
        // Enable the search button
        myself._previewOverlay.hidden = NO;
    } andOnError:^(NSError *error) {
        NSLog(@"Error adding collection: %@", [error localizedDescription]);
    }];
}

#pragma mark -


#pragma mark Cloud search setup

- (void) cloudSetup {
    
    
    mCloudRecognition = [CraftARCloudRecognition sharedCloudImageRecognition];
    [mCloudRecognition setCollectionWithToken:CLOUD_COLLECTION_TOKEN onSuccess:^{
        mReadyForCloudRecognition = YES;
    } andOnError:^(NSError *error) {
        NSLog(@"Could not set collection for Cloud recognition: %@", error.localizedDescription);
    }];
}

#pragma mark -


- (IBAction)snapPhotoToSearch:(id)sender {
    self._previewOverlay.hidden = YES;
    self._scanningOverlay.hidden = NO;
    [self._scanningOverlay setNeedsDisplay];
    [mSDK singleShotSearch];
}


#pragma mark CameraSearchController implementation

- (void) didTakePicture:(UIImage *)image {
    // First, perform on-device Image Recongition
    CraftARQueryImage* queryImage = [[CraftARQueryImage alloc] initWithUIImage:image];
    [mOnDeviceIR searchWithImage:queryImage withOnResults:^(NSArray *results) {
        
        // If no results are found, Extend search to the cloud, otherwise process results
        if (results.count == 0 && mReadyForCloudRecognition) {
            NSLog(@"Nothing found on the device, extend search to the cloud");
            [mCloudRecognition searchWithImage:queryImage withOnResults:^(NSArray *results) {
                [self processSearchResults:results];
            } andOnError:^(NSError *error) {
                [self searchFailedWithError:error];
            }];
            return;
        }
        [self processSearchResults:results];
    } andOnError:^(NSError *error) {
        [self searchFailedWithError:error];
    }];
}

- (void) didReceivePreviewFrame:(VideoFrame *)image {
    // Do nothing if you are not implementing Finder mode
}

- (void) didActivateFinderMode {
    // Do nothing if you are not implementing Finder mode
}

- (void) didDeactivateFinderMode {
    // Do nothing if you are not implementing Finder mode
}

- (BOOL) isFinding {
    // Always false if you are not implementing Finder mode
    return false;
}

#pragma mark -

- (void) processSearchResults:(NSArray *)resultItems {
    self._scanningOverlay.hidden = YES;
    
    if ([resultItems count] >= 1) {
        // Found one item, launch its content on a webView:
        CraftARSearchResult *bestResult = [resultItems objectAtIndex:0];
        CraftARItem *item = bestResult.item;
        
        NSString* alertText = [NSString stringWithFormat:@"Item found: '%@'", item.name];
        if (resultItems.count > 1) {
            alertText = [alertText stringByAppendingString: [NSString stringWithFormat:@" and %d more", (int)resultItems.count -1]];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:alertText];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"Ok"];
        [alert show];
        
        self._previewOverlay.hidden = NO;
        self._scanningOverlay.hidden = YES;
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Nothing found"];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"Ok"];
        [alert show];
        self._scanningOverlay.hidden = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self._previewOverlay.hidden = NO;
    [[mSDK getCamera] restartCapture];
}

- (void) searchFailedWithError:(CraftARError *)error {    // Check the error type
    NSLog(@"Error calling CRS: %@", [error localizedDescription]);
    self._previewOverlay.hidden = NO;
    self._scanningOverlay.hidden = YES;
    [[mSDK getCamera] restartCapture];
}

#pragma mark -


#pragma mark view lifecycle

- (void) viewWillDisappear:(BOOL)animated {
    [mSDK stopCapture];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

@end
