//
//  WikiPageFetcher.h
//  MultiThreadFetch
//
//  Created by stefono on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WIKI_API_BASE_URL @"https://en.wikipedia.org/w/api.php"
#define WIKI_MEDIA_BASE_URL @"https://en.wikipedia.org/wiki/"
@protocol WikiQueryDelegate <NSObject>

@optional
-(void)didReceivedResponse:(NSDictionary*)responseDict;

@end

@interface WikiPageFetcher : NSObject <WikiQueryDelegate>
@property(nonatomic, retain)NSString * targetPage;

-(void)start;

@end



@interface WikiQuery : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, retain) NSMutableDictionary * headers;
@property (nonatomic, assign) id delegate;
-(void)start;

@end