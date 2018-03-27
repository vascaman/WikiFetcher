//
//  WikiPageFetcher.m
//  MultiThreadFetch
//
//  Created by Stefano Aru on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "WikiPageFetcher.h"
@interface WikiPageFetcher()
@property(nonatomic, retain)WikiQuery * query;
@property(nonatomic, retain)NSMutableDictionary * imagesInPage;
@end

@implementation WikiPageFetcher
@synthesize targetPage;
@synthesize query;
@synthesize imagesInPage;

-(void)dealloc
{
    [imagesInPage release];
    [query release];
    [targetPage release];
    [super dealloc];
}

#pragma mark - Public method

-(void)clearCache
{
    [self.imagesInPage removeAllObjects];
}

-(void)start
{
    self.query = [[[WikiQuery alloc] init] autorelease];
    self.query.delegate = self;
    [self.query.headers setObject:self.targetPage forKey:@"titles"];
    [self.query.headers setObject:@"query" forKey:@"action"];
    [self.query.headers setObject:@"images" forKey:@"prop"];
    [self.query.headers setObject:@"json" forKey:@"format"];

    [self.query start];

    [[NSNotificationCenter defaultCenter] postNotificationName:WIKI_FETCHER_START_NOTIFICATION
                                                        object:self.targetPage];
}

-(NSDictionary*)getInfoDictForElementAtIndex:(NSInteger)index
{
    NSString * imageTitle = [[self.imagesInPage allKeys] objectAtIndex:index];
    
    NSString * imageFilePath = [[self.imagesInPage allValues] objectAtIndex:index];
    
    NSString * thumbFilePath = [imageFilePath stringByDeletingLastPathComponent];
    
    NSString * thumbImageFilename = [NSString stringWithFormat:@"thumb-%@", imageTitle];
    
    thumbFilePath = [thumbFilePath stringByAppendingPathComponent:thumbImageFilename];
    
    NSDictionary * infoDict = [NSDictionary dictionaryWithObjects:@[imageTitle, imageFilePath, thumbFilePath]
                                                          forKeys:@[@"title", @"filePath", @"thumbFilePath"]];
    
    return infoDict;
}

-(NSInteger)getElementsCount
{
    return [self.imagesInPage count];
}

#pragma mark - Batch Handling

-(NSMutableDictionary*)imagesInPage
{
    if (!imagesInPage)
    {
        imagesInPage = [[NSMutableDictionary alloc] init];
    }
    
    return imagesInPage;
}

-(void)updatePagesImagesWithResponseDict:(NSDictionary*)response
{
    NSDictionary * queryDict = [response objectForKey:@"query"];
    
    NSDictionary * pages = [queryDict objectForKey:@"pages"];
    
    for (NSDictionary * page in [pages allValues])
    {
        [self updatePageImageWithPageInfoDict:page];
    }
}

-(void)updatePageImageWithPageInfoDict:(NSDictionary*)pageInfoDict
{
    NSArray * images = [pageInfoDict objectForKey:@"images"];
    
    for (NSDictionary * imageInfoDict in images)
    {
        NSString * title = [[imageInfoDict objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"File:" withString:@""];
        
        [self.imagesInPage setObject:title forKey:title];
        
        [self downloadImageWithTitle:title withIndex:self.imagesInPage.count-1];
    }
}

#pragma mark - Image Download Logic


-(UIImage*)generateThumbWithImage:(NSData*)imageData
{
    CGSize thumbSize = CGSizeMake(50, 50);
    
    CGFloat scale = 1;
    
    UIImage * sourceImage = [UIImage imageWithData:imageData];
    
    if (sourceImage.size.width > thumbSize.width)
    {
        scale = thumbSize.width/sourceImage.size.width;
    }
    
    if (sourceImage.size.height*scale > thumbSize.height)
    {
        scale = (thumbSize.height*scale)/sourceImage.size.height;
    }

    UIImage * thumb = [UIImage imageWithData:imageData scale:scale];
    
    return thumb;
}

-(void)downloadImageWithTitle:(NSString*)titleImage withIndex:(NSInteger)index
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^{
                       NSString * imageUrlString = [NSString stringWithFormat:@"%@%@/%@?width=480",WIKI_MEDIA_BASE_URL, WIKI_SPECIAL_FILEPATH, titleImage];
                       
                       NSURL * imageUrl = [NSURL URLWithString:[imageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                       
                       NSData * imageData  = [NSData dataWithContentsOfURL:imageUrl];
                       
                       NSString * imageLocalFilePath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), titleImage];
                       
                       [imageData writeToFile:imageLocalFilePath atomically:YES];
                       
                       [self.imagesInPage setObject:imageLocalFilePath forKey:titleImage];
                       
                       //let's create thumb

                       UIImage * thumb = [self generateThumbWithImage:imageData];
                       
                       NSData * thumbData = UIImageJPEGRepresentation(thumb, 0.5);
                       
                       NSString * thumbLocalFilePath = [NSString stringWithFormat:@"%@/thumb-%@", NSTemporaryDirectory(), titleImage];
                       
                       [thumbData writeToFile:thumbLocalFilePath atomically:YES];
                       
                       [[NSNotificationCenter defaultCenter] postNotificationName:WIKI_FETCHER_IMAGE_DOWNLOADED_NOTIFICATION
                                                                           object:[NSNumber numberWithInteger:index]];
                   });
}

#pragma mark - WikiQuery Delegate Methods

-(void)didReceivedResponse:(NSDictionary *)responseDict
{
    
    [self updatePagesImagesWithResponseDict:responseDict];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WIKI_FETCHER_UPDATE_NOTIFICATION
                                                        object:self.targetPage];
    
    if ([responseDict objectForKey:@"batchcomplete"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:WIKI_FETCHER_FINISH_NOTIFICATION
                                                            object:self.targetPage];
        return;
    }
    
    NSDictionary * continueDict = [responseDict objectForKey:@"continue"];
    
    NSString * continueToken = [continueDict objectForKey:@"continue"];
    
    NSString * imContinue = [continueDict objectForKey:@"imcontinue"];
    
    [self.query.headers setObject:continueToken forKey:@"continue"];
    
    [self.query.headers setObject:imContinue forKey:@"imcontinue"];
    
    [self.query start];
}

@end

@interface WikiQuery()
@property(nonatomic, retain)NSURLConnection * connection;
@property(nonatomic, retain)NSMutableData * responseData;
@property(nonatomic, retain)NSDictionary * responseDict;
-(NSURLRequest*)getRequest;

@end

@implementation WikiQuery
@synthesize connection;
@synthesize headers;
@synthesize responseData;
@synthesize responseDict;

-(void)dealloc
{
    [responseDict release];
    [responseData release];
    [headers release];
    [connection release];
    [super dealloc];
}

#pragma mark - Public Methods

-(NSMutableDictionary*)headers
{
    if (!headers)
    {
        headers = [[NSMutableDictionary alloc] init];
    }
    
    return headers;
}

-(NSMutableData*)responseData
{
    if(!responseData)
    {
        responseData = [[NSMutableData alloc] init];
    }
    
    return responseData;
}

-(void)start
{
    self.responseData = [[[NSMutableData alloc] init] autorelease];
    
    NSURLRequest * myRequest = [self getRequest];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:myRequest
                                                      delegate:self
                                              startImmediately:YES];
}

#pragma mark - PrivateMethods
-(NSURLRequest*)getRequest
{
    NSMutableString * urlRequest = [NSMutableString stringWithString:WIKI_API_BASE_URL];
    
    [urlRequest appendString:@"?"];
    
    for (NSString * header in [self.headers allKeys])
    {
        NSString * headerValue = [self.headers objectForKey:header];
        [urlRequest appendFormat:@"%@=%@", header, headerValue];
        [urlRequest appendString:@"&"];
    }

    NSURL * url = [NSURL URLWithString:[urlRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return [NSURLRequest requestWithURL:url];
}

#pragma mark - NSURLConnection delegate methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responseDict = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                        options:0
                                                          error:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceivedResponse:)])
    {
        [self.delegate didReceivedResponse:self.responseDict];
    }
}





@end