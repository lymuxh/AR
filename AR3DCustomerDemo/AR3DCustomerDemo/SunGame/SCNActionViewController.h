//
//  SCNActionViewController.h
//  SceneKitRoationDemo
//
//  Created by tianpengfei on 16/5/8.
//  Copyright © 2016年 tianpengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface SCNActionViewController : UIViewController

@property (strong, nonatomic) UIButton *closeButton;

@property(strong,nonatomic)ARSCNView *scnView;
//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置：负责追踪相机的运动
@property(nonatomic,strong)ARConfiguration *arConfiguration;

@end
