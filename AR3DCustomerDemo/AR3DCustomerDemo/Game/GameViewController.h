//
//  GameViewController.h
//  GameDemo
//
//  Created by muxiaohui on 2017/10/25.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface GameViewController : UIViewController

//返回按钮
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)SCNView *scnView;
@end
