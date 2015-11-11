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
#import "OnDeviceRecognitionFinderModeViewController.h"
#import <CraftAROnDeviceRecognitionSDK/CraftARSDK.h>
#import <CraftAROnDeviceRecognitionSDK/CraftAROnDeviceIR.h>

@interface OnDeviceRecognitionFinderModeViewController () <CraftARSDKProtocol, SearchProtocol, UIAlertViewDelegate> {
    CraftARSDK *_sdk;
    CraftAROnDeviceIR *_oir;
    bool _captureStarted;
    NSDate *mSearchStartTime;
}

@end

@implementation OnDeviceRecognitionFinderModeViewController

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
    _sdk = [CraftARSDK sharedCraftARSDK];
    
    // Become delegate of the SDK to receive capture initialization callbacks
    _sdk.delegate = self;
        
    // Start Video Preview for search
    [_sdk startCaptureWithView: self._preview];
    
    if (_captureStarted) {
        [_sdk startFinder];
        mSearchStartTime = [NSDate date];
    }
}

#pragma mark -


#pragma mark Snap Photo mode implementation

- (void) didStartCapture {
    _captureStarted=YES;
    self._scanningOverlay.hidden = NO;
    [self._scanningOverlay setNeedsDisplay];
    
    // Get On Device Image Recognition class (for on-device searches)
    // and set it as the search controller delegate for the SDK
    // the SDK will take care of sending the camera capture frames to the search controller
    // and to manage the Finder Mode status.
    _oir = [CraftAROnDeviceIR sharedCraftAROnDeviceIR];
    _sdk.searchControllerDelegate = _oir;
    
    // Set the view controller as delegate of the OnDeviceIR to recieve the
    // search results
    _oir.delegate = self;
    
    // Start searching using the finder mode
    [_sdk startFinder];
    mSearchStartTime = [NSDate date];

}


- (void) didGetSearchResults:(NSArray *)results {
    if (results.count > 0) {
        self._scanningOverlay.hidden = YES;
        [_sdk stopFinder];
        
        // Found one item, launch its content on a webView:
        CraftARSearchResult *bestResult = [results objectAtIndex:0];
        CraftARItem *item = bestResult.item;
        
        NSString* alertText = [NSString stringWithFormat:@"Item found: '%@'", item.name];
        if (results.count > 1) {
            alertText = [alertText stringByAppendingString: [NSString stringWithFormat:@" and %d more", (int)results.count -1]];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:alertText];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"Ok"];
        [alert show];
    } else {
        if ([[NSDate date] timeIntervalSinceDate:mSearchStartTime] > 10) {
            self._scanningOverlay.hidden = YES;
            [_sdk stopFinder];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No objects found" message:@"Point to an object of the catchoomcooldemo collection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self._scanningOverlay.hidden = NO;
    [_sdk startFinder];
    mSearchStartTime = [NSDate date];
}


- (void) didFailSearchWithError:(CraftARError *)error {
    self._scanningOverlay.hidden = NO;
    [self._scanningOverlay setNeedsDisplay];
    [_sdk startFinder];
    mSearchStartTime = [NSDate date];
}


#pragma mark -


#pragma mark view lifecycle

- (void) viewWillDisappear:(BOOL)animated {
    [_sdk  stopCapture];
    [_sdk stopFinder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

@end
