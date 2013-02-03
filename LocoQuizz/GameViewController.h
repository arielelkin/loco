//
//  GameViewController.h
//  LocoQuizz
//
//  Created by Matthew Pateman on 02/02/2013.
//  Copyright (c) 2013 Matthew Pateman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GameViewController : UIViewController

@property CLLocationCoordinate2D userLocation;

-(IBAction)userTappedAnswer:(UIButton *)sender;

@end
