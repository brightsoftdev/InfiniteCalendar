//
//  TUCalendarViewController.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarViewController.h"

#import "TUCalendarView.h"


@interface TUCalendarViewController ()

@end

@implementation TUCalendarViewController {
	TUCalendarView *_calendarView;
}
@synthesize calendarView = _calendarView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	_calendarView = [[TUCalendarView alloc] initWithFrame:self.view.bounds];
//	_calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	[self.view addSubview:_calendarView];
}

- (void)viewDidUnload
{
	[self setCalendarView:nil];
    [super viewDidUnload];
	
	_calendarView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// All orientations for iPad, any orientation except portrait upside down for iPhone/iPod touch
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
