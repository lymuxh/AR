//
//  ViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/10/23.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "ViewController.h"

#import "GameViewController.h"
#import "TdViewController.h"
#import "ThdViewController.h"
#import "ThdPositionDemoViewController.h"

#import "ARRotatoViewController.h"
#import "ARPlaneAnchorViewController.h"
#import "ARPlaneRotatoDemoViewController.h"
#import "ARPlaneRotatoViewController.h"

#import "SCNGameViewController.h"
#import "SCNActionViewController.h"
#import "HomeHeroViewController.h"

#import "ThdPictureDemoViewController.h"
#import "thdVideoDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


//游戏
-(IBAction)gameButtonClick:(id)sender{
    GameViewController *gameVC= [[GameViewController alloc]init];
    [self presentViewController:gameVC animated:YES completion:nil];
}

//2DDemo
- (IBAction)tdDemoClick:(id)sender {
    TdViewController *tdVC = [[TdViewController alloc]init];
    [self presentViewController:tdVC animated:YES completion:nil];
}

//3dDemo
- (IBAction)thdDemoClick:(id)sender {
    ThdViewController *thdVC = [[ThdViewController alloc]init];
    [self presentViewController:thdVC animated:YES completion:nil];
}

//3dPosition
- (IBAction)thdPositionDemoClick:(id)sender {
    ThdPositionDemoViewController *thdVC = [[ThdPositionDemoViewController alloc]init];
    [self presentViewController:thdVC animated:YES completion:nil];
}

//自转 公转
-(IBAction)startButtonClick:(id)sender{
    ARRotatoViewController *rotatoVC= [[ARRotatoViewController alloc]init];
    [self presentViewController:rotatoVC animated:YES completion:nil];
}


//太阳系演示
- (IBAction)rotatoCameraClick:(id)sender {
    
    ARPlaneRotatoDemoViewController *planeVC = [[ARPlaneRotatoDemoViewController alloc]init];
   [self presentViewController:planeVC animated:YES completion:nil];

/**
 添加太阳光焰
 */
    
//    SCNGameViewController *gameVC = [[SCNGameViewController alloc]init];
//    [self presentViewController:gameVC animated:YES completion:nil];
    
/**
 添加飞机和粒子火焰
 */
//    SCNActionViewController *actionVC = [[SCNActionViewController alloc]init];
//    [self presentViewController:actionVC animated:YES completion:nil];
}


//跟随移动
- (IBAction)flowCameraClick:(id)sender {
    ARPlaneRotatoViewController *planeRotatoVC = [[ARPlaneRotatoViewController alloc]init];
    [self presentViewController:planeRotatoVC animated:YES completion:nil];
}


//平面识别
- (IBAction)startPlaneAnchorClick:(id)sender {
    ARPlaneAnchorViewController *planeVC = [[ARPlaneAnchorViewController alloc]init];
    [self presentViewController:planeVC animated:YES completion:nil];
}


//平面识别用例
- (IBAction)homeHeroBtnClick:(id)sender {
    HomeHeroViewController *planeVC = [[HomeHeroViewController alloc]init];
    [self presentViewController:planeVC animated:YES completion:nil];
}

//全景照片
- (IBAction)thdPictureBtnClick:(id)sender {
    ThdPictureDemoViewController *planeVC = [[ThdPictureDemoViewController alloc]init];
    [self presentViewController:planeVC animated:YES completion:nil];
}


//全景视频
- (IBAction)thdVideoBtnClick:(id)sender {
    thdVideoDemoViewController *planeVC = [[thdVideoDemoViewController alloc]init];
    [self presentViewController:planeVC animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
