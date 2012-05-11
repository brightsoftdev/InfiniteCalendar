//
//  NSCalendar+TUShortcuts.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/9/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "NSCalendar+TUShortcuts.h"

#import <objc/runtime.h>


@implementation NSDate (TUShortcuts)

- (NSDate *)firstDayOfMonth
{
	NSDate *firstDay = objc_getAssociatedObject(self, @"firstDayOfMonth");
	
	if (firstDay == nil) {
		NSDateComponents *components = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
		firstDay = [[NSCalendar sharedCalendar] dateFromComponents:components];
		objc_setAssociatedObject(self, @"firstDayOfMonth", firstDay, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}
	
	return firstDay;
}

- (NSDate *)lastDayOfMonth
{
	NSDate *lastDay = objc_getAssociatedObject(self, @"lastDayOfMonth");
	
	if (lastDay == nil) {
		NSDateComponents *components = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
		[components setDay:[[NSCalendar sharedCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self].length];
		lastDay = [[NSCalendar sharedCalendar] dateFromComponents:components];
		objc_setAssociatedObject(self, @"lastDayOfMonth", lastDay, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}
	
	return lastDay;
}

- (NSInteger)weekday
{
	NSNumber *weekday = objc_getAssociatedObject(self, @"weekday");
	
	if (weekday == nil) {
		weekday = [NSNumber numberWithInteger:[[NSCalendar sharedCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday];
		objc_setAssociatedObject(self, @"weekday", weekday, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}
	
	return [weekday integerValue];
}

@end

@implementation NSCalendar (TUShortcuts)

+ (NSCalendar *)sharedCalendar
{
	static NSCalendar *calendar = nil;
	if (calendar == nil) {
		calendar = [self autoupdatingCurrentCalendar];
	}
	
	return calendar;
}

- (NSInteger)numberOfDaysInWeek
{
	return [self rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[NSDate date]].length;
}

@end
