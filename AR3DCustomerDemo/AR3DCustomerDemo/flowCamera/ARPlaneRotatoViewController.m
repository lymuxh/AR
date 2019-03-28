//
//  ARPlaneRotatoViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/10/23.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "ARPlaneRotatoViewController.h"
//3D游戏框架
#import <SceneKit/SceneKit.h>
//ARKit框架
#import <ARKit/ARKit.h>

@interface ARPlaneRotatoViewController ()<ARSessionDelegate>

//AR视图：展示3D界面
@property(nonatomic,strong)ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置：负责追踪相机的运动
@property(nonatomic,strong)ARConfiguration *arConfiguration;

//飞机3D模型(本小节加载多个模型)
@property(nonatomic,strong)SCNNode *planeNode;

//返回按钮
@property(nonatomic,strong)UIButton *backButton;

@end

@implementation ARPlaneRotatoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    //1.将AR视图添加到当前视图
    [self.view addSubview:self.arSCNView];
    
    //2.添加返回按钮
    [self.view insertSubview:self.backButton aboveSubview:self.arSCNView];
    
    self.arSession.delegate = self;
    
    //3.设置场景
    [self initplane];
    
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //2.开启AR会话（此时相机开始工作）
    [self.arSession runWithConfiguration:self.arConfiguration];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // Pause the view's session
    [self.arSession pause];
}


-(void)initplane{
    
    //1.使用场景加载scn文件（scn格式文件是一个基于3D建模的文件，使用3DMax软件可以创建，这里系统有一个默认的3D飞机）--------在右侧我添加了许多3D模型，只需要替换文件名即可
    SCNScene *scene = [SCNScene sceneNamed:@"3dart.scnassets/ship.scn"];
    
//    //2.创建一个3D物体模型 （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个球形，并且是否对平地做了一个缩放效果）
//    //参数分别是长宽高和圆角
//    SCNSphere *plane = [SCNSphere sphereWithRadius:1];
//
//    //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
//    plane.firstMaterial.diffuse.contents = @"earth.scnassets/earth/earth-diffuse-mini.jpg";;
//    plane.firstMaterial.emission.contents = @"earth.scnassets/earth/earth-emissive-mini.jpg";
//
//    //4.创建一个基于3D物体模型的节点
//    SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//    //5.设置节点的位置为捕捉到的平地的锚点的中心位置 SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
//    planeNode.position =SCNVector3Make(5, 0, -15);
//    [planeNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:10]]];
    
    //6.所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
    SCNNode *ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    //[ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:30]]];
    //[ship addChildNode:planeNode];
    ship.position= SCNVector3Make(0, -5, -15);
    self.planeNode = ship;
    self.arSCNView.scene =scene;
    
}

#pragma mark -ARSessionDelegate
//会话位置更新（监听相机的移动），此代理方法会调用非常频繁，只要相机移动就会调用，如果相机移动过快，会有一定的误差，具体的需要强大的算法去优化，笔者这里就不深入了
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
    NSLog(@"相机移动");
    //移动飞机
    if (self.planeNode) {
        //捕捉相机的位置，让节点随着相机移动而移动
        //根据官方文档记录，相机的位置参数在4X4矩阵的第三列
        self.planeNode.position =SCNVector3Make(frame.camera.transform.columns[3].x,frame.camera.transform.columns[3].y,frame.camera.transform.columns[3].z);
    }
}

#pragma mark -搭建ARKit环境

//懒加载会话追踪配置
- (UIButton *)backButton
{
    if (_backButton != nil) {
        return _backButton;
    }
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame=CGRectMake(10, 30, 80, 40) ;
    
    [_backButton.layer setMasksToBounds:YES];
    [_backButton.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [_backButton.layer setBorderWidth:1.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1 });
    [_backButton.layer setBorderColor:colorref];//边框颜色
    
    [_backButton setTitle:@"back" forState: UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backButton.backgroundColor = [UIColor clearColor];
    
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    return _backButton;
    
}

//懒加载会话追踪配置
- (ARConfiguration *)arConfiguration
{
    if (_arConfiguration != nil) {
        return _arConfiguration;
    }
    
    //1.创建世界追踪会话配置（使用ARWorldTrackingConfiguration效果更加好），需要A9芯片支持
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    //2.设置追踪方向（追踪平面，后面会用到）
    configuration.planeDetection = ARPlaneDetectionNone;
    _arConfiguration = configuration;
    //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
    _arConfiguration.lightEstimationEnabled = YES;
    
    return _arConfiguration;
    
}

//懒加载拍摄会话
- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    //1.创建会话
    _arSession = [[ARSession alloc] init];
    //2返回会话
    return _arSession;
}

//创建AR视图
- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    
    //1.创建AR视图
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    
    //2.设置视图背景
    _arSCNView.backgroundColor = [UIColor clearColor];
    
    //3.设置视图会话
    _arSCNView.session = self.arSession;
    
    //4.自动刷新灯光（3D游戏用到，此处可忽略）
    _arSCNView.automaticallyUpdatesLighting = YES;
    
    //5.显示统计信息
    _arSCNView.showsStatistics = YES;
    
    //6.允许相机控制
    //_arSCNView.allowsCameraControl = YES;
    
    //7.调试信息
    //    _arSCNView.debugOptions =
    //    ARSCNDebugOptionShowWorldOrigin |
    //    ARSCNDebugOptionShowFeaturePoints;
    
    return _arSCNView;
}

@end
