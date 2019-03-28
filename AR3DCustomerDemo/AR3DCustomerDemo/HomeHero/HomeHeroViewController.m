//
//  HomeHeroViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/11/7.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "HomeHeroViewController.h"
//3D游戏框架
#import <SceneKit/SceneKit.h>
//ARKit框架
#import <ARKit/ARKit.h>

#import "SelectableButton.h"
#import "SCNNodeHelpers.h"

@interface HomeHeroViewController ()<ARSCNViewDelegate>

{
    
    NSMutableArray *_measuringNodes;
    
    NSMutableArray *_objects;
    
    NSMutableArray *_functionArray;
    
    NSString *_currentFunction;
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


//花瓶
@property(nonatomic,strong)SelectableButton *vaseButton;

//椅子
@property(nonatomic,strong)SelectableButton *chairButton;

//蜡烛
@property(nonatomic,strong)SelectableButton *candleButton;

//测量
@property(nonatomic,strong)SelectableButton *measureButton;

//十字瞄准线
@property(nonatomic,strong)UIView *crosshair;

//距离
@property(nonatomic,strong)UILabel *distanceLabel;

//消息
@property(nonatomic,strong)UILabel *messageLabel;

//跟踪信息
@property(nonatomic,strong)UILabel *trackingInfoLabel;

//刷新界面
@property(nonatomic,strong)SelectableButton *refreshButton;

@end

@implementation HomeHeroViewController


-(id)init{
    
    if (self = [super init]) {
        _measuringNodes =[NSMutableArray array];
        _objects = [NSMutableArray array];
        //_functionArray=@[@"none",];
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.arSCNView.backgroundColor = [UIColor blackColor];
    
    //将AR视图添加到当前视图
    [self.view addSubview:self.arSCNView];
    
    //添加返回按钮
    [self.view insertSubview:self.backButton aboveSubview:self.arSCNView];
    
    [self.view addSubview:self.vaseButton];
    [self.view addSubview:self.chairButton];
    [self.view addSubview:self.candleButton];
    [self.view addSubview:self.measureButton];
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.crosshair];
    [self.view insertSubview:self.distanceLabel aboveSubview:self.arSCNView];
    [self.view insertSubview:self.messageLabel aboveSubview:self.arSCNView];
    [self.view insertSubview:self.trackingInfoLabel aboveSubview:self.arSCNView];
    
    self.trackingInfoLabel.text = @"";
    self.messageLabel.text = @"";
    self.distanceLabel.hidden = YES;
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
    [self selectVase];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // Pause the view's session
    [self.arSession pause];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSArray *arr =  [self.arSCNView hitTest:self.view.center types:ARHitTestResultTypeExistingPlaneUsingExtent];
    if ([arr count]>0) {
        ARHitTestResult *result =[arr firstObject];
        [self.arSCNView.session addAnchor: [[ARAnchor alloc] initWithTransform:result.worldTransform]];
        return;
    }
    
    NSArray *arr2 = [self.arSCNView hitTest:self.view.center types:ARHitTestResultTypeFeaturePoint];
    if ([arr2 count]>0) {
        ARHitTestResult *result =[arr2 lastObject];
        [self.arSCNView.session addAnchor: [[ARAnchor alloc] initWithTransform:result.worldTransform]];
        return;
    }
    
}

#pragma mark ARSCNViewDelegate

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    [self showMessage:error.description];
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
     [self showMessage:@"Session interrupted"];
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
     [self showMessage:@"Session resumed"];
    
    [self removeAllObject];
    [self.arSession runWithConfiguration:self.arConfiguration];
}



- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
           
            //1.获取捕捉到的平地锚点
            ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
            
            SCNNode *planeNode = [SCNNodeHelpers createPlaneNode:planeAnchor.center Extent:planeAnchor.extent];
            
            [node addChildNode:planeNode];
            
        }else{
            
            if ([_currentFunction isEqualToString:@"none"]) {
                
            }else if([_currentFunction containsString:@"Models."]){
                SCNNode *modelClone =  [SCNNodeHelpers nodeWithModelName:_currentFunction];
                [_objects addObject:modelClone];
                modelClone.position = SCNVector3Zero;
                [node addChildNode:modelClone];
                
            }else if([_currentFunction isEqualToString:@"measure"]){
                
                SCNNode *sphereNode =  [SCNNodeHelpers createSphereNode:0.02];
                [_objects addObject:sphereNode];
                sphereNode.position =SCNVector3Zero;
                [node addChildNode:sphereNode];
                [_measuringNodes addObject:node];
    
            }
        }
    });
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    dispatch_async(dispatch_get_main_queue(), ^{
         if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
             
              ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
             
             [SCNNodeHelpers updatePlaneNode:node.childNodes[0] Center:planeAnchor.center Extent:planeAnchor.extent];
             
         }else{
             
             [self updateMeasuringNodes];
         }
        
        });
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateTrackingInfo];
        
        NSArray *arr =  [self.arSCNView hitTest:self.view.center types:ARHitTestResultTypeExistingPlaneUsingExtent];
        
        for (int i = 0; i<[arr count]; i++) {
            if (i == 0) {
                self.crosshair.backgroundColor = [UIColor greenColor];
            }else{
                self.crosshair.backgroundColor = [UIColor colorWithWhite:0.34 alpha:1];
            }
        }
    });
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
            
            [SCNNodeHelpers removeChildren:node];
            
        }else{
            
        }
    });
}


-(void)updateMeasuringNodes{
    
    if ([_measuringNodes count] > 1) {
        
    }else{
        return;
    }
    
    SCNNode * firstNode = _measuringNodes[0];
    SCNNode * secondNode = _measuringNodes[1];

    BOOL showMeasuring = [_measuringNodes count] == 2;
    
    _distanceLabel.hidden = !showMeasuring;
    
    if (showMeasuring) {
        [self measureFromNode:firstNode toNode:secondNode];
    } else if ([_measuringNodes count] > 2 ) {
        [firstNode removeFromParentNode];
        [secondNode removeFromParentNode];
        [_measuringNodes removeObjectsInRange:NSMakeRange(0,2)];
        
        for ( SCNNode *  node in self.arSCNView.scene.rootNode.childNodes) {
            if ([node.name isEqualToString: @"MeasuringLine"]) {
                [node removeFromParentNode];
            }
        }
    }
}


-(void)measureFromNode:(SCNNode *)fromNode toNode:(SCNNode *)toNode{
    
    SCNNode *measuringLineNode =  [SCNNodeHelpers createLineNode:fromNode to:toNode];
    measuringLineNode.name = @"MeasuringLine";
    [self.arSCNView.scene.rootNode addChildNode:measuringLineNode];
    [_objects addObject:measuringLineNode];
    
    float distance = sqrtf((fromNode.position.x-toNode.position.x)*(fromNode.position.x-toNode.position.x)+(fromNode.position.y-toNode.position.y)*(fromNode.position.y-toNode.position.y)+(fromNode.position.z-toNode.position.z)*(fromNode.position.z-toNode.position.z));

    _distanceLabel.text =[NSString stringWithFormat:@"Distance:%.2f m",distance];
}


-(void)updateTrackingInfo{
    
//    guard let frame = sceneView.session.currentFrame else {
//        return
//    }
    
    ARFrame *frame = self.arSCNView.session.currentFrame;
    ARTrackingState state = frame.camera.trackingState;
    
    if (state == ARTrackingStateLimited) {
        ARTrackingStateReason reason = frame.camera.trackingStateReason;
        if (reason == ARTrackingStateReasonExcessiveMotion) {
            _trackingInfoLabel.text = @"Limited Tracking: Excessive Motion";
        }else if(reason == ARTrackingStateReasonInsufficientFeatures){
            _trackingInfoLabel.text = @"Limited Tracking: Insufficient Details";
        }else{
            _trackingInfoLabel.text = @"Limited Tracking";
        }
    }else{
        _trackingInfoLabel.text = @"";
    }
    
   
    float lightEstimate = frame.lightEstimate.ambientIntensity;
    
    if (lightEstimate < 100) {
        _trackingInfoLabel.text = @"Limited Tracking: Too Dark";
    }
}



-(void)showMessage:(NSString *)text{
    
    _messageLabel.text = text;

    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        _messageLabel.text=@"";
    });
}


#pragma mark function

-(void)didTapVase{
    [self selectVase];
}

-(void)didTapChair{
    _currentFunction = @"Models.scnassets/chair/chair.scn";
    [self selectButton:_chairButton];
}

-(void)didTapCandle{
    _currentFunction = @"Models.scnassets/candle/candle.scn";
    [self selectButton:_candleButton];
}

-(void)didTapMeasure{
    _currentFunction = @"measure";
    [self selectButton:_measureButton];
}

-(void)didTapRefesh{

    [self removeAllObject];
    self.distanceLabel.text = @"";
}


-(void) selectVase{
    _currentFunction = @"Models.scnassets/vase/vase.scn";
    [self selectButton:_vaseButton];
}


-(void) selectButton:(UIButton *)btn {
    [self unselectAllButtons];
    btn.selected = true;
}

-(void) unselectAllButtons {
    
    _vaseButton.selected = NO;
    _chairButton.selected = NO;
    _candleButton.selected = NO;
    _measureButton.selected =NO;
    _refreshButton.selected = NO;
}

-(void)removeAllObject{
    for (SCNNode *obj in _objects) {
        [obj removeFromParentNode];
    }
    [_objects removeAllObjects];
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


//懒加载会话追踪配置
- (UIButton *)vaseButton
{
    if (_vaseButton != nil) {
        return _vaseButton;
    }
    _vaseButton = [SelectableButton buttonWithType:UIButtonTypeCustom];
    _vaseButton.frame=CGRectMake(10, 100, 50, 60) ;
    [_vaseButton setTitle:@"⚱️" forState:UIControlStateNormal];
    [_vaseButton setBackgroundColor:[UIColor colorWithRed:51/255.0 green:201/255.0 blue:153/255.0 alpha:1]];
    [_vaseButton addTarget:self action:@selector(didTapVase) forControlEvents:UIControlEventTouchUpInside];
    
    return _vaseButton;
    
}

//懒加载会话追踪配置
- (UIButton *)chairButton
{
    if (_chairButton != nil) {
        return _chairButton;
    }
    _chairButton = [SelectableButton buttonWithType:UIButtonTypeCustom];
    _chairButton.frame=CGRectMake(10, 180, 50, 60) ;
    [_chairButton setTitle:@"💺" forState:UIControlStateNormal];
    [_chairButton setBackgroundColor:[UIColor colorWithRed:51/255.0 green:201/255.0 blue:153/255.0 alpha:1]];
    [_chairButton addTarget:self action:@selector(didTapChair) forControlEvents:UIControlEventTouchUpInside];
    
    return _chairButton;
    
}

//懒加载会话追踪配置
- (UIButton *)candleButton
{
    if (_candleButton != nil) {
        return _candleButton;
    }
    _candleButton = [SelectableButton buttonWithType:UIButtonTypeCustom];
    _candleButton.frame=CGRectMake(10, 260, 50, 60) ;
    [_candleButton setTitle:@"🕯" forState:UIControlStateNormal];
    [_candleButton setBackgroundColor:[UIColor colorWithRed:51/255.0 green:201/255.0 blue:153/255.0 alpha:1]];
    [_candleButton addTarget:self action:@selector(didTapCandle) forControlEvents:UIControlEventTouchUpInside];
    
    return _candleButton;
    
}

//懒加载会话追踪配置
- (UIButton *)measureButton
{
    if (_measureButton != nil) {
        return _measureButton;
    }
    _measureButton = [SelectableButton buttonWithType:UIButtonTypeCustom];
    _measureButton.frame=CGRectMake(10, 340, 50, 60) ;
    [_measureButton setTitle:@"📏" forState:UIControlStateNormal];
    [_measureButton setBackgroundColor:[UIColor colorWithRed:51/255.0 green:201/255.0 blue:153/255.0 alpha:1]];
    [_measureButton addTarget:self action:@selector(didTapMeasure) forControlEvents:UIControlEventTouchUpInside];
    
    return _measureButton;
    
}


//懒加载会话追踪配置
- (UIButton *)refreshButton
{
    if (_refreshButton != nil) {
        return _refreshButton;
    }
    _refreshButton = [SelectableButton buttonWithType:UIButtonTypeCustom];
    _refreshButton.frame=CGRectMake(10, 420, 50, 60) ;
    [_refreshButton setTitle:@"🔄" forState:UIControlStateNormal];
    [_refreshButton setBackgroundColor:[UIColor colorWithRed:51/255.0 green:201/255.0 blue:153/255.0 alpha:1]];
    [_refreshButton addTarget:self action:@selector(didTapRefesh) forControlEvents:UIControlEventTouchUpInside];
    
    return _refreshButton;
    
}

-(UIView *)crosshair
{
    if (_crosshair !=nil) {
        return _crosshair;
    }
    
    _crosshair = [[UIView alloc]init];
    _crosshair.bounds = CGRectMake(0, 0, 10, 10);
    _crosshair.center = self.view.center;
    _crosshair.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    return _crosshair;
}

-(UILabel *)distanceLabel
{
    if (_distanceLabel !=nil) {
        return _distanceLabel;
    }
    
    _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 360, 100, 20.5)];
    _distanceLabel.backgroundColor = [UIColor clearColor];
    _distanceLabel.font = [UIFont systemFontOfSize:10];
    return _distanceLabel;
}

-(UILabel *)messageLabel
{
    if (_messageLabel !=nil) {
        return _messageLabel;
    }
    
    _messageLabel = [[UILabel alloc]init];
    _messageLabel.bounds =CGRectMake(0, 0, 100, 20.5);
    _messageLabel.center = CGPointMake(self.view.center.x, 30);
    _messageLabel.font = [UIFont systemFontOfSize:10];
    _messageLabel.backgroundColor = [UIColor clearColor];
    return _messageLabel;
}

-(UILabel *)trackingInfoLabel
{
    if (_trackingInfoLabel !=nil) {
        return _trackingInfoLabel;
    }
    _trackingInfoLabel = [[UILabel alloc]init];
    _trackingInfoLabel.backgroundColor = [UIColor clearColor];
    _trackingInfoLabel.bounds =CGRectMake(0, 0, 100, 20.5);
    _trackingInfoLabel.center = CGPointMake(self.view.center.x, 619);
    _trackingInfoLabel.font = [UIFont systemFontOfSize:10];
    return _trackingInfoLabel;
}

@end
