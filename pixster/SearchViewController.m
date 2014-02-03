//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "GoogleCell.h"

NSInteger startIndex;
@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *googleSearchBar;


@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
        self.googleSearchBar.delegate = self;
        
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Register custom cell nib
     UINib *customNib = [UINib nibWithNibName:@"GoogleCell" bundle:nil];
    [self.photoCollectionView registerNib:customNib forCellWithReuseIdentifier:@"GoogleCell"];
    
    self.photoCollectionView.dataSource=self;
    self.photoCollectionView.delegate=self;
    
    startIndex = 1;
    self.photoCollectionView.alwaysBounceVertical = YES;
    [self.photoCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView data source


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


//Collection View method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.imageResults count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    static NSString *CellIdentifier = @"GoogleCell";
    
    //Dequeue or create cell of appropriate type
    GoogleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.googlePhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [cell.googlePhotoImageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKey:@"url"]]];
    //[self.photoCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    /*UIImageView *imageView = nil;
    const int IMAGE_TAG = 1;
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = IMAGE_TAG;
        [cell.contentView addSubview:imageView];
    } else {
        imageView = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
    }
    
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKey:@"url"]]];*/
    return cell;
    
}


#pragma mark -UIColelctiovViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *heightStr = [self.imageResults[indexPath.row]valueForKey:@"tbHeight"];
    NSString *widthStr = [self.imageResults[indexPath.row]valueForKey:@"tbWidth"];
    
    int height =  heightStr.intValue;
    int width = widthStr.intValue;
    
    CGSize retval;
    retval = CGSizeMake(50, 50);
   if(height !=0 && width != 0){
        retval = CGSizeMake(height, width);
        
    }else{
        retval = CGSizeMake(50, 50);
    }
    
    retval.height += 30;
    retval.width += 30;
    return retval;
    
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self.imageResults removeAllObjects];
    
    NSInteger start = 1;
    startIndex =1;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%u", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],start]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        NSLog(@"Results are :%@",results);
        [self.imageResults addObjectsFromArray:results];
        [self.photoCollectionView reloadData];
        
    } failure:nil];
    
    [operation start];
   
    
    
    [operation start];

    
    NSLog(@"The count of images:%u",self.imageResults.count);
    
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

#pragma -mark UIScroll View delegate methods
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSLog(@"UI Scroll view did end dragging");
    startIndex =startIndex + 4;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%u", [self.googleSearchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],startIndex]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        NSLog(@"Results are :%@",results);
        [self.imageResults addObjectsFromArray:results];
        [self.photoCollectionView reloadData];
        
    } failure:nil];
    
    [operation start];
    
}


@end
