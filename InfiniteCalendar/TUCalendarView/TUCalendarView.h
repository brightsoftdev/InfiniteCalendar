//
//  TUCalendarView.h
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TUCalendarView : UIScrollView

@property (nonatomic, strong) NSDateComponents *selectedDay;
- (void)setSelectedDay:(NSDateComponents *)selectedDay animated:(BOOL)animated;

- (void)scrollToMonth:(NSDate *)month;
- (void)scrollToMonth:(NSDate *)month animated:(BOOL)animated;

@end
