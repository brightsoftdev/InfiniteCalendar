//
//  TUCalendarView.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarView.h"

#import "TUMonthView.h"
#import "TUCalendarHeaderView.h"
#import "NSCalendar+TUShortcuts.h"


@interface TUCalendarView ()

- (BOOL)_lastMonthNeeded;
- (BOOL)_firstMonthNeeded;
- (void)_recenterIfNecessary;
- (void)_updateHeaderPosition;
- (void)_updateMonthViews;
- (TUMonthView *)_dequeueMonthView;

@end


@implementation TUCalendarView {
	NSMutableArray *_monthViews;
	NSMutableSet *_monthViewQueue;
	TUCalendarHeaderView *_headerView;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
		self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
		
		self.contentSize = CGSizeMake(self.bounds.size.width, 2000.0);
		
		_monthViews = [[NSMutableArray alloc] init];
		_monthViewQueue = [[NSMutableSet alloc] init];
		
		_headerView = [[TUCalendarHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 15.0)];
		_headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_headerView];
		
		
		TUMonthView *monthView = [self _dequeueMonthView];
		monthView.month = [NSDate date];
		monthView.frame = CGRectMake(0.0,
									 -1.0,
									 self.frame.size.width,
									 monthView.frame.size.height);
		[self insertSubview:monthView atIndex:0];
		[_monthViews addObject:monthView];
		
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self scrollToMonth:[NSDate date]];
		});
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
		self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
		
		self.contentSize = CGSizeMake(self.bounds.size.width, 2000.0);
		
		_monthViews = [[NSMutableArray alloc] init];
		_monthViewQueue = [[NSMutableSet alloc] init];
		
		_headerView = [[TUCalendarHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 15.0)];
		_headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_headerView];
		
		
		TUMonthView *monthView = [self _dequeueMonthView];
		monthView.month = [NSDate date];
		monthView.frame = CGRectMake(0.0,
									 -1.0,
									 self.frame.size.width,
									 monthView.frame.size.height);
		[self insertSubview:monthView atIndex:0];
		[_monthViews addObject:monthView];
		
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self scrollToMonth:[NSDate date]];
		});
    }
    return self;
}


#pragma mark - Month View Management

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


#pragma mark - Scroll Adjustments

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

- (void)_updateHeaderPosition
{
	CGRect headerFrame = _headerView.frame;
	headerFrame.origin.y = self.contentOffset.y;
	_headerView.frame = headerFrame;
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
		monthView.month = [[NSCalendar sharedCalendar] dateByAddingComponents:components toDate:lastMonthView.month options:0];
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
		monthView.month = [[NSCalendar sharedCalendar] dateByAddingComponents:components toDate:lastMonthView.month options:0];
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
	[self _updateHeaderPosition];
	[self _updateMonthViews];
}


#pragma mark - Scrolling Control

- (void)scrollToMonth:(NSDate *)month
{
	[self scrollToMonth:month animated:NO];
}

- (void)scrollToMonth:(NSDate *)month animated:(BOOL)animated
{
	CGPoint offset = self.contentOffset;
	TUMonthView *referenceMonthView = [_monthViews lastObject];
	
	offset.y = referenceMonthView.frame.origin.y + referenceMonthView.topOffset - _headerView.frame.size.height;
	
	NSDate *lastMonth = referenceMonthView.month;
	NSComparisonResult comparison;
	while ((comparison = [lastMonth.firstDayOfMonth compare:month.firstDayOfMonth]) != NSOrderedSame) {
		NSDateComponents *monthMovement = [[NSDateComponents alloc] init];
		monthMovement.month = (comparison == NSOrderedAscending) ? 1 : -1;
		NSDate *newMonth = [[NSCalendar sharedCalendar] dateByAddingComponents:monthMovement toDate:lastMonth options:0];
		
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
