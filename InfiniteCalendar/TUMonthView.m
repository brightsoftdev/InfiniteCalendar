//
//  TUMonthView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUMonthView.h"


#define TUMonthLabelWidth 30.0
#define TUMonthBoundaryLineWidth 1.0



@implementation NSDate (_TUMonthView)

- (NSDate *)_firstDayOfMonth
{
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
	return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)_lastDayOfMonth
{
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
	[components setDay:[[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self].length];
	return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSInteger)_weekday
{
	return [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
}

@end

@implementation NSCalendar (_TUMonthView)

- (NSInteger)_numberOfDaysInWeek
{
	return [self rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[NSDate date]].length;
}

@end



@interface TUMonthView ()

@property (nonatomic, readonly) CGFloat _dayHeight;
@property (nonatomic, readonly) CGPoint _topLeftPoint;
@property (nonatomic, readonly) CGPoint _bottomRightPoint;

- (void)_drawMonthLabel;
- (void)_drawMonthBackground;
- (void)_drawMonthBorder;

@end


@implementation TUMonthView

@synthesize month = _month;

- (void)setMonth:(NSDate *)month
{
	_month = month;
	
	[self sizeToFit];
}

- (CGFloat)topOffset
{
	return self._topLeftPoint.y;
}

- (CGFloat)_dayHeight
{
	return roundf((self.bounds.size.width - TUMonthLabelWidth) / [[NSCalendar currentCalendar] _numberOfDaysInWeek]);
}

- (CGPoint)_topLeftPoint
{
	NSInteger firstDayOffset = self.month._firstDayOfMonth._weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	CGPoint point = CGPointMake(TUMonthLabelWidth, 0.0);
	if (firstDayOffset != 0) {
		point.y += self._dayHeight;
	}
	
	return point;
}

- (CGPoint)_bottomRightPoint
{
	NSInteger lastDayOffset = self.month._lastDayOfMonth._weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	CGPoint point = CGPointMake(self.bounds.size.width, self.bounds.size.height);
	if (lastDayOffset != [[NSCalendar currentCalendar] _numberOfDaysInWeek] - 1) {
		point.y -= self._dayHeight;
	}
	
	return point;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;
//		self.userInteractionEnabled = NO;
		
		self.month = [NSDate date];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.opaque = NO;
//		self.userInteractionEnabled = NO;
		
		self.month = [NSDate date];
    }
	
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGFloat dayHeight = roundf((size.width - TUMonthLabelWidth) / [[NSCalendar currentCalendar] _numberOfDaysInWeek]);
	NSInteger weeks = [[NSCalendar currentCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month].length;
	
	size.height = dayHeight * weeks;
	
	return size;
}

- (void)drawRect:(CGRect)rect
{
    [self _drawMonthBackground];
	[self _drawMonthLabel];
	[self _drawMonthBorder];
}

- (void)_drawMonthLabel
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"MMMM yyyy";
	NSString *monthName = [formatter stringFromDate:self.month];
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextRotateCTM(context, -M_PI_2);
	
	[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5] set];
	CGRect labelRect = CGRectMake(0.0, 0.0, self.bounds.size.height - self._topLeftPoint.y, TUMonthLabelWidth);
	CGContextFillRect(context, labelRect);
	
	
	[[UIColor yellowColor] set];
	CGSize textSize = [monthName sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:labelRect.size lineBreakMode:UITextAlignmentCenter];
	CGRect textRect = labelRect;
	textRect.origin.y = (labelRect.size.height - textSize.height) / 2.0;
	textRect.size.height = textSize.height;
	[monthName drawInRect:textRect withFont:[UIFont boldSystemFontOfSize:18.0] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextRestoreGState(context);
}

- (void)_drawMonthBackground
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSInteger firstDayOffset = self.month._firstDayOfMonth._weekday - [[NSCalendar currentCalendar] firstWeekday];
	NSInteger lastDayOffset = self.month._lastDayOfMonth._weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	
	CGContextMoveToPoint(context, self._topLeftPoint.x,
						 self._topLeftPoint.y + TUMonthBoundaryLineWidth);
	CGContextAddLineToPoint(context, firstDayOffset * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth,
							self._topLeftPoint.y + TUMonthBoundaryLineWidth);
	CGContextAddLineToPoint(context, firstDayOffset * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth,
							TUMonthBoundaryLineWidth);
	CGContextAddLineToPoint(context, self.bounds.size.width,
							TUMonthBoundaryLineWidth);
	
	CGContextAddLineToPoint(context, self._bottomRightPoint.x,
							self._bottomRightPoint.y);
	CGContextAddLineToPoint(context, (lastDayOffset + 1) * self._dayHeight + TUMonthLabelWidth,
							self.bounds.size.height - self._dayHeight);
	CGContextAddLineToPoint(context, (lastDayOffset + 1) * self._dayHeight + TUMonthLabelWidth,
							self.bounds.size.height);
	CGContextAddLineToPoint(context, TUMonthLabelWidth,
							self.bounds.size.height);
	
	
	[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5] set];
	CGContextFillPath(context);
}

- (void)_drawMonthBorder
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSInteger firstDayOffset = self.month._firstDayOfMonth._weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	
	CGContextMoveToPoint(context, 0.0,
						 self._topLeftPoint.y + TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, firstDayOffset * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth/2.0,
							self._topLeftPoint.y + TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, firstDayOffset * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth/2.0,
							TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, self.bounds.size.width,
							TUMonthBoundaryLineWidth/2.0);
	
	
	[[UIColor blackColor] set];
	CGContextSetLineWidth(context, TUMonthBoundaryLineWidth);
	CGContextStrokePath(context);
}

@end
