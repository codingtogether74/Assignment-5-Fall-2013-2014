//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by Tatiana Kornilova on 12/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "FlickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
#import "RecentsUserDefaults.h"

@interface FlickrPhotosTVC ()

@end

@implementation FlickrPhotosTVC

-(void)setPhotos:(NSArray *)photos
{
    _photos =photos;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDaraSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}
#define FLICKR_UNKNOWN_PHOTO @"Unknown"

-(NSString *)titleForRow:(NSUInteger)row
{
    NSString *titleCell = [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_TITLE] description];
    if ([titleCell length]== 0) {
        titleCell = [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        if ([titleCell length]== 0) {
            titleCell = FLICKR_UNKNOWN_PHOTO;
        }
    }
    return titleCell;

}

-(NSString *)subTitleForRow:(NSUInteger)row
{
    NSString *subTitle = [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description]; // description because could be NSNull
    if ([[self titleForRow:row] isEqualToString:subTitle] || [[self titleForRow:row] isEqualToString:FLICKR_UNKNOWN_PHOTO]) {
        subTitle = @"";
    }
    return subTitle;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    
    return cell;
}

#pragma UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row] forRow:indexPath.row];
         [RecentsUserDefaults saveRecentsUserDefaults:self.photos[indexPath.row]];
    }
}

#pragma mark - Navigation
-(void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo forRow:(NSUInteger)row
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = [self titleForRow:row];//[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
   
}
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.photos[indexPath.row] forRow:indexPath.row
                     ];
                     [RecentsUserDefaults saveRecentsUserDefaults:self.photos[indexPath.row]];
                }
            }
        }
    }
}



@end
