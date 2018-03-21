//
//  WikiPageFetcher.m
//  MultiThreadFetch
//
//  Created by stefono on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import "WikiPageFetcher.h"
@interface WikiPageFetcher()
@property(nonatomic, retain)WikiQuery * query;
@end

@implementation WikiPageFetcher
@synthesize targetPage;
@synthesize query;

-(void)dealloc
{
    [query release];
    [targetPage release];
    [super dealloc];
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
}

#pragma mark - WikiQuery Delegate Methods
-(void)didReceivedResponse:(NSDictionary *)responseDict
{
    
    
    if ([responseDict objectForKey:@"batchcomplete"])
    {
        NSLog(@"done");
        return;
    }
    
    NSDictionary * continueDict = [responseDict objectForKey:@"continue"];
    
    NSString * continueToken = [continueDict objectForKey:@"continue"];
    
    NSString * imContinue = [continueDict objectForKey:@"imcontinue"];
    
    [self.query.headers setObject:continueToken forKey:@"continue"];
    
    [self.query.headers setObject:imContinue forKey:@"imcontinue"];
    
    NSLog(@"imcontinue %@", imContinue);

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