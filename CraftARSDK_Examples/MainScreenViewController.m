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

#import "MainScreenViewController.h"
#import <CraftAROnDeviceRecognitionSDK/CraftARSDK_IR.h>
#import <CraftAROnDeviceRecognitionSDK/CraftARCollectionManager.h>
#import <CraftAROnDeviceRecognitionSDK/CraftAROnDeviceIR.h>

@interface MainScreenViewController () {
    CraftARSDK_IR* mSDK;
    CraftARCollectionManager* mCollectionManager;
    CraftAROnDeviceIR* mOnDeviceIR;
}

@end

@implementation MainScreenViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    mSDK = [CraftARSDK_IR sharedCraftARSDK_IR];
    
    
    // Get the colleciton manager
    mCollectionManager = [CraftARCollectionManager sharedCollectionManager];
    
    // Get the On Device IR
    mOnDeviceIR = [CraftAROnDeviceIR sharedCraftAROnDeviceIR];
    
    // Get the collection if it is already in the device
    CraftARError* error;
    CraftARCollection* demoCollection = [mCollectionManager getCollectionWithToken:@"catchoomcooldemo" andError:&error];
    
    // if it is not in the device load it
    if (demoCollection == nil) {
        NSLog(@"Error getting collection: %@", [error localizedDescription]);
        [self addDemoCollection];
    } else {
        [self loadDemoCollection: demoCollection];
    }
    
    self._finderModeRecognitionButton.enabled = NO;
    self._singleShotRecognitionButton.enabled = NO;
    self._finderModeRecognitionButton.hidden = YES;
    self._singleShotRecognitionButton.hidden = YES;
    
}

- (IBAction)buttonPressed:(id)sender {
    
    UIViewController *target;
    if (sender == self._singleShotRecognitionButton) {
        UIStoryboard *exampleStoryBoard = [UIStoryboard storyboardWithName:@"SingleShot" bundle:nil];
        target = (UIViewController *)[exampleStoryBoard instantiateViewControllerWithIdentifier:@"RecognitionOneShotViewController"];
        target.navigationItem.title = @"Single shot Image Recognition ";
    } else if (sender == self._finderModeRecognitionButton) {
        UIStoryboard *exampleStoryBoard = [UIStoryboard storyboardWithName:@"FinderMode" bundle:nil];
        target = (UIViewController *)[exampleStoryBoard instantiateViewControllerWithIdentifier:@"RecognitionFinderModeViewController"];
        target.navigationItem.title = @"Finder Mode Image Recognition";
    }
    [self.navigationController pushViewController:target animated:YES];
}



#pragma mark manage collection

- (void) addDemoCollection {
    self._loadingView.hidden = NO;
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

- (void) loadDemoCollection: (CraftARCollection*) collection {
    
    self._loadingView.hidden = NO;
    MainScreenViewController* myself = self;
    
    // Load the collection before doing any searches
    [mOnDeviceIR setCollection:collection setActive:YES withOnProgress:^(float progress) {
        NSLog(@"Load collection progress: %f", progress);
    } onSuccess:^{
        // Now the collection is ready for recognition
        myself._loadingView.hidden = YES;
        myself._finderModeRecognitionButton.enabled = YES;
        myself._singleShotRecognitionButton.enabled = YES;
        myself._finderModeRecognitionButton.hidden = NO;
        myself._singleShotRecognitionButton.hidden = NO;

    } andOnError:^(CraftARError *error) {
        NSLog(@"Error adding collection: %@", [error localizedDescription]);
    }];
}


#pragma mark -



#pragma Websites with outside content
NSString* utm_medium = @"iOS";
NSString* utm_source = @"CraftARExamplesApp";


- (IBAction)signUpURL:(id)sender {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: @"https://crs.catchoom.com/try-free?utm_source="];
    [urlString appendString:utm_source];
    [urlString appendString:@"&utm_medium="];
    [urlString appendString:utm_medium];
    [urlString appendString:@"&utm_campaign=SignUp"];
    
    // Open URL in Webview
    UIViewController *webViewController = [[UIViewController alloc] init];
    
    UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: self.view.frame];
    [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    uiWebView.scalesPageToFit = YES;
    
    [webViewController.view addSubview: uiWebView];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)craftARProductURL:(id)sender {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: @"http://catchoom.com/product/?utm_source="];
    [urlString appendString:utm_source];
    [urlString appendString:@"&utm_medium="];
    [urlString appendString:utm_medium];
    [urlString appendString:@"&utm_campaign=HelpWithAPI"];
    
    // Open URL in Webview
    UIViewController *webViewController = [[UIViewController alloc] init];
    
    UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: self.view.frame];
    [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    uiWebView.scalesPageToFit = YES;
    
    [webViewController.view addSubview: uiWebView];
    [self.navigationController pushViewController:webViewController animated:YES];
}


- (IBAction)launchAPIURL:(id)sender {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: @"http://catchoom.com/documentation/api/management?utm_source="];
    [urlString appendString:utm_source];
    [urlString appendString:@"&utm_medium="];
    [urlString appendString:utm_medium];
    [urlString appendString:@"&utm_campaign=HelpWithAPI"];
    
    // Open URL in Webview
    UIViewController *webViewController = [[UIViewController alloc] init];
    
    UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: self.view.frame];
    [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    uiWebView.scalesPageToFit = YES;
    
    [webViewController.view addSubview: uiWebView];
    [self.navigationController pushViewController:webViewController animated:YES];
    
}

- (IBAction)launchCRSURL:(id)sender {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: @"http://crs.catchoom.com?utm_source="];
    [urlString appendString:utm_source];
    [urlString appendString:@"&utm_medium="];
    [urlString appendString:utm_medium];
    [urlString appendString:@"&utm_campaign=HelpWithAPI"];
    
    // Open URL in Webview
    UIViewController *webViewController = [[UIViewController alloc] init];
    
    UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: self.view.frame];
    [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    uiWebView.scalesPageToFit = YES;
    
    [webViewController.view addSubview: uiWebView];
    [self.navigationController pushViewController:webViewController animated:YES];
    
}

#pragma mark -

@end
