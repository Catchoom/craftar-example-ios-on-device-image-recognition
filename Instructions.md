
## CraftAR On-device Recognition SDK for iOS

This document is a tutorial that explains the basic steps to integrate the On-device recognition SDK into an application. There is a complete API reference in the documentation folder with more detailed description of the SDK and its modules.

The following sections show how the SDK was integrated to our Image Recognition SDK examples.

### SDK Initialization

The first step to be able to perform on-device recognition is to load the collection bundle and get it ready for recognition.

We need to initialise the SDK and get access to the __CollecitonManager__ and __OfflineIR__ modules. Then, we check if our collection has already been added to this device or not by looking for it with the token on the CollectionManager.

```
    mSDK = [CraftARSDK_IR sharedCraftARSDK_IR];
    
    // Get the colleciton manager
    mCollectionManager = [CraftARCollectionManager sharedCollectionManager];
    
    // Get the Offline IR
    mOfflineIR = [OfflineIR sharedOfflineIR];
    
    // Get the collection if it is already in the device
    CraftARCollection* demoCollection = [mCollectionManager getCollectionWithToken:@"catchoomcooldemo"];
    
    // if it is not in the device load it
    if (demoCollection == nil) {
        [self addDemoCollection];
    } else {
        [self loadDemoCollection: demoCollection];
    }
```

If the collection is not in the device we will add the collection by providing the path for the collection bundle file. This will extract the reference image database and store it in the user storage. This process may take a few seconds if the collection is big so the SDK provides feedback for a progress bar.


```
- (void) addDemoCollection {
    MainScreenViewController* myself = self;
    
    // Get the collection bundle file that contains the image database for recognition
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"catchoomcooldemoBundle" ofType: @"zip"];
    
    // Add the collection to the device
    [mCollectionManager addCollectionFromBundle:bundlePath withOnProgress:^(float progress) {
        NSLog(@"Add bundle progress: %f", progress);
    } andOnSuccess:^(CraftARCollection *collection) {
        // On success, we load the collection for recognition
        [myself loadDemoCollection: collection];
    } andOnError:^(CraftARError *error) {
        NSLog(@"Error adding collection: %@", [error localizedDescription]);
    }];
}
```

Finally, when we are sure that the collection is on the device, we set the collection for on-device recognition using the __OfflineIR__ module. This process is fast but can also take a few seconds for large collections so  progress feedback is provided here as well.

```
- (void) loadDemoCollection: (CraftARCollection*) collection {
    
    MainScreenViewController* myself = self;
    
    // Load the collection before doing any searches
    [mOfflineIR setCollection:collection setActive:YES withOnProgress:^(float progress) {
        NSLog(@"Load collection progress: %f", progress);
    } onSuccess:^{
        // Now the collection is ready for recognition
    } andOnError:^(CraftARError *error) {
        NSLog(@"Error adding collection: %@", [error localizedDescription]);
    }];
}
```

Now we are ready for on-device Image Recognition.

### On-device Image Recognition

In this section we will show how the On-device Image Recognition was integrated to the Single shot example. The Finder Mode example is very similar but using different SDK features to perform continuous scan.

First, we Setup the SDK in our viewController when the view loads and initialise the video capture with a previewView provided in our Storyboard.

```
- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    // setup the CraftAR SDK
    _sdk = [CraftARSDK_IR sharedCraftARSDK_IR];
    
    // Become delegate of the SDK to receive capture initialization callbacks
    _sdk.delegate = self;
    
    // Initialize the video capture on our preview view.
    [_sdk startCaptureWithView:self._preview];
    self._previewOverlay.hidden = NO;
    self._scanningOverlay.hidden = YES;
}
```

Once the capture is initialised, we set the __OfflineIR__ module as the __SearchControllerDelegate__ of the OfflineIR. The search controller will be used by the SDK to perform __Single Shot__ or __Finder Mode__ searches. Also, we want the view controller to get the results of the searches in a callback so we set it as the __OfflineIR__ delegate.

```
- (void) didStartCapture {
    self._previewOverlay.hidden = NO;
    
    // Get Offline Recognition class (for on-device searches)
    // and set it as the search controller delegate for the SDK
    _oir = [OfflineIR sharedOfflineIR];
    _sdk.searchControllerDelegate = _oir;
    
    // Set the view controller as delegate of the OfflineIR to recieve the
    // search results
    _oir.delegate = self;
}
```

To take a picture with the camera and perform a recognition we just need to ask the SDK to perform a __singleShotSearch__ as follows:

```
    [_sdk singleShotSearch];
```

The SDK will use the __CraftARCamera__ class to take a picture and will forward the image to the search controller (the __OfflineIR__ module). When the search is completed, the __didGetSearchResults__ message will be sent to the OfflineIR delegate with the list of results found (if any):

```
- (void) didGetSearchResults:(NSArray *)resultItems {
    // Handle the search results here
}
```

