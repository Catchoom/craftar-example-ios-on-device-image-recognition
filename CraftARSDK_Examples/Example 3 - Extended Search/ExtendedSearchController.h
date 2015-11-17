//
//  ExtendedSearchController.h
//  CraftAR-On-Device-IR-SDK_Examples
//
//  Created by Luis Martinell Andreu on 12/11/15.
//  Copyright © 2015 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARProtocols.h>
#import <CraftAROnDeviceRecognitionSDK/BaseSearchController.h>

@interface ExtendedSearchController :  BaseSearchController


/**
 * The ImageRecognition delegate will receive the search result callbacks
 */
@property (nonatomic, weak) id <SearchProtocol> delegate;

@property (nonatomic, readwrite) BOOL mReadyForCloudRecognition;

@end
