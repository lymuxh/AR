//
//  ThdPictureDemoViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/11/27.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "ThdPictureDemoViewController.h"

@interface ThdPictureDemoViewController ()
//AR视图：展示3D界面
@property(nonatomic,strong)ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置：负责追踪相机的运动
@property(nonatomic,strong)ARConfiguration *arConfiguration;

//返回按钮
@property(nonatomic,strong)UIButton *backButton;

@end

@implementation ThdPictureDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.将AR视图添加到当前视图
    [self.view addSubview:self.arSCNView];
    
    //2.添加返回按钮
    [self.view insertSubview:self.backButton aboveSubview:self.arSCNView];
    
    //3.设置场景
    [self initplane];
    
    //4.添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:self.arSCNView.gestureRecognizers];
    self.arSCNView.gestureRecognizers = gestureRecognizers;
    
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
    //开启AR会话（此时相机开始工作）
    [self.arSession runWithConfiguration:self.arConfiguration];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // Pause the view's session
    [self.arSession pause];
}


-(void)initplane{
    
    //1.创建一个摄像机
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.automaticallyAdjustsZRange = true;// 自动调节可视范围
    cameraNode.position = SCNVector3Make(0, 0, 0);// 把摄像机放在中间
    [self.arSCNView.scene.rootNode addChildNode:cameraNode];
    
    //1.创建一个3D物体模型
    SCNSphere *panorama = [SCNSphere sphereWithRadius:10];
    panorama.firstMaterial.doubleSided = NO ;
    panorama.firstMaterial.cullMode = SCNCullModeFront;
    //2.使用Material渲染3D模型
    panorama.firstMaterial.diffuse.contents = @"car";
    //3.创建一个基于3D物体模型的节点
    SCNNode *panoramaNode = [SCNNode nodeWithGeometry:panorama];
    //4.设置节点的位置 SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
    panoramaNode.position = SCNVector3Make(0, 0, 0);
    //panoramaNode.rotation =SCNVector4Make(0, 0, 0, 1);
    [self.arSCNView.scene.rootNode addChildNode:panoramaNode];
    
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:self.arSCNView];
    NSArray *hitResults = [self.arSCNView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
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
    //2.设置追踪方向
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
    _arSCNView.backgroundColor = [UIColor blackColor];
    
    //3.设置视图会话
    _arSCNView.session = self.arSession;
    
    //4.自动刷新灯光（3D游戏用到，此处可忽略）
    _arSCNView.automaticallyUpdatesLighting = YES;
    
    //5.显示统计信息
    _arSCNView.showsStatistics = YES;
    
    //6.允许相机控制
    _arSCNView.allowsCameraControl = YES;
    
    //7.调试信息
    _arSCNView.debugOptions =
    ARSCNDebugOptionShowWorldOrigin |
    ARSCNDebugOptionShowFeaturePoints;
    
    return _arSCNView;
}


@end
