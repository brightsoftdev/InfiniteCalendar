//
//  NSCalendar+TUShortcuts.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/9/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "NSCalendar+TUShortcuts.h"

@implementation NSDate (TUShortcuts)

- (NSDate *)firstDayOfMonth
{
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
	return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)lastDayOfMonth
{
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
	[components setDay:[[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self].length];
	return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSInteger)weekday
{
	return [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
}

@end

@implementation NSCalendar (TUShortcuts)

- (NSInteger)numberOfDaysInWeek
{
	return [self rangeOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[NSDate date]].length;
}

@end
