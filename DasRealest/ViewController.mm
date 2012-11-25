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
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;//640x480;
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

- (void) switchCamera{
	[self.videoCamera switchCameras];

}

- (void)processImage:(Mat&)source;
{
	//estimates the frames per second from this frame only: get the current time
	double fps1 = CACurrentMediaTime();
	
	//prepare a cannied image for the canny algorithm and a blurred
	Mat cannied, blurred;
	// Do some OpenCV stuff with the image
	
	// convert to greyscale... always a good idea not just for canny but for hough too
	cvtColor(source, blurred, CV_BGR2GRAY);
	// reduce noise with a kernel 3x3
	//blur(blurred, blurred, cv::Size(3,3));
	GaussianBlur(blurred, blurred, cv::Size(9, 9), 2, 2 );

	//perform canny
	Canny(blurred, cannied, 50, 200, 3);
	
	//standard hough transform for lines
	//first apply the transform
	vector<Vec2f> lines;
	HoughLines(cannied, lines, 1, CV_PI/180, 100, 0, 0 );
	//printf("there are %l lines.",lines.size());
	//then display the lines
	for( size_t i = 0; i < lines.size(); i++ )
	{
		float rho = lines[i][0], theta = lines[i][1];
		cv::Point pt1, pt2;
		double a = cos(theta), b = sin(theta);
		double x0 = a*rho, y0 = b*rho;
		pt1.x = cvRound(x0 + 1000*(-b));
		pt1.y = cvRound(y0 + 1000*(a));
		pt2.x = cvRound(x0 - 1000*(-b));
		pt2.y = cvRound(y0 - 1000*(a));
		line(source, pt1, pt2, Scalar(0,0,255), 3, CV_AA);
	}
	
	//standard hough transform for circles
	//we can treat this as optional for the time being
	//first apply the transform
	vector<Vec3f> circles;
	HoughCircles(blurred, circles, CV_HOUGH_GRADIENT, 2, blurred.rows/4, 200, 100);
	//printf("there are %l lines.",lines.size());
	//then display the lines
	for( size_t i = 0; i < circles.size(); i++ )
	{
		cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
		int radius = cvRound(circles[i][2]);
         // draw the circle center
         circle(source, center, 3, Scalar(0,255,0), -1, 8, 0 );
         // draw the circle outline
         circle(source, center, radius, Scalar(0,0,255), 3, 8, 0 );
  	}
	//cvtColor(image_copy, image, CV_BGR2BGRA);
	
	//again, get the current time:
	double fps2 = CACurrentMediaTime();
	//...and just for now, put it in the console:
	//printf("FPS: %f",1/(fps2-fps1));
}

@end
