//
//  ViewController.m
//  MultiThreadFetch
//
//  Created by Stefano Aru on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "ViewController.h"
#import "WikiPageFetcher.h"
#import "ImageDetailViewController.h"
//#import "IntroViewController.h"

#define WIKI_IMAGE_CELL_ID @"myCellId"
@interface ViewController ()
@property (nonatomic, retain)WikiPageFetcher * pageFetcher;
@property (nonatomic, retain)UITableView * imagesTableView;
@property (nonatomic, retain)UIActivityIndicatorView * spinner;
@property (nonatomic, retain)NSRecursiveLock * updateLock;
@property (nonatomic, retain)UISearchBar * searchBar;
@property (nonatomic, assign)BOOL introDone;
@end

@implementation ViewController
@synthesize searchBar;
@synthesize pageFetcher;
@synthesize imagesTableView;
@synthesize spinner;
@synthesize updateLock;
@synthesize introDone;

-(void)dealloc
{
    [searchBar setDelegate:nil];
    [searchBar release];
    [updateLock release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [spinner release];
    [imagesTableView setDelegate:nil];
    [imagesTableView setDataSource:nil];
    [imagesTableView release];
    [pageFetcher release];
    [super dealloc];
}

#pragma mark - SearchBar handling

-(UISearchBar*)searchBar
{
    if (!searchBar)
    {
        CGRect searchBarFrame = CGRectMake(0, 0, self.view.bounds.size.width, 65);
        searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
        [searchBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        [searchBar setDelegate:self];
        //[searchBar.layer setBorderColor:[UIColor redColor].CGColor];
        //[searchBar.layer setBorderWidth:2];
        [searchBar setText:@"Albert Einstein"];
    }
    
    return searchBar;
}

#pragma mark SearchBar delegate methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [self.pageFetcher clearCache];
    [self.imagesTableView reloadData];
    [self.pageFetcher setTargetPage:_searchBar.text];
    [self.pageFetcher start];
}

#pragma mark - Spinner handling

-(UIActivityIndicatorView*)spinner
{
    if (!spinner)
    {
        CGRect spinnerRect = CGRectMake(0, 0, 35, 35);
        spinnerRect.origin.y = self.searchBar.bounds.size.height/2 - spinnerRect.size.height/2;
        spinnerRect.origin.x = self.view.bounds.size.width - spinnerRect.size.width;
        spinnerRect.origin.x -= spinnerRect.origin.y;
        spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerRect];
        [spinner setBackgroundColor:[UIColor lightGrayColor]];
        [spinner.layer setCornerRadius:spinner.bounds.size.height/2];
        [spinner setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    }
    
    return spinner;
}

#pragma mark - TableView handling

-(UITableView*)imagesTableView
{
    if (!imagesTableView)
    {
        CGRect tableViewFrame = CGRectZero;
        tableViewFrame.origin.x = 0;
        tableViewFrame.origin.y = self.searchBar.frame.size.height;
        tableViewFrame.size.height = self.view.bounds.size.height - self.searchBar.frame.size.height;
        tableViewFrame.size.width = self.view.bounds.size.width;
        imagesTableView = [[UITableView alloc] initWithFrame:tableViewFrame];
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

    AruCellView * cell = [tableView dequeueReusableCellWithIdentifier:WIKI_IMAGE_CELL_ID];
    
    if (!cell)
    {
        cell = [[[AruCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFilePath])
    {
        [self notifyUser:@"Image not yet downloaded\ntry again later.."];
        return;
    }
    
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
    [self.searchBar setUserInteractionEnabled:NO];
    [self.spinner startAnimating];
}

-(void)wikiFetcherDidReceivedUpdate:(NSNotification*)notification
{
    [self.imagesTableView reloadData];
}

-(void)wikiFetcherDidFinished:(NSNotification*)notification
{
    [self.spinner stopAnimating];
    [self.searchBar setUserInteractionEnabled:YES];
}


#pragma mark - View Life Cycle Methods

-(void)loadView
{
    [super loadView];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.imagesTableView];
    [self.view addSubview:self.spinner];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.introDone)
    {
//        IntroViewController * introVC = [[IntroViewController alloc] init];
//        
//        [self presentViewController:introVC
//                           animated:YES
//                         completion:nil];
//        
//        [introVC release];
        self.introDone = YES;
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)notifyUser:(NSString *)text
{
    [ToastView makeToastWihtText:text];
}

@end

#define CELL_PADDING 2

@interface AruCellView()
@property(nonatomic, retain)UIActivityIndicatorView * spinner;
@end

@implementation AruCellView
@synthesize spinner;


-(void)dealloc
{
    [spinner release];
    [super dealloc];
}

-(UIActivityIndicatorView*)spinner
{
    if (!spinner)
    {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return spinner;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateImageView];
    [self updateTextLabel];
    [self updateSeparator];
    [self updateSpinner];
}

-(void)updateSeparator
{
    self.separatorInset = UIEdgeInsetsZero;
}

-(void)updateSpinner
{
    if (self.imageView.image)
    {
        [self.spinner removeFromSuperview];
        return;
    }else if(![self.spinner isAnimating])
    {
        [self addSubview:self.spinner];
        [self.spinner startAnimating];
        CGRect newRect = CGRectZero;
        newRect.size.width = newRect.size.height = self.bounds.size.height - CELL_PADDING*2;
        newRect.origin.x = newRect.origin.y = CELL_PADDING;
        self.spinner.frame = newRect;
    }
}

-(void)updateTextLabel
{
    CGRect newRect = self.textLabel.frame;
    newRect.origin.x = self.imageView.frame.origin.x + self.imageView.frame.size.width + CELL_PADDING;
    newRect.size.width = self.bounds.size.width - newRect.origin.x - CELL_PADDING;
    [self.textLabel setFrame:newRect];
    //[self.textLabel.layer setBorderWidth:2];
    //[self.textLabel.layer setBorderColor:[UIColor blueColor].CGColor];
    
}

-(void)updateImageView
{
    CGRect newRect = CGRectZero;
    newRect.size.width = newRect.size.height = self.bounds.size.height - CELL_PADDING*2;
    newRect.origin.x = newRect.origin.y = CELL_PADDING;
    self.imageView.frame = newRect;
    //[self.imageView.layer setBorderWidth:2];
    //[self.imageView.layer setBorderColor:[UIColor redColor].CGColor];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
}

@end

@implementation ToastView

+(void)makeToastWihtText:(NSString*)text
{
    NSTimeInterval toastTime = 2.5;
    
    __block UILabel * labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 150)];
    [labelView setTextColor:[UIColor whiteColor]];
    [labelView setText:text];
    [labelView setNumberOfLines:3];
    [labelView.layer setCornerRadius:25];
    [labelView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [labelView.layer setBorderWidth:2];
    [labelView setClipsToBounds:YES];
    [labelView setBackgroundColor:[UIColor lightGrayColor]];
    [labelView setTextAlignment:NSTextAlignmentCenter];
    [labelView setCenter:[[[UIApplication sharedApplication] delegate] window].center];
    [labelView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:labelView];
    
    
    void(^animatedDismisBlock)(void);
    
    animatedDismisBlock = ^{
        [UIView beginAnimations:@"dismissAnimation" context:nil];
        [UIView setAnimationDelay:toastTime-1];
        [labelView setAlpha:0];
        [UIView setAnimationDuration:0.666];
        [UIView commitAnimations];
    };
    
    animatedDismisBlock();
    
    void (^dismissBlock)(void);
    
    dismissBlock = ^{
        
        [labelView performSelector:@selector(removeFromSuperview)
                        withObject:nil
                        afterDelay:toastTime];
        [labelView release];
        
    };
    
    dismissBlock();
    

}



@end
