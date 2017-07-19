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
#import <CraftAROnDeviceRecognitionSDK/CraftARProtocols.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARCloudRecognition.h>
#import <CraftAROnDeviceRecognitionSDK/CrsConnect.h>

#import "ExtendedSearchController.h"

#define CLOUD_COLLECTION_TOKEN     @"cloudrecognition"

/**
 * This example shows how to perform extended image recognition using the single-shot mode,
 * using on-device image recognition + cloud image recognition.
 *
 * The example will load an on-device collection and search always first in the on-device collection.
 * If nothing is found in the on-device collection, and there's connectivity, it will search it in
 * the cloud collection, which is supposed to have a different content than the on-device collection, so
 * we expect to find a match there.
 *
 * Extended image recognition is useful if you want to pre-fetch some images into the application (in an on-device collection),
 * because they're more likely to be scanned, so you skip searching into the cloud for all those requests. Note that the size of
 * on-device collection affects the size of the app, but the size of the cloud collection don't.
 *
 *
 * How to use:
 *
 * You can find the Reference images in the Reference Images folder of this project:
 *
 * The on-device collection contains the images biz_card and shopping_kart.
 * The cloud collection in addition contains the images kid_with_mobile and craftar_logo.
 *
 * So, if you point to the image biz_card, it will be recognized using the on-device module. If you point to another image, a search
 * in the cloud will be performed. In the case you were pointing to the kid_with_mobile or to the craftar_logo images, the search in the cloud
 * will find the match.
 * **/

@interface ExtendedSearchViewController () <CraftARSDKProtocol, SearchProtocol> {
    CraftARSDK *mSDK;
    CraftARCloudRecognition *mCloudRecognition;
    
    ExtendedSearchController* mExtendedSearchController;
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
    
    self._previewOverlay.hidden = YES;
    self._scanningOverlay.hidden = YES;
    
    // Initialize the video capture on our preview view.
    [mSDK startCaptureWithView:self._preview];
    
}

#pragma mark -


#pragma mark Snap Photo mode implementation

- (void) didStartCapture {
    self._previewOverlay.hidden = NO;

    // Initialize the extended search controller and set the delegate
    // to receive search responses
    mExtendedSearchController = [[ExtendedSearchController alloc] init];
    mExtendedSearchController.delegate = self;
    
    // Set the extended search controller instance as the CameraSearchController
    // with this, it will receive the events from the SDK when
    // the SingleShotSearch and FindeMode are used.
    [[CraftARSDK sharedCraftARSDK] setSearchControllerDelegate:mExtendedSearchController];
    
    [self cloudSetup];
}

#pragma mark Cloud search setup

- (void) cloudSetup {
    
    
    ExtendedSearchController* searchController = mExtendedSearchController;
    mCloudRecognition = [CraftARCloudRecognition sharedCloudImageRecognition];
    [mCloudRecognition setCollectionWithToken:CLOUD_COLLECTION_TOKEN onSuccess:^{
        searchController.mReadyForCloudRecognition = YES;
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


- (void) didGetSearchResults:(NSArray *)resultItems {
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

- (void) didFailSearchWithError:(NSError *)error {    // Check the error type
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
