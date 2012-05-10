//
//  TUMonthView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUMonthView.h"

#import "NSCalendar+TUShortcuts.h"


#define TUMonthLabelWidth 30.0
#define TUMonthBoundaryLineWidth 1.0


@interface TUMonthView ()

@property (nonatomic, readonly) CGFloat _dayHeight;
@property (nonatomic, readonly) CGPoint _topLeftPoint;
@property (nonatomic, readonly) CGPoint _bottomRightPoint;
@property (nonatomic, readonly) NSInteger _firstDayOffset;
@property (nonatomic, readonly) NSInteger _lastDayOffset;

- (void)_drawMonthLabel;
- (void)_drawMonthBackground;
- (void)_drawMonthBorder;

@end


@implementation TUMonthView {
	CGFloat _dayHeight;
	NSInteger _firstDayOffset;
	NSInteger _lastDayOffset;
}

@synthesize month = _month;

- (void)setMonth:(NSDate *)month
{
	_month = month;
	
	_dayHeight = 0.0;
	_firstDayOffset = -1;
	_lastDayOffset = -1;
	[self sizeToFit];
	[self setNeedsDisplay];
}

- (CGFloat)topOffset
{
	return self._topLeftPoint.y;
}

+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month
{
	CGFloat offset = 0.0;
	
	CGFloat dayHeight = roundf((width - TUMonthLabelWidth) / [[NSCalendar sharedCalendar] numberOfDaysInWeek]);
	
	NSInteger firstDayOffset = month.firstDayOfMonth.weekday - [[NSCalendar sharedCalendar] firstWeekday];
	if (firstDayOffset != 0) {
		offset -= dayHeight;
	}
	
	return offset;
}

+ (CGFloat)verticalOffsetForWidth:(CGFloat)width month:(NSDate *)month
{
	CGFloat offset = 0.0;
	
	
	CGFloat dayHeight = roundf((width - TUMonthLabelWidth) / [[NSCalendar sharedCalendar] numberOfDaysInWeek]);
	NSInteger weeks = [[NSCalendar sharedCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:month].length;
	offset = dayHeight * weeks;
	
	
	NSInteger firstDayOffset = month.firstDayOfMonth.weekday - [[NSCalendar sharedCalendar] firstWeekday];
	if (firstDayOffset != 0) {
		offset -= dayHeight;
	}
	
	
	return offset;
}

- (CGFloat)_dayHeight
{
	if (_dayHeight == 0.0) {
		_dayHeight = roundf((self.frame.size.width - TUMonthLabelWidth) / [[NSCalendar sharedCalendar] numberOfDaysInWeek]);
	}
	
	return _dayHeight;
}

- (NSInteger)_firstDayOffset
{
	if (_firstDayOffset == -1) {
		_firstDayOffset = self.month.firstDayOfMonth.weekday - [[NSCalendar sharedCalendar] firstWeekday];
	}
	
	return _firstDayOffset;
}

- (NSInteger)_lastDayOffset
{
	if (_lastDayOffset == -1) {
		_lastDayOffset = self.month.lastDayOfMonth.weekday - [[NSCalendar sharedCalendar] firstWeekday];
	}
	
	return _lastDayOffset;
}

- (CGPoint)_topLeftPoint
{
	CGPoint point = CGPointMake(TUMonthLabelWidth, 0.0);
	if ([self _firstDayOffset] != 0) {
		point.y += self._dayHeight;
	}
	
	return point;
}

- (CGPoint)_bottomRightPoint
{
	CGPoint point = CGPointMake(self.bounds.size.width, self.bounds.size.height);
	NSInteger numberOfDays = [[NSCalendar sharedCalendar] numberOfDaysInWeek];
	NSInteger lastDayOffset = [self _lastDayOffset];
	if (lastDayOffset != numberOfDays - 1) {
		point.y -= self._dayHeight;
	}
	
	return point;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	_dayHeight = 0.0;
	_firstDayOffset = -1;
	_lastDayOffset = -1;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;
		_dayHeight = 0.0;
		
		self.month = [NSDate date];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.opaque = NO;
		_dayHeight = 0.0;
		
		self.month = [NSDate date];
    }
	
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGFloat dayHeight = roundf((size.width - TUMonthLabelWidth) / [[NSCalendar sharedCalendar] numberOfDaysInWeek]);
	NSInteger weeks = [[NSCalendar sharedCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month].length;
	
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
	
	static NSDateFormatter *formatter = nil;
	if (formatter == nil) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"MMMM yyyy";
	}
	
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
	
	
	CGContextMoveToPoint(context, self._topLeftPoint.x,
						 self._topLeftPoint.y + TUMonthBoundaryLineWidth);
	CGContextAddLineToPoint(context, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth,
							self._topLeftPoint.y + TUMonthBoundaryLineWidth);
	CGContextAddLineToPoint(context, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth,
							TUMonthBoundaryLineWidth);
	CGContextAddLineToPoint(context, self.bounds.size.width,
							TUMonthBoundaryLineWidth);
	
	CGContextAddLineToPoint(context, self._bottomRightPoint.x,
							self._bottomRightPoint.y);
	CGContextAddLineToPoint(context, ([self _lastDayOffset] + 1) * self._dayHeight + TUMonthLabelWidth,
							self._bottomRightPoint.y);
	CGContextAddLineToPoint(context, ([self _lastDayOffset] + 1) * self._dayHeight + TUMonthLabelWidth,
							self.bounds.size.height);
	CGContextAddLineToPoint(context, TUMonthLabelWidth,
							self.bounds.size.height);
	
	
	[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5] set];
	CGContextFillPath(context);
}

- (void)_drawMonthBorder
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	CGContextMoveToPoint(context, 0.0,
						 self._topLeftPoint.y + TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth/2.0,
							self._topLeftPoint.y + TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth + TUMonthBoundaryLineWidth/2.0,
							TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, self.bounds.size.width,
							TUMonthBoundaryLineWidth/2.0);
	
	
	[[UIColor blackColor] set];
	CGContextSetLineWidth(context, TUMonthBoundaryLineWidth);
	CGContextStrokePath(context);
}

@end
