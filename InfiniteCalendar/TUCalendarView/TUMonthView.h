//
//  TUMonthView.h
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUCalendarView;


#define TUMonthLabelFont [UIFont boldSystemFontOfSize:16.0]
#define TUMonthLabelWidth 28.0
#define TUMonthBoundaryLineWidth 1.0
#define TUMonthBoundaryLineColor [UIColor darkGrayColor]


@interface TUMonthView : UIView

@property (nonatomic, weak) TUCalendarView *calendarView;
@property (nonatomic) NSDate *month;

- (CGFloat)topOffset;
+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month;
+ (CGFloat)verticalOffsetForWidth:(CGFloat)widthh month:(NSDate *)month;

- (NSDateComponents *)dayAtPoint:(CGPoint)point;

@end
