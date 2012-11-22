//
//  ViewController.m
//  DasRealest
//
//  Created by Gianni Settino on 2012-11-21.
//  Copyright (c) 2012 Milton and Parc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView = _imageView;
@synthesize videoCamera = _videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
  self.videoCamera.delegate = self;
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
  self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
  self.videoCamera.defaultFPS = 30;
  self.videoCamera.grayscaleMode = NO;
  
  [self.videoCamera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processImage:(Mat&)image;
{
  // Do some OpenCV stuff with the image
  // convert to greyscale
  cvtColor(image, image, CV_BGR2GRAY);
  // reduce noise with a kernel 3x3
  blur(image, image, cv::Size(3,3));
  Canny(image, image, 5, 15, 3);
  
  //cvtColor(image_copy, image, CV_BGR2BGRA);
}

@end
