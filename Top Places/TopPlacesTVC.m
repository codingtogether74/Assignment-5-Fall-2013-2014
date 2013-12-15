//
//  TopPlacesTVC.m
//  Top Places
//
//  Created by Tatiana Kornilova on 12/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"
#import "PlaceFlickrPhotos.h"

@interface TopPlacesTVC ()
@property (nonatomic, strong) NSDictionary *placesByCountry;
@property (nonatomic, strong) NSArray *countries;
@property (strong, nonatomic) NSArray *sectionHeaders;
@end

@implementation TopPlacesTVC

// whenever our Model is set, must update our View

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self fetchTopPlaces];
 
}
- (NSString *)countryForPlace: (NSDictionary *) topPlace {
    NSString *placeInformation = [topPlace objectForKey:FLICKR_PLACE_NAME];
	return [[placeInformation componentsSeparatedByString:@", "] lastObject];
}

-(IBAction)fetchTopPlaces
{
    [self.refreshControl beginRefreshing]; // start the spinner
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
        
        // Create a sorted array of place descriptions
        NSArray *sortDescriptors = [NSArray arrayWithObject:
                                    [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME
                                                                  ascending:YES]];
        
        
        // Set up the array of top places, organised by place descriptions
        NSArray *topPlaces = [places sortedArrayUsingDescriptors:sortDescriptors];
 //       NSLog(@"places %@",topPlaces);
  //----------------
        // We want to divide the places up by country, so we can use a dictionary with the
        // country names as key and the places as values
        NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
        
        // For each place
        for (NSDictionary *place in topPlaces) {
            // extract the country name
            NSString *country = [self countryForPlace:place];
            // If the country isn't already in the dictionary, add it with a new array
            if (![placesByCountry objectForKey:country]) {
                [placesByCountry setObject:[NSMutableArray array] forKey:country];
            }
            // Add the place to the countries' value array
            [(NSMutableArray *)[placesByCountry objectForKey:country] addObject:place];
        }
        
        // Set the place by country
        self.placesByCountry = [NSDictionary dictionaryWithDictionary:placesByCountry];
        
        // Set up the section headers in alphabetical order
        self.sectionHeaders = [[placesByCountry allKeys] sortedArrayUsingSelector:
                               @selector(caseInsensitiveCompare:)];
       
  //-------------------
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
                  self.places =places;
        });
    });

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return self.sectionHeaders.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	// Return the header at the given index
	return [self.sectionHeaders objectAtIndex:section];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	return [[self.placesByCountry objectForKey:
             [self.sectionHeaders objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top places";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
	// Get a handle the dictionary that contains the selected top place information
	NSDictionary *topPlaceDictionary =
	[[self.placesByCountry objectForKey:[self.sectionHeaders objectAtIndex:indexPath.section]]
	 objectAtIndex:indexPath.row];
    
	// Extract the place name information for the cell
	NSString *topPlaceDescription = [topPlaceDictionary objectForKey:FLICKR_PLACE_NAME];
	
	// Format the top place description into the cell's title and subtitle
	// Check to see if place description has a comma
	NSRange firstComma = [topPlaceDescription rangeOfString:@","];
	
	// If no comma, then title is place description and we have no subtitle, otherwise set the
	// title to everything before the comma and the subtitle to everything after it.
	if (firstComma.location == NSNotFound) {
		cell.textLabel.text = topPlaceDescription;
		cell.detailTextLabel.text = @"";
	} else {
		cell.textLabel.text = [topPlaceDescription substringToIndex:firstComma.location];
		cell.detailTextLabel.text = [topPlaceDescription substringFromIndex:
                                     firstComma.location + 1];
	}
    return cell;
}


#pragma mark - Navigation


// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Place Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[PlaceFlickrPhotos class]]) {

                    // Identify the selected place from within the places by country dictionary
                    NSDictionary *place =
                    [[self.placesByCountry valueForKey:
                      [self.sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
//                    self.placesByCountry[self.countries[indexPath.section]][indexPath.row];
                    [segue.destinationViewController setPlace:place ];
                    [segue.destinationViewController setTitle:[[sender textLabel] text]];
                }
            }
            
            
        }
    }
}

 

@end
