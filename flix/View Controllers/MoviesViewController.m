//
//  MoviesViewController.m
//  flix
//
//  Created by constanceh on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//@property (nonatomic) Reachability *internetReachability;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredData;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self.activityIndicator startAnimating];
    [self fetchMovies];
//    [self.activityIndicator stopAnimating];
    
    self.filteredData = self.movies;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)fetchMovies {
//    [self.activityIndicator startAnimating];
    
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
                   [self fetchMovies];
                                                                        // handle try again response here. Doing nothing will dismiss the view.
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
               
               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               self.filteredData = self.movies;
               
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               
               [self.tableView reloadData];
               
               // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
           }
        
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection: (NSInteger)section {
    return self.filteredData.count;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
//    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
//
////    NSLog(@"%@", [NSString stringWithFormat:@"row: %d, section %d", indexPath.row, indexPath.section]);
//
//    NSDictionary *movie = self.movies[indexPath.row];
//    cell.titleLabel.text = movie[@"title"];
//    cell.synopsisLabel.text = movie[@"overview"];
//
//    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
//    NSString *posterURLString = movie[@"poster_path"];
//    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
//
////    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
////    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
//
//    cell.posterView.image = nil;
//
//    [cell.posterView setImageWithURL:posterURL];
//
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
//    NSDictionary *movie = self.movies[indexPath.row];
    NSDictionary *movie = self.filteredData[indexPath.row];

    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w500/%@", movie[@"poster_path"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURL *urlSmall = [NSURL URLWithString:@"https://image.tmdb.org/t/p/w200/j0BtDE8M4Q2sJANrQjCosU8N7ji.jpg"];
    NSURL *urlLarge = [NSURL URLWithString:@"https://image.tmdb.org/t/p/w500/j0BtDE8M4Q2sJANrQjCosU8N7ji.jpg"];

    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];


    [cell.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       cell.posterView.alpha = 0.0;
                                       cell.posterView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            
                                           cell.posterView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [cell.posterView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                cell.posterView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length != 0) {

        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];

        NSLog(@"%@", self.filteredData);

    }
    else {
        self.filteredData = self.movies;
    }

    [self.tableView reloadData];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *tappedCell = sender;
    tappedCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    
    NSLog(@"Tapping on a list movie!");
    
}

@end
