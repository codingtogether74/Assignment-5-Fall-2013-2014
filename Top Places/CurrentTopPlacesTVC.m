//
//  CurrentTopPlacesTVC.m
//  Top Places
//
//  Created by Tatiana Kornilova on 12/16/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "CurrentTopPlacesTVC.h"
#import "FlickrFetcher.h"

@interface CurrentTopPlacesTVC ()

@end

@implementation CurrentTopPlacesTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchTopPlaces];


}
-(IBAction)fetchTopPlaces
{
    [self.refreshControl beginRefreshing]; // start the spinner
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];

    NSURL *url = [FlickrFetcher URLforTopPlaces];
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                options:0
                                                                  error:NULL];
        // get the NSArray of places NSDictionarys out of the results
        NSDictionary *placesResults = results[@"places"];
        NSArray *places = placesResults[@"place"];
        
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.places =places;
        });
    });
    
}


@end
