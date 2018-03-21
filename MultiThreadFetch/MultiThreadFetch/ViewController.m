//
//  ViewController.m
//  MultiThreadFetch
//
//  Created by stefono on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "ViewController.h"
#import "WikiPageFetcher.h"
@interface ViewController ()

@end

@implementation ViewController

-(void)loadView
{
    [super loadView];
    WikiPageFetcher * pageFetcher = [[WikiPageFetcher alloc] init];
    [pageFetcher setTargetPage:@"Albert Einstein"];
    [pageFetcher start];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
