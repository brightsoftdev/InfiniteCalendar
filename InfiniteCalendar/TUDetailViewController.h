//
//  TUDetailViewController.h
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TUDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
