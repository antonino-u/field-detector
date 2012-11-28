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
@synthesize fpsLabel = _fpsLabel;
@synthesize sliderLabel = _sliderLabel;

int framesProcessed = 0;
Mat blurKernel;

- (void)viewDidLoad
{
    [super viewDidLoad];
  Mat temp = [self createKernelOfRadius:1 withSigma:0];
  temp.copyTo(blurKernel);
  
	// Do any additional setup after loading the view, typically from a nib.
	//start a timer
	pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateFps) userInfo:nil repeats:YES];
	//start the video capture
	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
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

- (void)processImage:(Mat&)source;
{		
  cvtColor(source, source, CV_BGR2GRAY);
  //GaussianBlur(source, source, cv::Size(3,3), 1);
  sepFilter2D(source, source, 0, blurKernel, blurKernel);
  //Canny(source, source, 150, 300);
	
	framesProcessed++;
	
}

- (void) updateFps{
	self.fpsLabel.text = [NSString stringWithFormat:@"%d fps",framesProcessed];
	framesProcessed = 0;
}

- (Mat)createKernelOfRadius:(int)radius withSigma:(double)sigma{
  int nRows = (2*radius)+1;
  
  // automatically calculate sigma when user sets it to 0.0f
  if (sigma == 0) {
    sigma = (double)nRows/6;
  }
  double sigmaSquaredTimes2 = 2*(sigma*sigma);
  
  //std::cout << "SIGMA = "<< sigma << std::endl;
  
  Mat kernel(nRows, 1, CV_64F, Scalar(0));
  
  int centerIndex = radius;
  double factor = 1/sqrt(CV_PI * sigmaSquaredTimes2);
  
  // first set the center
  kernel.at<double>(centerIndex) = factor;
  
  for (int i = 1; i<=centerIndex; i++) {
    double power = (i*i)/sigmaSquaredTimes2;
    double exponent = exp(-power);
    float result = factor * exponent;
    
    kernel.at<double>(centerIndex-i) = result;
    kernel.at<double>(centerIndex+i) = result;
  }
  
  double kernelSum = sum(kernel)[0];
  
  // normalize kernel (divide each element by sum)
  for (int i = 0; i<=nRows; i++){
    kernel.at<double>(i) = (kernel.at<double>(i))/kernelSum;
  }
  
  //std::cout << "KERNEL = "<< std::endl << kernel << std::endl;
  //std::cout << "VERSUS = "<< std::endl << getGaussianKernel(3, 1) << std::endl << std::endl;
  
  return kernel;
  
}

- (IBAction)sliderChanged:(id) sender
{
  int sliderValue;
  sliderValue = self.blurSlider.value;
  NSString *newText =[[NSString alloc]
                      initWithFormat:@"%d",(int)sliderValue];
  self.sliderLabel.text = newText;
}

- (IBAction)updateBlurKernel:(id)sender
{
  Mat temp = [self createKernelOfRadius:self.blurSlider.value withSigma:0];
  temp.copyTo(blurKernel);
  //std::cout << "KERNEL UPDATED = "<< std::endl << blurKernel << std::endl;
}

@end
