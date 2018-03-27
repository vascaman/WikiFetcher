//
//  ViewController.h
//  MultiThreadFetch
//
//  Created by Stefano Aru on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>


@end

@interface AruCellView : UITableViewCell

@end

@interface ToastView : NSObject
+(void)makeToastWihtText:(NSString*)text;
@end
