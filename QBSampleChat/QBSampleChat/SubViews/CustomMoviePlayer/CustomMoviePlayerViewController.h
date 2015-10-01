//
//  CustomMoviePlayerViewController.h
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CustomMoviePlayerViewController : UIViewController 
{
  MPMoviePlayerController *mp;
  NSURL 									*movieURL;
}

- (id)initWithPath:(NSString *)moviePath;
- (void)readyPlayer;

@end
