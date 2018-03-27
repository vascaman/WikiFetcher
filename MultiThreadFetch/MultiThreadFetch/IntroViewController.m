//
//  IntroViewController.m
//  MultiThreadFetch
//
//  Created by stefono on 27/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "IntroViewController.h"
#import "UIColor+ThemeColor.h"

@interface IntroViewController ()
@property(nonatomic, retain)UITextView * introText;
@property(nonatomic, retain)UIButton * dismissButton;
@end

@implementation IntroViewController
@synthesize introText;
@synthesize dismissButton;

-(void)dealloc
{
    [introText release];
    [dismissButton release];
    [super dealloc];
}

-(NSString*)introString
{
    return @"WELCOME!\n\nThe goal of this project is to present a simple use of interactions with Wikimedia API. \n\n The app presents itself with a search bar where you can insert a title of a wikipedia page, once you tap on search button the app will download all the images in the selected page. \n\n Then you can tap on any cell to see the image.\n\n Enjoy!";
}

-(UITextView*)introText
{
    if (!introText)
    {
        CGFloat padding = 10;
        
        CGRect textViewRect = self.view.bounds;
        textViewRect.origin = CGPointMake(padding, padding);
        textViewRect.size.width -= padding*2;
        //textViewRect.size.height /=1.5;
        
        introText = [[UITextView alloc] initWithFrame:textViewRect];
        [introText setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [introText setTextAlignment:NSTextAlignmentCenter];
        [introText setEditable:NO];
        [introText setFont:[UIFont systemFontOfSize:18]];
        [introText setTextColor:[UIColor themeColor]];
//        NSURL * textUrl = [NSURL URLWithString:@"https://raw.githubusercontent.com/vascaman/WikiFetcher/master/README.md"];
//        
//        NSString * text = [NSString stringWithContentsOfURL:textUrl
//                                                   encoding:NSUTF8StringEncoding
//                                                      error:nil];
//        
        [introText setText:[self introString]];
        
        
        //[introText.layer setBorderColor:[UIColor blueColor].CGColor];
        //[introText.layer setBorderWidth:2];
    }
    
    return introText;
}

-(UIButton*)dismissButton
{
    if (!dismissButton)
    {
//        CGFloat padding = 20;
//        
//        CGRect buttonFrame = CGRectZero;
//        buttonFrame.size.width = self.view.bounds.size.width - padding * 6;
//        buttonFrame.size.height = 50;
//        buttonFrame.origin.y = self.view.bounds.size.height - buttonFrame.size.height - padding;
//        buttonFrame.origin.x = padding * 3;
//        
//        
//        dismissButton = [[UIButton alloc] initWithFrame:buttonFrame];
//        [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
//        [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [dismissButton addTarget:self
//                          action:@selector(dismiss)
//                forControlEvents:UIControlEventTouchUpInside];
//        [dismissButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
//        [dismissButton setBackgroundColor:[UIColor themeColor]];
//        [dismissButton.layer setCornerRadius:5];
        
        
        CGRect buttonRect = CGRectZero;
        buttonRect.size = CGSizeMake(70, 70);
        buttonRect.origin.x = self.view.bounds.size.width-buttonRect.size.width/1.5;
        buttonRect.origin.y = self.view.bounds.size.height-buttonRect.size.height/1.5;
        //buttonRect.origin = CGPointMake(100, 100);
        dismissButton = [[UIButton alloc] initWithFrame:buttonRect];
        [dismissButton setBackgroundColor:[UIColor themeColor]];
        [dismissButton setTitle:@"GO" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissButton addTarget:self
                        action:@selector(dismiss)
              forControlEvents:UIControlEventTouchUpInside];
        [dismissButton.layer setCornerRadius:buttonRect.size.width/2];
        [dismissButton.layer setBorderWidth:2];
        [dismissButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [dismissButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, 0, 0)];
        [dismissButton setAutoresizesSubviews:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
        [dismissButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        
    }
    return dismissButton;
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setBorderColor:[UIColor themeColor].CGColor];
    [self.view.layer setBorderWidth:5];
    [self.view addSubview:self.introText];
    [self.view addSubview:self.dismissButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
