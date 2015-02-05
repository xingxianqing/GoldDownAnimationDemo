//
//  ViewController.m
//  DoldDownDemo
//
//  Created by 邢现庆 on 15-2-5.
//  Copyright (c) 2015年 邢现庆. All rights reserved.
//

#import "ViewController.h"
#import "WZGuideViewController.h"
//设备高度
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height
//设备宽度
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kCoinCountKey   300     //金币总数
@interface ViewController ()
@property(nonatomic,assign)int num;
@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.num=0;
    self.title = @"红包福利";
    
    UIImageView * backView = [[UIImageView alloc]init];
    backView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    backView.image = [UIImage imageNamed:@"bg.png"];

    [self.view addSubview:backView];
    
    
    _coinTagsArr = [NSMutableArray new];
    
    //主福袋层   icon_hongbao_bags
    _bagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"02"]];
    
    _bagView.frame = CGRectMake(ScreenWidth/2-67, ScreenHeight-130, 135, 131);
    
    
    [self.view addSubview:_bagView];
    
    [self getCoinAction:nil];
    
}

//统计金币数量的变量
static int coinCount = 0;
- (void)getCoinAction:(UIButton *)btn
{
    //初始化金币生成的数量
    coinCount = 0;
    for (int i = 0; i<=kCoinCountKey; i++) {
        
        //延迟调用函数
        [self performSelector:@selector(initCoinViewWithInt:) withObject:[NSNumber numberWithInt:i] afterDelay:i*0.01];
    }
}

- (void)initCoinViewWithInt:(NSNumber *)i
{
    
    int n = arc4random()%3;
    if (n==0||n==1) {
        n=1;
        
    }
    UIImageView *coin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"jinbi%d",n]]];
    
    
    int h1=ScreenHeight > 500 ? 20 : 50 ;
    
    //初始化金币的最终位置
    coin.center = CGPointMake(CGRectGetMidX(self.view.frame) + arc4random()%40 * (arc4random() %3 - 1) - 20, CGRectGetMidY(self.view.frame) - 20-h1);
    
    coin.tag = [i integerValue] + 1;
    
    //每生产一个金币,就把该金币对应的tag加入到数组中,用于判断当金币结束动画时和福袋交换层次关系,并从视图上移除
    [_coinTagsArr addObject:[NSNumber numberWithInteger:coin.tag]];
    
    [self.view addSubview:coin];
    
    [self setAnimationWithLayer:coin];
}

- (void)setAnimationWithLayer:(UIView *)coin
{
    
    CGFloat duration = 1.6f;
    //绘制从底部到福袋口之间的抛物线
    CGFloat positionX   = coin.layer.position.x;    //终点x
    CGFloat positionY   = coin.layer.position.y+200;    //终点y
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    int fromX   = arc4random() % (int)ScreenWidth;     //起始位置:x轴上随机生成一个位置
    
    int fromY  =  0;
    
    CGFloat cpx = positionX + (fromX - positionX)/2;    //x控制点
    
    CGFloat cpy = fromY / 2 - positionY;                //y控制点,确保抛向的最大高度在屏幕内,并且在福袋上方(负数)
    
    //动画的起始位置
    
    CGPathMoveToPoint(path, NULL, fromX, -50);
    
    CGPathAddQuadCurveToPoint(path, NULL, cpx, cpy, positionX, positionY);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:path];
    CFRelease(path);
    path = nil;
    
    //图像由大到小的变化动画
    CGFloat from3DScale = 1 + arc4random() % 10 *0.1*0.1;
    
    CGFloat to3DScale = from3DScale * 0.5*0.5;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0, from3DScale,from3DScale)], [NSValue valueWithCATransform3D:CATransform3DMakeScale(to3DScale, to3DScale, 0)]];
    
    scaleAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    //动画组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = duration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.animations = @[scaleAnimation, animation];
    [coin.layer addAnimation:group forKey:@"position and transform"];
}





- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // if (flag) {
    
    ++self.num;
    NSLog(@">>>%d",self.num);
    //动画完成后把金币和数组对应位置上的tag移除
    UIView *coinView = (UIView *)[self.view viewWithTag:[[_coinTagsArr firstObject] intValue]];
    [coinView removeFromSuperview];
    [_coinTagsArr removeObjectAtIndex:0];
    NSLog(@"con----%ld",(unsigned long)_coinTagsArr.count);
    //全部金币完成动画后执行的动作
    if (_coinTagsArr.count==0 ) {
        [self bagShakeAnimation];
    }
    //}
}

//福袋晃动动画
- (void)bagShakeAnimation
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:- 0.2];
    shake.toValue   = [NSNumber numberWithFloat:+ 0.2];
    shake.duration = 0.1;
    shake.autoreverses = YES;
    shake.repeatCount = 4;
    
    [_bagView.layer addAnimation:shake forKey:@"bagShakeAnimation"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{

                WZGuideViewController*  wzgu=[[WZGuideViewController alloc]init];
                wzgu.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:wzgu animated:YES completion:nil];
 
            
            
        });
        
    });
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
