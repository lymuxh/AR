//
//  ARPlaneAnchorViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/10/23.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "ARPlaneAnchorViewController.h"
//3D游戏框架
#import <SceneKit/SceneKit.h>
//ARKit框架
#import <ARKit/ARKit.h>


@interface ARPlaneAnchorViewController ()<ARSCNViewDelegate>{
    
    CGPoint _originalLocation;
}

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

@implementation ARPlaneAnchorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.arSCNView.backgroundColor = [UIColor blackColor];
    
    //将AR视图添加到当前视图
    [self.view addSubview:self.arSCNView];
    
    //添加返回按钮
    [self.view insertSubview:self.backButton aboveSubview:self.arSCNView];
    
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    _originalLocation = [touch locationInView:self.view];
    NSLog(@"touchesBegan = %.2f,%2.f",_originalLocation.x,_originalLocation.y);
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.view];
    CGRect frame = self.view.frame;
    frame.origin.x += currentLocation.x - _originalLocation.x;
    frame.origin.y += currentLocation.y - _originalLocation.y;
    
    NSLog(@"touchesMoved = %.2f,%2.f",currentLocation.x,currentLocation.y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.view];
    NSLog(@"touchesEnded = %.2f,%2.f",currentLocation.x,currentLocation.y);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.view];
    NSLog(@"touchesCancelled = %.2f,%2.f",currentLocation.x,currentLocation.y);
}

#pragma mark -- ARSCNViewDelegate

//添加节点时候调用（当开启平地捕捉模式之后，如果捕捉到平地，ARKit会自动添加一个平地节点）
- (void)renderer:(id )renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    NSLog(@"renderer:(id )renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor");
        //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地的3D模型来渲染他
        //1.获取捕捉到的平地锚点
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    
        //2.创建一个3D物体模型 （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形，并且是否对平地做了一个缩放效果）
        //参数分别是长宽高和圆角
        SCNPlane *plane = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
    
        //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
        plane.firstMaterial.diffuse.contents = [UIColor redColor];
    
        //4.创建一个基于3D物体模型的节点
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
    
        //5.设置节点的位置为捕捉到的平地的锚点的中心位置 SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
        planeNode.position =SCNVector3Make(planeAnchor.center.x, -0.1, planeAnchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(-M_PI / 2.0, 1.0, 0.0, 0.0);
        [node addChildNode:planeNode];
    
    //2.当捕捉到平地时，2s之后开始在平地上添加一个3D模型
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //1.创建一个飞机场景
        SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
        //2.获取飞机节点（一个场景会有多个节点，此处我们只写，飞机节点则默认是场景子节点的第一个）
        //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
        SCNNode *vaseNode = scene.rootNode.childNodes[0];
        
        //4.设置飞机节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
        vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        vaseNode.scale =SCNVector3Make(0.1, 0.1, 0.1);
        //5.将花瓶节点添加到当前屏幕中
        //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
        [node addChildNode:vaseNode];
        
    });
    
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;
{
   
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地的3D模型来渲染他
    //1.获取捕捉到的平地锚点
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    SCNNode *planeNode =node.childNodes[0];
    planeNode.position =SCNVector3Make(planeAnchor.center.x, -0.1, planeAnchor.center.z);
    SCNPlane *plane = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
    planeNode.geometry = plane;
    
    SCNNode *ship = [node childNodeWithName:@"ship" recursively:YES];
    ship.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
    
    NSLog(@"renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor");
}


- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;
{

    NSLog(@"renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor");
}

#pragma mark -搭建ARKit环境//懒加载会话追踪配置

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


- (ARConfiguration *)arConfiguration{
    if (_arConfiguration != nil) {
        return _arConfiguration;
    }
    //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    //2.设置追踪方向（追踪平面，后面会用到）
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arConfiguration = configuration;
    //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
    _arConfiguration.lightEstimationEnabled = YES;
    return _arConfiguration;
    
}


//懒加载拍摄会话
- (ARSession *)arSession
{
    if(_arSession != nil){
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
   
    //设置委托
    _arSCNView.delegate = self;
    
    //2.设置视图会话
    _arSCNView.session = self.arSession;
    
    //3.自动刷新灯光（3D游戏用到，此处可忽略）
    _arSCNView.automaticallyUpdatesLighting = YES;
    
    // Show statistics such as fps and timing information
    _arSCNView.showsStatistics = YES;
    
    //_arSCNView.allowsCameraControl = YES;
    
    _arSCNView.debugOptions =
    ARSCNDebugOptionShowWorldOrigin |
    ARSCNDebugOptionShowFeaturePoints;
    
    return _arSCNView;
}





@end
