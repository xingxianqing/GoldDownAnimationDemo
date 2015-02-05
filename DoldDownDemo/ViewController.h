//
//  ViewController.h
//  DoldDownDemo
//
//  Created by 邢现庆 on 15-2-5.
//  Copyright (c) 2015年 邢现庆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

{
    UIButton        *_getBtn;
    UIImageView     *_bagView;      //福袋图层
    NSMutableArray  *_coinTagsArr;  //存放生成的所有金币对应的tag值
}
@end

