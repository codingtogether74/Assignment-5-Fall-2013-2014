//
//  PlaceFlickrPhotos.m
//  Top Places
//
//  Created by Tatiana Kornilova on 12/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "PlaceFlickrPhotos.h"
#import "FlickrFetcher.h"

@interface PlaceFlickrPhotos ()

@end

@implementation PlaceFlickrPhotos
#define MAX_RESULTS 50


- (void)setPlace:(NSDictionary *)place
{
    _place = place;
    [self fetchPhotos];
}

-(void)fetchPhotos
{
    [self.refreshControl beginRefreshing];
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:[self.place valueForKeyPath:FLICKR_PLACE_ID] maxResults:MAX_RESULTS];
    dispatch_queue_t fetchQ =dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        

        NSDictionary *propertyListResults =[NSJSONSerialization JSONObjectWithData:jsonResults
                                                                           options:0
                                                                             error:NULL];
        
        NSArray *photos =[propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.photos =photos;
        });
        
    });
 
}

@end
