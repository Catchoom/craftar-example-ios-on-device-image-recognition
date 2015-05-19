## CraftAR - iOS Image Recognition SDK examples

### Introduction

The CraftAR Service for [Augmented Reality and Image Recognition](http://catchoom.com/product/craftar/augmented-reality-and-image-recognition/) is a  service
that allows you to build a wide range of __Image Recognition__ and __Augmented Reality__ applications
and services.

With CraftAR, you can create amazing apps that provide digital content
for real-life objects like printed media, packaging among others. You
can use our online web panel or APIs, to upload images to be recognized and set
content to display upon recognition in your CraftAR-powered app.

The [iOS Image Recognition SDK](http://catchoom.com/documentation/sdk/image-recognition/ios-image-recognition-sdk/) focuses on opening the camera in the mobile device and performing
Image Recognition requests to the API of CraftAR. The display of the result of the request
of each is up to you.

This document describes mainly the Examples of different uses of the Service and the Image Recognition SDK.
General use of the SDK can be found in the Documentation webpage for the [iOS Image Recognition SDK](http://catchoom.com/documentation/sdk/image-recognition/ios-image-recognition-sdk/). Complete SDK documentation of the classes can be found within the distribution of the SDK itself.


### How to use the examples

This repository comes with an Xcode project of an iOS app with several
examples that show how to use the SDK.

To run the examples follow these steps:
 1.  Open the CatchoomSDK_Examples.xcodeproj project.
 2.  Integrate the CatchoomSDK into the Xcode project (see [below](#step-by-step-guide)).
 3.  Select an iOS 8 device (notice that the project will not
     compile for the simulator).
 4.  Hit the run button.

### Add CatchoomSDK to the Example project

#### Requirements

To build the project or use the library, you will need XCode 6 or newer,
and at least the iOS 8.0 SDK.

#### Step-by-step guide
1.  Download the [CraftAR iOS Image Recognition SDK](http://catchoom.com/product/craftar/augmented-reality-and-image-recognition-sdk/#download-mobile-sdk).
2.  Unzip the package
3.  Drag the following files into the project:
 * CatchoomSDK.framework
 * Pods.framework
