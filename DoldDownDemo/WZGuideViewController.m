//
//  WZGuideViewController.m
//  WZGuideViewController
//
//  Created by Wei on 13-3-11.
//  Copyright (c) 2013年 ZhuoYun. All rights reserved.
//

#import "WZGuideViewController.h"
#import "lastViewController.h"

//设备高度
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height
//设备宽度
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
@interface WZGuideViewController ()
@property(nonatomic,strong)UIView* animationView;
@property(nonatomic,strong)UIImageView* centerImage;
@property(nonatomic,strong)UIImageView* downImage;

@end

@implementation WZGuideViewController

@synthesize animating = _animating;

@synthesize pageScroll = _pageScroll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

#pragma mark -

- (CGRect)onscreenFrame
{
	return [UIScreen mainScreen].applicationFrame;
}

- (CGRect)offscreenFrame
{
	CGRect frame = [self onscreenFrame];
	switch ([UIApplication sharedApplication].statusBarOrientation)
    {
		case UIInterfaceOrientationPortrait:
			frame.origin.y = frame.size.height;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			frame.origin.y = -frame.size.height;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			frame.origin.x = frame.size.width;
			break;
		case UIInterfaceOrientationLandscapeRight:
			frame.origin.x = -frame.size.width;
			break;
	}
	return frame;
}

- (void)showGuide
{
	if (!_animating && self.view.superview == nil)
	{
		[WZGuideViewController sharedGuide].view.frame = [self offscreenFrame];
		[[self mainWindow] addSubview:[WZGuideViewController sharedGuide].view];
		
		_animating = YES;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(guideShown)];
		[WZGuideViewController sharedGuide].view.frame = [self onscreenFrame];
		[UIView commitAnimations];
	}
}

- (void)guideShown
{
	_animating = NO;
}

- (void)hideGuide
{
	if (!_animating && self.view.superview != nil)
	{
		_animating = YES;
        [WZGuideViewController sharedGuide].view.alpha=1;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(guideHidden)];
		[WZGuideViewController sharedGuide].view.frame = [self offscreenFrame];
        [WZGuideViewController sharedGuide].view.alpha=0;
		[UIView commitAnimations];
	}
    
}

- (void)guideHidden
{
	_animating = NO;
	[[[WZGuideViewController sharedGuide] view] removeFromSuperview];
    if (self.guideDelegate && [self.guideDelegate respondsToSelector:@selector(viewClickDid)]) {
        [self.guideDelegate viewClickDid];
        
    }
}

- (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
//    if ([app.delegate respondsToSelector:@selector(window)])
//    {
        return [app keyWindow];
//    }
//    else
//    {
//        return [app keyWindow];
//    }
}

+ (void)show
{
    [[WZGuideViewController sharedGuide].pageScroll setContentOffset:CGPointMake(0.f, 0.f)];
	[[WZGuideViewController sharedGuide] showGuide];
}

+ (void)hide
{
	[[WZGuideViewController sharedGuide] hideGuide];
}

#pragma mark - 

+ (WZGuideViewController *)sharedGuide
{
    @synchronized(self)
    {
        static WZGuideViewController *sharedGuide = nil;
        if (sharedGuide == nil)
        {
            sharedGuide = [[self alloc] init];
        }
        return sharedGuide;
    }
}

- (void)pressCheckButton:(UIButton *)checkButton
{
    [checkButton setSelected:!checkButton.selected];
}

- (void)pressEnterButton:(UIButton *)enterButton
{
    NSLog(@"=====tuichu===");
    //[[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [self hideGuide];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    
    NSArray *imageNameArray = [NSArray arrayWithObjects:@"1.png",  @"3.png",  nil];
    if (ScreenHeight<500) {
        imageNameArray = [NSArray arrayWithObjects:@"1.jpg",  @"daoyin3.png",  nil];
    }
    
    _pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [_pageScroll setTag:9999];
    self.pageScroll.pagingEnabled = YES;
    self.pageScroll.contentSize = CGSizeMake(self.view.frame.size.width * imageNameArray.count, ScreenHeight);
    [self.view addSubview:self.pageScroll];
    
    NSString *imgName = nil;
    UIImageView *view;
    for (int i = 0; i < imageNameArray.count; i++) {
        imgName = [imageNameArray objectAtIndex:i];
        view = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width * i), 0.f, ScreenWidth, ScreenHeight)];
        [view setUserInteractionEnabled:YES];
        [view setImage:[UIImage imageNamed:imgName]];
        
        [self.pageScroll addSubview:view];
        
        if (i == imageNameArray.count - 1) {
            view.userInteractionEnabled=YES;
            self.centerImage=[[UIImageView alloc]init];
            self.centerImage.frame=CGRectMake(view.frame.size.width/2-60, view.frame.size.height/2-40, 120, 120);
            
            self.downImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"jinbi.png"]];
            self.downImage.frame=CGRectMake(view.frame.size.width/2-30, view.frame.size.height-100, 60, 60);
            self.downImage.userInteractionEnabled=YES;
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(handlePan:)];
            [self.downImage addGestureRecognizer:panGestureRecognizer];
            [view addSubview:self.centerImage];
            [view addSubview:self.downImage];
            self.animationView=view;

        }
    }
}
- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    
    CGPoint translation = [recognizer translationInView:self.animationView];
    if (recognizer.view.center.y>self.centerImage.center.y) {
        recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                             recognizer.view.center.y + translation.y);
    }
    
    [recognizer setTranslation:CGPointZero inView:self.animationView];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (CGRectContainsPoint(self.centerImage.frame, self.downImage.center)) {
            self.downImage.center=self.centerImage.center;
            [UIView animateWithDuration:0.2 animations:^{
                self.downImage.alpha=0;
            }];
            lastViewController* last=[[lastViewController alloc  ]initWithNibName:@"lastViewController" bundle:nil];
            [self presentViewController:last animated:YES completion:nil];
            
            
        }else {
            [UIView animateWithDuration:0.3 animations:^{
                self.downImage.frame=CGRectMake(ScreenWidth/2-30, ScreenHeight-100, 60, 60);
            }];
        }
   
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
