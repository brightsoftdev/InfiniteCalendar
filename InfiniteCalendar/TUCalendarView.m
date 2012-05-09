//
//  TUCalendarView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarView.h"

#import "TUMonthView.h"


@interface TUCalendarView ()

- (BOOL)_lastMonthNeeded;
- (BOOL)_firstMonthNeeded;
- (void)_recenterIfNecessary;
- (void)_updateMonthViews;

@end


@implementation TUCalendarView {
	NSMutableArray *_monthViews;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.scrollEnabled = YES;
		self.bounces = YES;
		self.alwaysBounceVertical = YES;
        self.showsVerticalScrollIndicator = YES;
		
		self.contentSize = CGSizeMake(self.bounds.size.width, 2000.0);
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.scrollEnabled = YES;
		self.bounces = YES;
		self.alwaysBounceVertical = YES;
        self.showsVerticalScrollIndicator = YES;
		
		self.contentSize = CGSizeMake(self.bounds.size.width, 2000.0);
		
		_monthViews = [[NSMutableArray alloc] init];
		
		
		TUMonthView *lastMonthView = [_monthViews lastObject];
		
		TUMonthView *monthView = [[TUMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 100.0)];
		monthView.month = [NSDate date];
		monthView.frame = CGRectMake(0.0,
									 -1.0,
									 self.bounds.size.width,
									 monthView.frame.size.height);
		[self addSubview:monthView];
		
		[_monthViews addObject:monthView];
    }
    return self;
}

- (BOOL)_lastMonthNeeded
{
	__block BOOL lastMonthNeeded = YES;
	CGPoint lastPoint = CGPointMake(CGRectGetMaxX(self.bounds) - 1.0, CGRectGetMaxY(self.bounds) + 100.0);
	
	[_monthViews enumerateObjectsUsingBlock:^(TUMonthView *monthView, NSUInteger index, BOOL *stop) {
		lastMonthNeeded = !CGRectContainsPoint(monthView.frame, lastPoint);
		
		*stop = !lastMonthNeeded;
	}];
	
	return lastMonthNeeded;
}

- (BOOL)_firstMonthNeeded
{
	__block BOOL firstMonthNeeded = YES;
	CGPoint lastPoint = CGPointMake(CGRectGetMinX(self.bounds) + 1.0, CGRectGetMinY(self.bounds) - 100.0);
	
	[_monthViews enumerateObjectsUsingBlock:^(TUMonthView *monthView, NSUInteger index, BOOL *stop) {
		firstMonthNeeded = !CGRectContainsPoint(monthView.frame, lastPoint);
		
		*stop = !firstMonthNeeded;
	}];
	
	return firstMonthNeeded;
}

- (void)_recenterIfNecessary
{
	CGPoint currentOffset = self.contentOffset;
	CGFloat contentHeight = self.contentSize.height;
	CGFloat centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0;
	CGFloat distanceFromCenter = fabs(currentOffset.y - centerOffsetY);
	
	if (distanceFromCenter > (contentHeight / 4.0)) {
		self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);
		
		[_monthViews enumerateObjectsUsingBlock:^(TUMonthView *monthView, NSUInteger index, BOOL *stop) {
			CGPoint center = monthView.center;
			center.y += (centerOffsetY - currentOffset.y);
			monthView.center = center;
		}];
	}
}

- (void)_updateMonthViews
{
	[[_monthViews copy] enumerateObjectsUsingBlock:^(TUMonthView *monthView, NSUInteger index, BOOL *stop) {
		if (!CGRectIntersectsRect(self.bounds, monthView.frame)) {
			[monthView removeFromSuperview];
			[_monthViews removeObject:monthView];
		}
	}];
	
	while ([self _lastMonthNeeded]) {
		TUMonthView *lastMonthView = [_monthViews lastObject];
		
		TUMonthView *monthView = [[TUMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 100.0)];
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = 1;
		monthView.month = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:lastMonthView.month options:0];
		monthView.frame = CGRectMake(0.0,
									 lastMonthView.frame.origin.y + lastMonthView.frame.size.height - [monthView topOffset],
									 self.bounds.size.width,
									 monthView.frame.size.height);
		[self insertSubview:monthView atIndex:0];
		
		[_monthViews addObject:monthView];
	}
	
	if ([self _firstMonthNeeded]) {
		TUMonthView *lastMonthView = [_monthViews objectAtIndex:0];
		
		TUMonthView *monthView = [[TUMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 100.0)];
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = -1;
		monthView.month = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:lastMonthView.month options:0];
		monthView.frame = CGRectMake(0.0,
									 CGRectGetMinY(lastMonthView.frame) + [lastMonthView topOffset] - monthView.frame.size.height,
									 self.bounds.size.width,
									 monthView.frame.size.height);
		[self insertSubview:monthView atIndex:0];
		
		[_monthViews insertObject:monthView atIndex:0];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self _recenterIfNecessary];
	[self _updateMonthViews];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[[UIColor whiteColor] set];
	CGContextFillRect(context, self.bounds);
	
	for (CGFloat i = -0.5; i < self.bounds.size.height; i += 50.0) {
		CGContextMoveToPoint(context, 0.0, i);
		CGContextAddLineToPoint(context, self.bounds.size.width, i);
	}
	
	for (CGFloat i = -0.5; i < self.bounds.size.width; i += 50.0) {
		CGContextMoveToPoint(context, i, 0.0);
		CGContextAddLineToPoint(context, i, self.bounds.size.height);
	}
	
	[[UIColor lightGrayColor] set];
	CGContextStrokePath(context);
}

@end
