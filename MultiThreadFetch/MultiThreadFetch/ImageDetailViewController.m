//
//  ImageDetailViewController.m
//  MultiThreadFetch
//
//  Created by Stefano Aru on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "UIColor+ThemeColor.h"

@interface ImageDetailViewController ()
@property(nonatomic, retain)UIButton * closeButton;
@property(nonatomic, retain)UIImageView * imageView;
@end

@implementation ImageDetailViewController
@synthesize closeButton;
@synthesize imageFilePath;
@synthesize imageView;

-(void)dealloc
{
    [imageView release];
    [imageFilePath release];
    [closeButton release];
    [super dealloc];
}

-(UIButton*)closeButton
{
    if (!closeButton)
    {

        CGRect buttonRect = CGRectZero;
        buttonRect.size = CGSizeMake(50, 50);
        buttonRect.origin.x = self.view.bounds.size.width-buttonRect.size.width/1.5;
        buttonRect.origin.y = self.view.bounds.size.height-buttonRect.size.height/1.5;
        
        closeButton = [[UIButton alloc] initWithFrame:buttonRect];
        [closeButton setBackgroundColor:[UIColor themeColor]];
        [closeButton setTitle:@"x" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self
                        action:@selector(closeButtonDidPressed)
              forControlEvents:UIControlEventTouchUpInside];
        [closeButton.layer setCornerRadius:closeButton.frame.size.width/2];
        [closeButton.layer setBorderWidth:2];
        [closeButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        //[closeButton setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 45)];
        [closeButton setContentEdgeInsets:UIEdgeInsetsMake(-15, -15, 0, 0)];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    
    }
    
    return closeButton;
}

-(void)closeButtonDidPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIImageView*)imageView
{
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        UIImage * imageToSet = [[[UIImage alloc] initWithContentsOfFile:self.imageFilePath] autorelease];
        [imageView setImage:imageToSet];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];

    }
    
    return imageView;
}

-(void)loadView
{
    [super loadView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.closeButton];
    [self.view.layer setBorderColor:[UIColor themeColor].CGColor];
    [self.view.layer setBorderWidth:5];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setCornerRadius:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
