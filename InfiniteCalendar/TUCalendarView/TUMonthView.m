//
//  TUMonthView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUMonthView.h"

#import "TUCalendarView.h"
#import "NSCalendar+TUShortcuts.h"


@interface TUMonthView ()

@property (nonatomic, readonly) CGFloat _dayHeight;
@property (nonatomic, readonly) CGPoint _topLeftPoint;
@property (nonatomic, readonly) CGPoint _bottomRightPoint;
@property (nonatomic, readonly) NSInteger _firstDayOffset;
@property (nonatomic, readonly) NSInteger _lastDayOffset;

- (void)_enumerateDays:(void(^)(NSDateComponents *day, CGRect dayRect, BOOL *stop))dayBlock;
- (CGGradientRef)_labelGradient;
- (CGGradientRef)_backgroundGradient;
- (CGGradientRef)_selectedGradient;
- (id)_backgroundPath;
- (void)_drawDayHighlights;
- (void)_drawDayBorders;
- (void)_drawMonthLabel;
- (void)_drawMonthBackground;
- (void)_drawMonthBorder;
- (void)_drawDays;

@end


@implementation TUMonthView {
	CGFloat _dayHeight;
	NSInteger _firstDayOffset;
	NSInteger _lastDayOffset;
}

#pragma mark - Properties

@synthesize calendarView = _calendarView;
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


#pragma mark - Initialization

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


#pragma mark - Sizing

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	_dayHeight = 0.0;
	_firstDayOffset = -1;
	_lastDayOffset = -1;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGFloat dayHeight = roundf((size.width - TUMonthLabelWidth) / [[NSCalendar sharedCalendar] numberOfDaysInWeek]);
	NSInteger weeks = [[NSCalendar sharedCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month].length;
	
	size.height = dayHeight * weeks;
	
	return size;
}


#pragma mark - Geometry

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

- (NSDateComponents *)dayAtPoint:(CGPoint)point
{
	__block NSDateComponents *dayComponents = nil;
	
	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {
		if (CGRectContainsPoint(dayRect, point)) {
			dayComponents = [day copy];
			
			*stop = YES;
		}
	}];
	
	return dayComponents;
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [self _drawMonthBackground];
	[self _drawDayHighlights];
	[self _drawDayBorders];
	[self _drawMonthBorder];
	[self _drawMonthLabel];
	[self _drawDays];
}

- (void)_enumerateDays:(void(^)(NSDateComponents *day, CGRect dayRect, BOOL *stop))dayBlock
{
	NSRange weeks = [[NSCalendar sharedCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month];
	NSRange days = [[NSCalendar sharedCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month];
	NSDateComponents *day = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.month];
	day.day = days.location;
	CGRect dayRect;
	dayRect.origin.x = [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth;
	dayRect.size = CGSizeMake(self._dayHeight - 1.0, self._dayHeight - 1.0);
	BOOL stop = NO;
	
	for (NSInteger week = 0; week < weeks.length && !stop; week++) {
		dayRect.origin.y = week * self._dayHeight + TUMonthBoundaryLineWidth;
		
		while (dayRect.origin.x < self.frame.size.width && day.day < days.location + days.length && !stop) {
			dayBlock(day, dayRect, &stop);
			dayRect.origin.x += self._dayHeight;
			day.day++;
		}
		
		dayRect.origin.x = TUMonthLabelWidth;
	}
}

- (id)_backgroundPath
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	
	CGPathMoveToPoint(path, NULL, self._topLeftPoint.x,
					  self._topLeftPoint.y + TUMonthBoundaryLineWidth);
	CGPathAddLineToPoint(path, NULL, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth - TUMonthBoundaryLineWidth,
						 self._topLeftPoint.y + TUMonthBoundaryLineWidth);
	CGPathAddLineToPoint(path, NULL, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth - TUMonthBoundaryLineWidth,
						 TUMonthBoundaryLineWidth);
	CGPathAddLineToPoint(path, NULL, self.bounds.size.width,
						 TUMonthBoundaryLineWidth);
	
	CGPathAddLineToPoint(path, NULL, self._bottomRightPoint.x,
						 self._bottomRightPoint.y);
	CGPathAddLineToPoint(path, NULL, ([self _lastDayOffset] + 1) * self._dayHeight + TUMonthLabelWidth - TUMonthBoundaryLineWidth,
						 self._bottomRightPoint.y);
	CGPathAddLineToPoint(path, NULL, ([self _lastDayOffset] + 1) * self._dayHeight + TUMonthLabelWidth - TUMonthBoundaryLineWidth,
						 self.bounds.size.height);
	CGPathAddLineToPoint(path, NULL, TUMonthLabelWidth,
						 self.bounds.size.height);
	
	
	id pathObject = CFBridgingRelease(path);
	return pathObject;
}

- (CGGradientRef)_labelGradient
{
	static CGGradientRef gradient = NULL;
    if (gradient == NULL) {
        CGFloat colors[8] = { 
            0.965, 0.965, 0.969, 1.0,
            0.800, 0.800, 0.820, 1.0};
        CGFloat locations[2] = { 0.0, 1.0 };
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
        CGColorSpaceRelease(colorSpace);
    }
	
    return gradient;
}

- (void)_drawMonthLabel
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	static NSDateFormatter *formatter = nil;
	if (formatter == nil) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"MMMM yyyy";
	}
	
	NSString *monthName = [formatter stringFromDate:self.month];
	
	
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextRotateCTM(context, -M_PI_2);
	
	
	CGRect labelRect = CGRectMake(0.0, 0.0, self.bounds.size.height - self._topLeftPoint.y - TUMonthBoundaryLineWidth, TUMonthLabelWidth);
	CGContextClipToRect(context, labelRect);
	
	
	CGGradientRef gradient = [self _labelGradient];
    CGPoint startPoint = CGPointMake(CGRectGetMidX(labelRect), CGRectGetMinY(labelRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(labelRect), CGRectGetMaxY(labelRect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	
	CGContextMoveToPoint(context, CGRectGetMinX(labelRect), CGRectGetMaxY(labelRect) - TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, CGRectGetMaxX(labelRect), CGRectGetMaxY(labelRect) - TUMonthBoundaryLineWidth/2.0);
	[[UIColor grayColor] set];
	CGContextStrokePath(context);
	
	
	CGSize textSize = [monthName sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:labelRect.size lineBreakMode:UITextAlignmentCenter];
	CGRect textRect = labelRect;
	textRect.size.height = textSize.height;
	[[UIColor colorWithWhite:1.0 alpha:0.75] set];
	textRect.origin.y = (labelRect.size.height - textSize.height) / 2.0 + 1.0;
	[monthName drawInRect:textRect withFont:TUMonthLabelFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	[[UIColor darkGrayColor] set];
	textRect.origin.y = (labelRect.size.height - textSize.height) / 2.0;
	[monthName drawInRect:textRect withFont:TUMonthLabelFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextRestoreGState(context);
}

- (void)_drawDayHighlights
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGPathRef backgroundPath = CFBridgingRetain([self _backgroundPath]);
	CGContextAddPath(context, backgroundPath);
	CGContextClip(context);
	CFRelease(backgroundPath);
	
	
	for (CGFloat y = TUMonthBoundaryLineWidth + 0.5; y < self.bounds.size.height; y += self._dayHeight) {
		CGContextMoveToPoint(context, TUMonthLabelWidth, y);
		CGContextAddLineToPoint(context, self.frame.size.width, y);
	}
	
	
	for (CGFloat x = TUMonthLabelWidth + self._dayHeight - 1.5; x < self.bounds.size.width; x += self._dayHeight) {
		CGContextMoveToPoint(context, x, 0.0);
		CGContextAddLineToPoint(context, x, self.frame.size.height);
	}
	
	
	[[UIColor colorWithRed:0.949 green:0.945 blue:0.953 alpha:1.000] set];
	CGContextStrokePath(context);
	
	
	CGContextRestoreGState(context);
}

- (void)_drawDayBorders
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGPathRef backgroundPath = CFBridgingRetain([self _backgroundPath]);
	CGContextAddPath(context, backgroundPath);
	CGContextClip(context);
	CFRelease(backgroundPath);
	
	
	for (CGFloat y = TUMonthBoundaryLineWidth - 0.5; y < self.bounds.size.height; y += self._dayHeight) {
		CGContextMoveToPoint(context, TUMonthLabelWidth, y);
		CGContextAddLineToPoint(context, self.frame.size.width, y);
	}
	
	
	for (CGFloat x = TUMonthLabelWidth + self._dayHeight - 0.5; x < self.bounds.size.width; x += self._dayHeight) {
		CGContextMoveToPoint(context, x, 0.0);
		CGContextAddLineToPoint(context, x, self.frame.size.height);
	}
	
	
	[[UIColor colorWithRed:0.663 green:0.675 blue:0.702 alpha:1.000] set];
	CGContextStrokePath(context);
	
	
	CGContextRestoreGState(context);
}

- (CGGradientRef)_backgroundGradient
{
	static CGGradientRef gradient = NULL;
    if (gradient == NULL) {
        CGFloat colors[8] = { 
            0.886, 0.886, 0.894, 1.0,
            0.800, 0.796, 0.816, 1.0};
        CGFloat locations[2] = { 0.0, 1.0 };
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
        CGColorSpaceRelease(colorSpace);
    }
	
    return gradient;
}

- (void)_drawMonthBackground
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	CGPathRef backgroundPath = CFBridgingRetain([self _backgroundPath]);
	CGContextAddPath(context, backgroundPath);
	CFRelease(backgroundPath);
	CGContextClip(context);
	

    CGGradientRef gradient = [self _backgroundGradient];
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.frame), 0.0);
    CGPoint endPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	
	CGContextRestoreGState(context);
}

- (void)_drawMonthBorder
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	CGContextMoveToPoint(context, 0.0,
						 self._topLeftPoint.y + TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth - TUMonthBoundaryLineWidth/2.0,
							self._topLeftPoint.y + TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, [self _firstDayOffset] * self._dayHeight + TUMonthLabelWidth - TUMonthBoundaryLineWidth/2.0,
							TUMonthBoundaryLineWidth/2.0);
	CGContextAddLineToPoint(context, self.bounds.size.width,
							TUMonthBoundaryLineWidth/2.0);
	
	
	[TUMonthBoundaryLineColor set];
	CGContextSetLineWidth(context, TUMonthBoundaryLineWidth);
	CGContextStrokePath(context);
}

- (CGGradientRef)_selectedGradient
{
	static CGGradientRef gradient = NULL;
    if (gradient == NULL) {
        CGFloat colors[16] = {
			0.745, 0.855, 0.965, 1.000,
			0.459, 0.698, 0.929, 1.000,
            0.196, 0.549, 0.894, 1.000,
            0.075, 0.459, 0.875, 1.000};
        CGFloat locations[4] = { 0.000, 1.0/40.0, 0.499, 0.5 };
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 4);
        CGColorSpaceRelease(colorSpace);
    }
	
    return gradient;
}

- (void)_drawDays
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSDateComponents *today = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
	NSDateComponents *month = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.month];
	
	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {
		CGContextSaveGState(context);
		
		NSString *dayString = [NSString stringWithFormat:@"%d", day.day];
		UIColor *textColor;
		UIColor *shadowColor;
		CGSize shadowOffset = CGSizeMake(0.0, 1.0);
		
		BOOL isToday = month.year == today.year && month.month == today.month && day.day == today.day;
		BOOL isSelected = [self.calendarView.selectedDay isEqual:day];
		
		if (isToday) {
			if (isSelected) {
				[[UIColor colorWithRed:0.137 green:0.510 blue:0.886 alpha:1.000] setFill];
			} else {
				[[UIColor colorWithRed:0.455 green:0.537 blue:0.643 alpha:1.000] setFill];
			}
			CGContextFillRect(context, dayRect);
			
			CGContextSaveGState(context);
			CGContextSetShadowWithColor(context, CGSizeZero, 5.0, [UIColor colorWithRed:0.116 green:0.214 blue:0.343 alpha:1.000].CGColor);
			CGContextClipToRect(context, dayRect);
			CGContextAddRect(context, CGRectInset(dayRect, -10.0, -10.0));
			CGContextAddRect(context, dayRect);
			CGContextEOFillPath(context);
			CGContextRestoreGState(context);
			
			[[UIColor colorWithRed:0.216 green:0.314 blue:0.443 alpha:1.000] setStroke];
			CGContextStrokeRect(context, CGRectInset(dayRect, -0.5, -0.5));
			
			textColor = [UIColor whiteColor];
			shadowColor = [UIColor darkGrayColor];
		} else if (isSelected) {
			CGContextSaveGState(context);
			
			CGContextClipToRect(context, dayRect);
			
			CGGradientRef gradient = [self _selectedGradient];
			CGPoint startPoint = CGPointMake(CGRectGetMidX(dayRect), CGRectGetMinY(dayRect));
			CGPoint endPoint = CGPointMake(CGRectGetMidX(dayRect), CGRectGetMaxY(dayRect));
			CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
			
			CGContextRestoreGState(context);
			
			[[UIColor colorWithRed:0.165 green:0.212 blue:0.282 alpha:1.000] setStroke];
			CGContextStrokeRect(context, CGRectInset(dayRect, -0.5, -0.5));
			
			textColor = [UIColor whiteColor];
			shadowColor = [UIColor darkGrayColor];
			shadowOffset = CGSizeMake(0.0, -1.0);
		} else {
			textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"day-gradient.png"]];
			shadowColor = [UIColor whiteColor];
		}
		
		
		CGSize stringSize = [dayString sizeWithFont:[UIFont boldSystemFontOfSize:20.0] constrainedToSize:dayRect.size];
		dayRect.origin.y += (dayRect.size.height - stringSize.height) / 2.0;
		dayRect.origin.x += shadowOffset.width;
		dayRect.origin.y += shadowOffset.height;
		dayRect.size.height = stringSize.height;
		
		[shadowColor set];
		[dayString drawInRect:dayRect withFont:[UIFont boldSystemFontOfSize:20.0] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
		
		dayRect.origin.x -= shadowOffset.width;
		dayRect.origin.y -= shadowOffset.height;
		[textColor set];
		CGContextSetPatternPhase(context, CGSizeMake(0.0, dayRect.origin.y));
		[dayString drawInRect:dayRect withFont:[UIFont boldSystemFontOfSize:20.0] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
		
		CGContextRestoreGState(context);
	}];
}

@end
