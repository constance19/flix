//
//  MoviesGridViewController.m
//  flix
//
//  Created by constanceh on 6/24/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "MovieApimanager.h"
#import "Movie.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *gridSearch;
@property (strong, nonatomic) NSArray *filteredData;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.gridSearch.delegate = self;
    self.gridSearch.barStyle = UIBarStyleBlack;
    
    [self fetchMovies];
    self.filteredData = self.movies; // set filtered movies for search feature
    
    // Set grid view formatting
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    // For pull to refresh feature
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Handle network error with alert message
           if (error != nil) {
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                                                          message:@"The internet connection appears to be offline."
                                                                                   preferredStyle:(UIAlertControllerStyleAlert)];
               
               UIAlertAction *tryAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchMovies]; // try again response
                                                                 }];
               
               // add the try again action to the alertController
               [alert addAction:tryAction];
               
               [self presentViewController:alert animated:YES completion:^{
                   [self fetchMovies];
               }];
               
               NSLog(@"%@", [error localizedDescription]);
               
            // No network error
           } else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);

               // Get the array of movies
               MovieApiManager *manager = [MovieApiManager new];
               [manager fetchNowPlaying:^(NSArray *movies, NSError *error) {
                   if(movies){
                       self.movies = movies;
                       self.filteredData = self.movies;
                       [self.collectionView reloadData];
                   } else {
                       NSLog(@"%@", error.localizedDescription);
                   }
                   
               }];
           }
        
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

// Filtering of movies for search bar
- (void)searchBar:(UISearchBar *)gridSearch textDidChange:(NSString *)searchText {

    if (searchText.length != 0) {

        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Movie *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.title containsString:searchText];
        }];
        
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
        NSLog(@"Filtered");
        NSLog(@"%@", self.filteredData);
        NSLog(@"End of Filtered");
    }
    else {
        self.filteredData = self.movies;
    }

    [self.collectionView reloadData];

}

// Show cancel button on the far right of the search bar if user has typed
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.gridSearch.showsCancelButton = YES;
}

// When user clicks cancel button, delete text and hide cancel button
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.gridSearch.showsCancelButton = NO;
    self.gridSearch.text = @"";
    [self.gridSearch resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"collectionDetail"]) {
        UICollectionViewCell *selectedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:selectedCell];
//        NSDictionary *movie = self.movies[indexPath.item];
        Movie *movie = self.filteredData[indexPath.item];
        DetailsViewController *postersDetailViewController = [segue destinationViewController];
        postersDetailViewController.movie = movie;
        NSLog(@"Tapping on a poster cell movie!");
    }
}

// Get the number of movies that should be in view
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count;
}

// Set the poster image for each movie in view
// Includes optional feature of fading in and loading a high-res image followed by a low-res image
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    Movie *movie = self.filteredData[indexPath.item];
    
    NSURL *url = movie.posterUrl;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Gradually fade in the images loaded from the network
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil
                                    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
                                        // imageResponse will be nil if the image is cached
                                        if (imageResponse) {
                                            NSLog(@"Image was NOT cached, fade in image");
                                            cell.posterView.alpha = 0.0;
                                            cell.posterView.image = image;
                                            
                                            //Animate UIImageView back to alpha 1 over 0.3sec
                                            [UIView animateWithDuration:0.3 animations:^{
                                                cell.posterView.alpha = 1.0;
                                            }];
                                        }
        
                                        // If not cached
                                        else {
                                            NSLog(@"Image was cached so just update the image");
                                            cell.posterView.image = image;
                                        }
                                    }
     
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                        // do something for the failure condition
                                    }];
    
    return cell;
}


@end
