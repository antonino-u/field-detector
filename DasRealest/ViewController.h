//
//  ViewController.h
//  DasRealest
//
//  Created by Gianni Settino on 2012-11-21.
//  Copyright (c) 2012 Milton and Parc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
  CvVideoCamera* videoCamera;
  UILabel *fpsLabel;
  NSTimer *pollingTimer;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, retain) IBOutlet UILabel *fpsLabel;


- (IBAction) switchCamera;
- (void) updateFps;

@end
