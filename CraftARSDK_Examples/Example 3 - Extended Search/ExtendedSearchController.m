//
//  ExtendedSearchController.m
//  CraftAR-On-Device-IR-SDK_Examples
//
//  Created by Luis Martinell Andreu on 12/11/15.
//  Copyright © 2015 Luis Martinell Andreu. All rights reserved.
//

#import "ExtendedSearchController.h"
#import <CraftAROnDeviceRecognitionSDK/CraftAROnDeviceIR.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARCloudRecognition.h>


@implementation ExtendedSearchController

- (void) didTakePicture:(UIImage *)image {
    // First, perform on-device Image Recongition
    CraftARQueryImage* queryImage = [[CraftARQueryImage alloc] initWithUIImage:image];
    [[CraftAROnDeviceIR sharedCraftAROnDeviceIR] searchWithImage:queryImage withOnResults:^(NSArray *results) {
        
        // If no results are found, Extend search to the cloud, otherwise process results
        if (results.count == 0 && self.mReadyForCloudRecognition) {
            NSLog(@"Nothing found on the device, extend search to the cloud");
            [[CraftARCloudRecognition sharedCloudImageRecognition] searchWithImage:queryImage withOnResults:^(NSArray *results) {
                [self.delegate didGetSearchResults: results];
            } andOnError:^(NSError *error) {
                [self.delegate didFailSearchWithError:error];
            }];
            return;
        }
        [self.delegate didGetSearchResults:results];
    } andOnError:^(NSError *error) {
        [self.delegate didFailSearchWithError:error];
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


@end
