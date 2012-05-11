//
//  TUMonthView.h
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>


#define TUMonthLabelFont [UIFont boldSystemFontOfSize:16.0]
#define TUMonthLabelWidth 26.0
#define TUMonthBoundaryLineWidth 1.0
#define TUMonthBoundaryLineColor [UIColor darkGrayColor]


@interface TUMonthView : UIView

@property (nonatomic) NSDate *month;

- (CGFloat)topOffset;
+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month;
+ (CGFloat)verticalOffsetForWidth:(CGFloat)widthh month:(NSDate *)month;

@end
