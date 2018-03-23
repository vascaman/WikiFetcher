//
//  ImageDetailViewController.m
//  MultiThreadFetch
//
//  Created by stefono on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "ImageDetailViewController.h"

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
        CGRect buttonRect = CGRectMake(0, 0, 50, 50);
        
        buttonRect.origin.x = self.view.bounds.size.width-buttonRect.size.width;
        
        closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setBackgroundColor:[UIColor lightGrayColor]];
        [closeButton setFrame:buttonRect];
        [closeButton addTarget:self
                        action:@selector(closeButtonDidPressed)
              forControlEvents:UIControlEventTouchUpInside];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
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