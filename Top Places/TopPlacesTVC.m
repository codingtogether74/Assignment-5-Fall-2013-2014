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
    [self createPlacesByCountryForPlaces:_places];
    [self.tableView reloadData];
}

- (NSString *)countryForPlace: (NSDictionary *) topPlace {
    NSString *placeInformation = [topPlace objectForKey:FLICKR_PLACE_NAME];
	return [[placeInformation componentsSeparatedByString:@", "] lastObject];
}

-(void)createPlacesByCountryForPlaces:(NSArray *)places
{
    // Create a sorted array of place descriptions
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME
                                                              ascending:YES]];
    
    // Set up the array of top places, organised by place descriptions
    NSArray *topPlaces = [places sortedArrayUsingDescriptors:sortDescriptors];

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
 
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    
    // Configure the cell..
	// Get a handle the dictionary that contains the selected top place information
	NSDictionary *topPlaceDictionary =
	[[self.placesByCountry objectForKey:[self.sectionHeaders objectAtIndex:indexPath.section]]
	 objectAtIndex:indexPath.row];
    
	// Extract the place name information for the cell
	NSString *topPlaceDescription = [topPlaceDictionary objectForKey:FLICKR_PLACE_NAME];

    // Format the top place description into the cell's title and subtitle
    // Find components of place name information
    
	NSMutableArray *placeNameComponents =[[topPlaceDescription componentsSeparatedByString:@", "] mutableCopy];
    // Remove country
    [placeNameComponents removeLastObject];
    
    NSString *titleCell = placeNameComponents[0];
    // Remove Title
     [placeNameComponents removeObjectAtIndex:0];
    
    NSString *subTitleCell = [placeNameComponents componentsJoinedByString:@", "];

    cell.textLabel.text = titleCell;
    cell.detailTextLabel.text = subTitleCell;
    return cell;
}


#pragma mark - Navigation


// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Place Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[PlaceFlickrPhotos class]]) {

                    // Identify the selected place from within the places by country dictionary
                    NSDictionary *place =
                    [[self.placesByCountry valueForKey:
                      [self.sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                    [segue.destinationViewController setPlace:place ];
                    [segue.destinationViewController setTitle:[[sender textLabel] text]];
                }
            }
            
            
        }
    }
}

@end
