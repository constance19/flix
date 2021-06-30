//
//  DetailsViewController.m
//  flix
//
//  Created by constanceh on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the poster URL to set the poster view
//    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
//    NSString *posterURLString = self.movie.posterUrl;
//    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    //  [NSURL URLWithString:fullPosterURLString];
    
    NSURL *posterURL = self.movie.posterUrl;
    [self.posterView setImageWithURL:posterURL];
    
    
    // Get the low-resolution backdrop image
    NSString *urlSmall = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w45/%@", self.movie.backdropUrl];
    NSURL *urlLow = [NSURL URLWithString:urlSmall];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlLow];
    
    // Get the high-resolution backdrop image
    NSString *urlLarge = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original/%@", self.movie.backdropUrl];
    NSURL *urlHigh = [NSURL URLWithString:urlLarge];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlHigh];

    // Load a low-resolution image followed by a high-resolution image for the backdrop
    [self.backdropView setImageWithURLRequest:requestSmall
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       self.backdropView.alpha = 0.0;
                                       self.backdropView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                           
                                           self.backdropView.alpha = 1.0;
                                                            
                                       } completion:^(BOOL finished) {
                                           // The AFNetworking ImageView Category only allows one request to be sent at a time
                                           // per ImageView. This code must be in the completion block.
                                           [self.backdropView setImageWithURLRequest:requestLarge
                                                                  placeholderImage:smallImage
                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                               self.backdropView.image = largeImage;
                                               
                                           }
                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               // do something for the failure condition of the large image request
                                               // possibly setting the ImageView's image to a default image
                                               //cell.imageView.image =
                                           }];
                                           
                                       }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    
    // Set the text of the title and synopsis labels
    self.titleLabel.text = self.movie.title;
    self.synopsisLabel.text = self.movie.overview;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;

    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
