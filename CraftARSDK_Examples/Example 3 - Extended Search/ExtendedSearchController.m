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

@interface ExtendedSearchController (){
    BOOL mIsFinderModeOn;
    BOOL mFinderSearchInProgress;
    
    CraftAROnDeviceIR* mOnDeviceIR;
    CraftARCloudRecognition* mCloudRecognition;
}


@end

@implementation ExtendedSearchController

- (id) init {
    self = [super init];
    if (self){
        mOnDeviceIR = [CraftAROnDeviceIR sharedCraftAROnDeviceIR];
        mCloudRecognition = [CraftARCloudRecognition sharedCloudImageRecognition];
    }
    return self;
}

- (void) didTakePicture:(UIImage *)image {
    // First, perform on-device Image Recongition
    CraftARQueryImage* queryImage = [[CraftARQueryImage alloc] initWithUIImage:image];
    [mOnDeviceIR searchWithImage:queryImage withOnResults:^(NSArray *results) {
        
        // If no results are found, Extend search to the cloud, otherwise process results
        if (results.count == 0 && self.mReadyForCloudRecognition) {
            NSLog(@"Nothing found on the device, extend search to the cloud");
            [mCloudRecognition searchWithImage:queryImage withOnResults:^(NSArray *results) {
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

- (void) didActivateFinderMode {
    mIsFinderModeOn = YES;
}

- (void) didDeactivateFinderMode {
    mIsFinderModeOn = NO;
}


- (void) didReceivePreviewFrame:(VideoFrame *)image {
    if (mIsFinderModeOn && [mOnDeviceIR getCurrentSearchCount] == 0) {
        CraftARQueryImage* searchImage = [[CraftARQueryImage alloc] initWithVideoFrame:image];
        [mOnDeviceIR searchWithImage:searchImage withOnResults:^(NSArray *results) {
            
            // If no results are found, Extend search to the cloud, otherwise process results
            if (results.count == 0 && self.mReadyForCloudRecognition) {
                NSLog(@"Nothing found on the device, extend search to the cloud");
                [mCloudRecognition searchWithImage:searchImage withOnResults:^(NSArray *results) {
                    [self.delegate didGetSearchResults: results];
                } andOnError:^(NSError *error) {
                    [self.delegate didFailSearchWithError:error];
                }];
                return;
            }
            [self.delegate didGetSearchResults:results];
        } andOnError:^(NSError *error) {
            if ([mOnDeviceIR.delegate respondsToSelector:@selector(didFailSearchWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [mOnDeviceIR.delegate didFailSearchWithError:error];
                });
            }
        }];
    }
}


- (BOOL) isFinding {
    return mIsFinderModeOn;
}

@end
