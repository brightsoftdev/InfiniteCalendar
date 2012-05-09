//
//  TUCalendarView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarView.h"

#import "TUMonthView.h"
#import "NSCalendar+TUShortcuts.h"


@interface TUCalendarView ()

- (BOOL)_lastMonthNeeded;
- (BOOL)_firstMonthNeeded;
- (void)_recenterIfNecessary;
- (void)_updateMonthViews;
- (TUMonthView *)_dequeueMonthView;

@end


@implementation TUCalendarView {
	NSMutableArray *_monthViews;
	NSMutableSet *_monthViewQueue;
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
		_monthViewQueue = [[NSMutableSet alloc] init];
		
		
		TUMonthView *monthView = [[TUMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 100.0)];
		monthView.month = [NSDate date];
		monthView.frame = CGRectMake(0.0,
									 -1.0,
									 self.frame.size.width,
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
	
	return lastMonthNeeded && CGRectGetMaxY([[_monthViews lastObject] frame]) < CGRectGetMaxY(self.bounds) + 100.0;
}

- (BOOL)_firstMonthNeeded
{
	__block BOOL firstMonthNeeded = YES;
	CGPoint lastPoint = CGPointMake(CGRectGetMinX(self.bounds) + 1.0, CGRectGetMinY(self.bounds) - 100.0);
	
	[_monthViews enumerateObjectsUsingBlock:^(TUMonthView *monthView, NSUInteger index, BOOL *stop) {
		firstMonthNeeded = !CGRectContainsPoint(monthView.frame, lastPoint);
		
		*stop = !firstMonthNeeded;
	}];
	
	return firstMonthNeeded && CGRectGetMinY([[_monthViews objectAtIndex:0] frame]) > self.bounds.origin.y - 100.0;
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

- (TUMonthView *)_dequeueMonthView
{
	TUMonthView *monthView = [_monthViewQueue anyObject];
	
	if (monthView  == nil) {
		monthView = [[TUMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 100.0)];
	} else {
		[_monthViewQueue removeObject:monthView];
	}
	
	return monthView;
}

- (void)_updateMonthViews
{
	[[_monthViews copy] enumerateObjectsUsingBlock:^(TUMonthView *monthView, NSUInteger index, BOOL *stop) {
		if (!CGRectIntersectsRect(self.bounds, monthView.frame) && _monthViews.count > 1) {
			[monthView removeFromSuperview];
			[_monthViews removeObject:monthView];
			[_monthViewQueue addObject:monthView];
		}
	}];
	
	while ([self _lastMonthNeeded]) {
		TUMonthView *lastMonthView = [_monthViews lastObject];
		
		TUMonthView *monthView = [self _dequeueMonthView];
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = 1;
		monthView.month = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:lastMonthView.month options:0];
		monthView.frame = CGRectMake(0.0,
									 lastMonthView.frame.origin.y + lastMonthView.frame.size.height - [monthView topOffset],
									 self.frame.size.width,
									 monthView.frame.size.height);
		[self insertSubview:monthView atIndex:0];
		
		[_monthViews addObject:monthView];
	}
	
	while ([self _firstMonthNeeded]) {
		TUMonthView *lastMonthView = [_monthViews objectAtIndex:0];
		
		TUMonthView *monthView = [self _dequeueMonthView];
		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = -1;
		monthView.month = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:lastMonthView.month options:0];
		monthView.frame = CGRectMake(0.0,
									 CGRectGetMinY(lastMonthView.frame) + [lastMonthView topOffset] - monthView.frame.size.height,
									 self.frame.size.width,
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

- (void)scrollToMonth:(NSDate *)month
{
	[self scrollToMonth:month animated:NO];
}

- (void)scrollToMonth:(NSDate *)month animated:(BOOL)animated
{
	CGPoint offset = self.contentOffset;
	TUMonthView *referenceMonthView = [_monthViews lastObject];
	
	offset.y =referenceMonthView.frame.origin.y + referenceMonthView.topOffset;
	
	NSDate *lastMonth = referenceMonthView.month;
	NSComparisonResult comparison;
	while ((comparison = [lastMonth.firstDayOfMonth compare:month.firstDayOfMonth]) != NSOrderedSame) {
		NSDateComponents *monthMovement = [[NSDateComponents alloc] init];
		monthMovement.month = (comparison == NSOrderedAscending) ? 1 : -1;
		NSDate *newMonth = [[NSCalendar currentCalendar] dateByAddingComponents:monthMovement toDate:lastMonth options:0];
		
		if (comparison == NSOrderedAscending) {
			offset.y += [TUMonthView verticalOffsetForWidth:self.frame.size.width month:lastMonth];
		} else {
			offset.y -= [TUMonthView verticalOffsetForWidth:self.frame.size.width month:newMonth];
		}
		
		lastMonth = newMonth;
	}
	
	offset.y += [TUMonthView topOffsetForWidth:self.frame.size.width month:month] + 1.0;
	
	[self setContentOffset:offset animated:animated];
}

@end
