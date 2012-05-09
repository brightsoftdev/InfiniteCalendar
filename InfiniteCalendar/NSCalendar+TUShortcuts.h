//
//  NSCalendar+TUShortcuts.h
//  InfiniteCalendar
//
//  Created by David Beck on 5/9/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TUShortcuts)

- (NSDate *)firstDayOfMonth;
- (NSDate *)lastDayOfMonth;
- (NSInteger)weekday;

@end

@interface NSCalendar (TUShortcuts)

- (NSInteger)numberOfDaysInWeek;

@end
