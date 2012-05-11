//
//  TUCalendarHeaderView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/11/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarHeaderView.h"

#import "TUMonthView.h"
#import "NSCalendar+TUShortcuts.h"


@implementation TUCalendarHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor colorWithRed:0.439 green:0.522 blue:0.635 alpha:0.850];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	static NSArray *weekdaySymbols = nil;
	if (weekdaySymbols == nil) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		weekdaySymbols = [formatter shortWeekdaySymbols];
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect dayRect;
	dayRect.size.height = self.frame.size.height;
    dayRect.size.width = (self.frame.size.width - TUMonthLabelWidth) / [[NSCalendar sharedCalendar] numberOfDaysInWeek];
	
	CGSize textSize = [@"Mon" sizeWithFont:UICalendarHeaderFont constrainedToSize:dayRect.size lineBreakMode:UILineBreakModeClip];
	dayRect.origin.y = (dayRect.size.height - textSize.height) / 2.0;
	dayRect.size.height = textSize.height;
	
	NSInteger weekday = 0;
	
	for (dayRect.origin.x = TUMonthLabelWidth; dayRect.origin.x < self.bounds.size.width; dayRect.origin.x += dayRect.size.width) {
		NSString *dayString = [weekdaySymbols objectAtIndex:weekday];
		
		CGRect shadowRect = dayRect;
		shadowRect.origin.y -= 1.0;
		[[UIColor colorWithWhite:0.2 alpha:0.5] setFill];
		[dayString drawInRect:shadowRect withFont:UICalendarHeaderFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		
		[[UIColor whiteColor] setFill];
		[dayString drawInRect:dayRect withFont:UICalendarHeaderFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		
		weekday++;
	}
	
	[[UIColor colorWithWhite:0.2 alpha:0.5] setStroke];
	CGContextMoveToPoint(context, 0.0, self.frame.size.height - 0.5);
	CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height - 0.5);
	CGContextStrokePath(context);
}

@end
