//
//  ViewController.m
//  MultiThreadFetch
//
//  Created by stefono on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "ViewController.h"
#import "WikiPageFetcher.h"
#import "ImageDetailViewController.h"
#define WIKI_IMAGE_CELL_ID @"myCellId"
@interface ViewController ()
@property (nonatomic, retain)WikiPageFetcher * pageFetcher;
@property (nonatomic, retain)UITableView * imagesTableView;
@property (nonatomic, retain)UIActivityIndicatorView * spinner;
@property (nonatomic, retain)NSRecursiveLock * updateLock;
@end

@implementation ViewController
@synthesize pageFetcher;
@synthesize imagesTableView;
@synthesize spinner;
@synthesize updateLock;

-(void)dealloc
{
    [updateLock release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [spinner release];
    [imagesTableView setDelegate:nil];
    [imagesTableView setDataSource:nil];
    [imagesTableView release];
    [pageFetcher release];
    [super dealloc];
}

#pragma mark - Spinner handling

-(UIActivityIndicatorView*)spinner
{
    if (!spinner)
    {
        CGRect spinnerRect = CGRectMake(0, 0, 50, 50);
        spinnerRect.origin.x = self.view.bounds.size.width - spinnerRect.size.width;
        spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerRect];
        [spinner setBackgroundColor:[UIColor redColor]];
        [spinner setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
    }
    
    return spinner;
}

#pragma mark - TableView handling

-(UITableView*)imagesTableView
{
    if (!imagesTableView)
    {
        imagesTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [imagesTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [imagesTableView setDelegate:self];
        [imagesTableView setDataSource:self];
    }
    
    return imagesTableView;
}

#pragma mark  TableView datasource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pageFetcher getElementsCount];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:WIKI_IMAGE_CELL_ID];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:WIKI_IMAGE_CELL_ID] autorelease];
    }
    
    NSDictionary * imageInfoDict = [self.pageFetcher getInfoDictForElementAtIndex:indexPath.row];
    
    NSString * title = [imageInfoDict objectForKey:@"title"];
    
    [[cell textLabel] setText:title];
    
    NSString * imageFilePath = [imageInfoDict objectForKey:@"thumbFilePath"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath])
    {
        UIImage * cellImage = [UIImage imageWithContentsOfFile:imageFilePath];
        [cell.imageView setImage:cellImage];
    }else
    {
        [cell.imageView setImage:nil];
        [cell.imageView setBackgroundColor:[UIColor lightGrayColor]];
    }

    return cell;
}

#pragma mark - TableView Delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * imageInfoDict = [self.pageFetcher getInfoDictForElementAtIndex:indexPath.row];
    
    NSString * imageFilePath = [imageInfoDict objectForKey:@"filePath"];
    
    ImageDetailViewController * imageVC = [[ImageDetailViewController alloc] init];
    
    imageVC.imageFilePath = imageFilePath;
    
    [self presentViewController:imageVC animated:YES completion:nil];
    
    [imageVC release];
}

#pragma mark - Data logic methods

-(WikiPageFetcher*)pageFetcher
{
    if (!pageFetcher)
    {
        pageFetcher = [[WikiPageFetcher alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(wikiFetcherDidStarted:)
                                                     name:WIKI_FETCHER_START_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(wikiFetcherDidReceivedUpdate:)
                                                     name:WIKI_FETCHER_UPDATE_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(wikiFetcherDidFinished:)
                                                     name:WIKI_FETCHER_FINISH_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(wikiFetcherImageDownloaded:)
                                                     name:WIKI_FETCHER_IMAGE_DOWNLOADED_NOTIFICATION
                                                   object:nil];
    }
    
    return pageFetcher;
}

#pragma mark Updates from business logic

-(NSRecursiveLock*)updateLock
{
    if (!updateLock)
    {
        updateLock = [[NSRecursiveLock alloc] init];
    }
    
    return updateLock;
}

-(void)wikiFetcherImageDownloaded:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.updateLock lock];
        [self.imagesTableView reloadData];
        [self.updateLock unlock];
    });
}

-(void)wikiFetcherDidStarted:(NSNotificationCenter*)notification
{
    [self.spinner startAnimating];
}

-(void)wikiFetcherDidReceivedUpdate:(NSNotification*)notification
{
    [self.imagesTableView reloadData];
}

-(void)wikiFetcherDidFinished:(NSNotification*)notification
{
    [self.spinner stopAnimating];
}


#pragma mark - View Life Cycle Methods

-(void)loadView
{
    [super loadView];
    [self.view addSubview:self.imagesTableView];
    [self.view addSubview:self.spinner];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.pageFetcher setTargetPage:@"Apple Inc."];
    [self.pageFetcher start];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
