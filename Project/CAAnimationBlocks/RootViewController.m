#import "RootViewController.h"
#import "CAAnimation+Blocks.h"

@interface RootViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView *anotherImageView;

@end

@implementation RootViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.layer.shadowOffset = CGSizeMake(0, 4);
    self.imageView.layer.shadowRadius = 7;
    self.imageView.layer.shadowOpacity = 0.7;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.anotherImageView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(runAnimation:) withObject:nil afterDelay:1.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)runAnimation:(id)unused
{
    const CGFloat duration = 1.0f;
    const CGFloat angle = 12.0f;
    NSNumber *angleR = @(angle);
    NSNumber *angleL = @(-angle);
    
    CABasicAnimation *animationL = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    CABasicAnimation *animationR = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    void (^completionR)(BOOL) = ^(BOOL finished) {
        [self.imageView.layer setValue:angleL forKey:@"transform.rotation.z"];
        [self.imageView.layer addAnimation:animationL
                                    forKey:nil];
    };
    
    void (^completionL)(BOOL) = ^(BOOL finished) {
        [self.imageView.layer setValue:angleR forKey:@"transform.rotation.z"];
        [self.imageView.layer addAnimation:animationR
                                    forKey:nil];
    };
    
    animationL.fromValue = angleR;
    animationL.toValue = angleL;
    animationL.duration = duration;
    animationL.completion = completionL;
    
    animationR.fromValue = angleL;
    animationR.toValue = angleR;
    animationR.duration = duration;
    animationR.completion = completionR;
    
    [self.imageView.layer setValue:angleR forKey:@"transform.rotation.z"];
    [self.imageView.layer addAnimation:animationL
                                forKey:nil];
    
    CABasicAnimation *anotherAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    anotherAnimation.fromValue = @(self.anotherImageView.layer.position.x);
    anotherAnimation.toValue = @600;
    anotherAnimation.duration = 2;
    [anotherAnimation setCompletion:^(BOOL finished) {
        CABasicAnimation *oneMoreAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        oneMoreAnimation.fromValue = @600;
        oneMoreAnimation.toValue = @160;
        oneMoreAnimation.duration = 1;
        [self.anotherImageView.layer addAnimation:oneMoreAnimation
                                           forKey:nil];
    }];
    [self.anotherImageView.layer addAnimation:anotherAnimation
                                       forKey:nil];
}

@end
