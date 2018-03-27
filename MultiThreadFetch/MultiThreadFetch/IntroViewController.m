//
//  IntroViewController.m
//  MultiThreadFetch
//
//  Created by stefono on 27/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "IntroViewController.h"

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

-(UITextView*)introText
{
    if (!introText)
    {
        CGFloat padding = 20;
        
        CGRect textViewRect = self.view.bounds;
        textViewRect.origin = CGPointMake(padding, padding);
        textViewRect.size.width -= padding*2;
        textViewRect.size.height -= padding*6;
        
        introText = [[UITextView alloc] initWithFrame:textViewRect];
        [introText setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
        [introText setTextAlignment:NSTextAlignmentCenter];
        [introText setEditable:NO];
        NSURL * textUrl = [NSURL URLWithString:@"https://raw.githubusercontent.com/vascaman/WikiFetcher/master/README.md"];
        
        NSString * text = [NSString stringWithContentsOfURL:textUrl
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        
        [introText setText:text];
        
        
        [introText.layer setBorderColor:[UIColor blueColor].CGColor];
        [introText.layer setBorderWidth:2];
    }
    
    return introText;
}

-(UIButton*)dismissButton
{
    if (!dismissButton)
    {
        dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 200, 50)];
        [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [dismissButton addTarget:self
                          action:@selector(dismiss)
                forControlEvents:UIControlEventTouchUpInside];
        [dismissButton setBackgroundColor:[UIColor redColor]];
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
    [self.view setBackgroundColor:[UIColor redColor]];
    //[self.introText setBackgroundColor:[UIColor whiteColor]];
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
