//
//  WikiPageFetcher.h
//  MultiThreadFetch
//
//  Created by stefono on 21/03/18.
//  Copyright (c) 2018 stefano.aru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define WIKI_API_BASE_URL @"https://en.wikipedia.org/w/api.php"
#define WIKI_MEDIA_BASE_URL @"https://en.wikipedia.org/wiki/"
#define WIKI_SPECIAL_FILEPATH @"Special:Filepath"

#define WIKI_FETCHER_START_NOTIFICATION @"WIKI_FETCHER_START_NOTIFICATION"
#define WIKI_FETCHER_UPDATE_NOTIFICATION @"WIKI_FETCHER_UPDATE_NOTIFICATION"
#define WIKI_FETCHER_FINISH_NOTIFICATION @"WIKI_FETCHER_FINISH_NOTIFICATION"
#define WIKI_FETCHER_IMAGE_DOWNLOADED_NOTIFICATION @"WIKI_FETCHER_IMAGE_DOWNLOADED_NOTIFICATION"

@protocol WikiQueryDelegate <NSObject>

-(void)didReceivedResponse:(NSDictionary*)responseDict;

@end

@interface WikiPageFetcher : NSObject <WikiQueryDelegate>
@property(nonatomic, retain)NSString * targetPage;
-(NSInteger)getElementsCount;
-(NSDictionary*)getInfoDictForElementAtIndex:(NSInteger)index;
-(void)start;
-(void)clearCache;

@end



@interface WikiQuery : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, retain) NSMutableDictionary * headers;
@property (nonatomic, assign) id delegate;
-(void)start;

@end