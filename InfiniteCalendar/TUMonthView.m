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
	[self setNeedsDisplay];
}

- (CGFloat)topOffset
{
	return self._topLeftPoint.y;
}

+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month
{
	CGFloat offset = 0.0;
	
	CGFloat dayHeight = roundf((width - TUMonthLabelWidth) / [[NSCalendar currentCalendar] numberOfDaysInWeek]);
	
	NSInteger firstDayOffset = month.firstDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	if (firstDayOffset != 0) {
		offset -= dayHeight;
	}
	
	return offset;
}

+ (CGFloat)verticalOffsetForWidth:(CGFloat)width month:(NSDate *)month
{
	CGFloat offset = 0.0;
	
	
	CGFloat dayHeight = roundf((width - TUMonthLabelWidth) / [[NSCalendar currentCalendar] numberOfDaysInWeek]);
	NSInteger weeks = [[NSCalendar currentCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:month].length;
	offset = dayHeight * weeks;
	
	
	NSInteger firstDayOffset = month.firstDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	if (firstDayOffset != 0) {
		offset -= dayHeight;
	}
	
	
	return offset;
}

- (CGFloat)_dayHeight
{
	return roundf((self.bounds.size.width - TUMonthLabelWidth) / [[NSCalendar currentCalendar] numberOfDaysInWeek]);
}

- (CGPoint)_topLeftPoint
{
	NSInteger firstDayOffset = self.month.firstDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	CGPoint point = CGPointMake(TUMonthLabelWidth, 0.0);
	if (firstDayOffset != 0) {
		point.y += self._dayHeight;
	}
	
	return point;
}

- (CGPoint)_bottomRightPoint
{
	NSInteger lastDayOffset = self.month.lastDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	CGPoint point = CGPointMake(self.bounds.size.width, self.bounds.size.height);
	if (lastDayOffset != [[NSCalendar currentCalendar] numberOfDaysInWeek] - 1) {
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
	CGFloat dayHeight = roundf((size.width - TUMonthLabelWidth) / [[NSCalendar currentCalendar] numberOfDaysInWeek]);
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
	
	NSInteger firstDayOffset = self.month.firstDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	NSInteger lastDayOffset = self.month.lastDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	
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
							self._bottomRightPoint.y);
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
	
	NSInteger firstDayOffset = self.month.firstDayOfMonth.weekday - [[NSCalendar currentCalendar] firstWeekday];
	
	
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
