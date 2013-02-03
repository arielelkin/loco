//
//  GameViewController.m
//  LocoQuizz
//
//  Created by Matthew Pateman on 02/02/2013.
//  Copyright (c) 2013 Matthew Pateman. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@property NSMutableDictionary *venuesDict;
@property NSString *rightAnswer;

@property IBOutlet UILabel *questionLabel;
@property IBOutlet UIButton *buttonOne;
@property IBOutlet UIButton *buttonTwo;
@property IBOutlet UIButton *buttonThree;
@property IBOutlet UILabel *resultLabel;

@end

@implementation GameViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self fetchGameContent];
    
    NSLog(@"Game loaded, coordinates are: %f, %f", self.userLocation.latitude, self.userLocation.longitude);
}

-(void)fetchGameContent {

   // https://api.foursquare.com/v2/venues/search
   //?ll=51.509980,-0.133700
   //&client_id=CPG1OA2FD0OE43PLES4MFOK133GSJADXF3DUMLO4CG0TKOEV
   //&client_secret=30UCWAOGHIVF1C3MSUQ1RNPEUBKO20S01DQCWUQ0LEKCNE4D
    //&v=20130126
    
    
    NSString *baseString = @"https://api.foursquare.com/v2/venues/search";
    
    NSString *queryString = [NSString stringWithFormat:@"?ll=%f,%f", self.userLocation.latitude, self.userLocation.longitude];

    NSString *apiKeyString = @"&client_id=CPG1OA2FD0OE43PLES4MFOK133GSJADXF3DUMLO4CG0TKOEV&client_secret=30UCWAOGHIVF1C3MSUQ1RNPEUBKO20S01DQCWUQ0LEKCNE4D&v=20130126";
    
    NSString *requestString = [[baseString stringByAppendingString:queryString] stringByAppendingString:apiKeyString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if( error == nil) {
                                   NSError *jsonError = nil;
                                   NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                   if(jsonError == nil) {
                                       //NSLog(@"json: %@", json);
                                       NSDictionary *fourSquareResponse = [json valueForKey:@"response"];
                                       NSArray *venues = [fourSquareResponse valueForKey:@"venues"];
                                       [self createVenuesDict:venues];
                                    
                                   }
                               }
                               else {
                                   NSLog(@"error loading url: %@", error.localizedDescription);
                               }
                           }
     
     ];
}

-(void)createVenuesDict:(NSArray *)allVenues{
    
    self.venuesDict = [NSMutableDictionary dictionary];
    
    //Only get the venues' names and categories
    for(NSDictionary *singleVenue in allVenues){
        NSArray *categories = [singleVenue valueForKey:@"categories"];
        if(categories){
            //            NSLog(@"%@ - %@", [venue valueForKey:@"name"], [categories valueForKey:@"name"][0]);
            [self.venuesDict setValue:[categories valueForKey:@"name"][0] forKey:[singleVenue valueForKey:@"name"]];
        }
    }
    
    NSLog(@"venues: %@", self.venuesDict);
    
    [self nextQuestion];
    
}

-(void)nextQuestion {
    
    NSArray *venueNames = self.venuesDict.allKeys;
    NSString *currentVenue = venueNames[arc4random()%venueNames.count];
    self.rightAnswer = [self.venuesDict valueForKey:currentVenue];

    //define wrong answers
    NSString *wrongChoiceOne = [self.venuesDict valueForKey:[venueNames objectAtIndex:arc4random()%venueNames.count]];
    NSString *wrongChoiceTwo = [self.venuesDict valueForKey:[venueNames objectAtIndex:arc4random()%venueNames.count]];
    
    self.questionLabel.text = [NSString stringWithFormat:@"What's %@?", currentVenue];
    [self.buttonOne setTitle:wrongChoiceOne forState:UIControlStateNormal];
    [self.buttonTwo setTitle:wrongChoiceTwo forState:UIControlStateNormal];
    [self.buttonThree setTitle:self.rightAnswer forState:UIControlStateNormal];
    
    NSLog(@"%@ is a %@, but not a %@ nor a %@", currentVenue, self.rightAnswer, wrongChoiceOne, wrongChoiceTwo);
}

-(IBAction)userTappedAnswer:(UIButton *)sender{
    
    NSLog(@"Right answer: %@", _rightAnswer);
    
    if([sender.titleLabel.text isEqualToString:_rightAnswer]){
        [self.resultLabel setText:@"CORRECT"];
    }
    else {
        [self.resultLabel setText:@"WRONG"];
        
    }
    
    [self nextQuestion];
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
