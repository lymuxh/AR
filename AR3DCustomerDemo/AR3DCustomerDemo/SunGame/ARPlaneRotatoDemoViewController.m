//
//  ARPlaneRotatoDemoViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/10/23.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "ARPlaneRotatoDemoViewController.h"
//3D游戏框架
#import <SceneKit/SceneKit.h>
//ARKit框架
#import <ARKit/ARKit.h>

@interface ARPlaneRotatoDemoViewController (){
    
    //3D模型(本小节加载多个模型)
    SCNNode *_moonNode;
    
    //3D模型(本小节加载多个模型)
    SCNNode *_moonRotationNode;
    
    //3D模型(本小节加载多个模型)
    SCNNode *_earthNode;
    
    //3D模型(本小节加载多个模型)
    SCNNode *_earthGroupNode;//地球和月球当做一个整体的节点 围绕太阳公转需要
    
    //3D模型(本小节加载多个模型)
    SCNNode *_sunNode;

    //3D模型(本小节加载多个模型)
    SCNNode *_sunHaloNode;//太阳光晕
    
}

//AR视图：展示3D界面
@property(nonatomic,strong)ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置：负责追踪相机的运动
@property(nonatomic,strong)ARConfiguration *arConfiguration;

//返回按钮
@property(nonatomic,strong)UIButton *backButton;

@end

@implementation ARPlaneRotatoDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    //1.将AR视图添加到当前视图
    [self.view addSubview:self.arSCNView];
    //添加返回按钮
    [self.view insertSubview:self.backButton aboveSubview:self.arSCNView];
    
    [self initNode];
    
    [self sunRotation];
    
    [self earthTurn];
    
    [self sunTurn];
    
    [self addLight];
    
   
    
    // add a tap gesture recognizer
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
    //2.开启AR会话（此时相机开始工作）
    [self.arSession runWithConfiguration:self.arConfiguration options:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // Pause the view's session
    [self.arSession pause];
}


-(void)initNode{
    
    //添加太阳、地球、月亮节点
    _moonNode = [SCNNode node];
    
    _moonRotationNode = [SCNNode node];//月球围绕地球转动的节点
    
    _earthNode =[SCNNode node];
    
    _earthGroupNode = [SCNNode node];//地球和月球当做一个整体的节点 围绕太阳公转需要
    
    _sunNode = [SCNNode node];
    
    _sunHaloNode = [SCNNode node];//太阳光晕
    
    //1.设置几何
    _sunNode.geometry = [SCNSphere sphereWithRadius:3];
    _earthNode.geometry =  [SCNSphere sphereWithRadius:1];
    _moonNode.geometry =  [SCNSphere sphereWithRadius:0.5];
    
    //2.渲染图
    // multiply： 把整张图拉伸，之后会变淡
    //diffuse:平均扩散到整个物体的表面，平切光泽透亮
    //   AMBIENT、DIFFUSE、SPECULAR属性。这三个属性与光源的三个对应属性类似，每一属性都由四个值组成。AMBIENT表示各种光线照射到该材质上，经过很多次反射后最终遗留在环境中的光线强度（颜色）。DIFFUSE表示光线照射到该材质上，经过漫反射后形成的光线强度（颜色）。SPECULAR表示光线照射到该材质上，经过镜面反射后形成的光线强度（颜色）。通常，AMBIENT和DIFFUSE都取相同的值，可以达到比较真实的效果。
    //        EMISSION属性。该属性由四个值组成，表示一种颜色。OpenGL认为该材质本身就微微的向外发射光线，以至于眼睛感觉到它有这样的颜色，但这光线又比较微弱，以至于不会影响到其它物体的颜色。
    //        SHININESS属性。该属性只有一个值，称为“镜面指数”，取值范围是0到128。该值越小，表示材质越粗糙，点光源发射的光线照射到上面，也可以产生较大的亮点。该值越大，表示材质越类似于镜面，光源照射到上面后，产生较小的亮点。
    
    _sunNode.geometry.firstMaterial.multiply.contents = @"earth.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"earth.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5; //強度
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    //  地球图
    
    _earthNode.geometry.firstMaterial.diffuse.contents = @"earth.scnassets/earth/earth-diffuse-mini.jpg";
    //  地球夜光图
    _earthNode.geometry.firstMaterial.emission.contents = @"earth.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"earth.scnassets/earth/earth-specular-mini.jpg";
    
    //月球圖
    _moonNode.geometry.firstMaterial.diffuse.contents = @"earth.scnassets/earth/moon.jpg";
    
    //3.设置位置
    
    _sunNode.position = SCNVector3Make(0, 5, -20);
    
    _earthGroupNode.position = SCNVector3Make(10,0,0);//地月节点距离太阳的10
    
    _earthNode.position = SCNVector3Make(3, 0, 0);
    
    _moonRotationNode.position = _earthNode.position; //设置月球围绕地球转动的节点位置与地球的位置相同
    
    _moonNode.position = SCNVector3Make(3, 0, 0);//月球距离月球围绕地球转动距离3
    
    //4.让rootnode为sun sun上添加earth earth添加moon
    
    [_moonRotationNode addChildNode:_moonNode];
    [_earthGroupNode addChildNode:_earthNode];
    [_earthGroupNode addChildNode:_moonRotationNode];
    
    [_sunNode addChildNode:_earthGroupNode];
    
    [self.arSCNView.scene.rootNode addChildNode:_sunNode];
    
}


//MARK：设置太阳自转
-(void) sunRotation {
    
    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
//    animation.duration = 10.0;
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
//    animation.repeatCount = FLT_MAX;
//    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
//
//    animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
//    animation.duration = 30.0;
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(5, 5, 5))];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
//    animation.repeatCount = FLT_MAX;
//    [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
    
    
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"rotation"];

    animation.duration = 10.0;//速度

    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];//围绕自己的y轴转动

    animation.repeatCount = FLT_MAX;

    [_sunNode addAnimation:animation forKey:@"sun-texture"];
    
}

//MARK:设置地球自转和月亮围绕地球转
/**
 月球如何围绕地球转呢
 可以把月球放到地球上，让地球自转月球就会跟着地球，但是月球的转动周期和地球的自转周期是不一样的，所以创建一个月球围绕地球节点（与地球节点位置相同），让月球放到地月节点上，让这个节点自转，设置转动速度即可
 */

-(void) earthTurn {
    
    //苹果有一套自带的动画
   [ _earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]] forKey:@"earth-texture"];//duration标识速度 数字越小数字速度越快
    
    //设置月球自转
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    
    animation.duration = 1.5;//速度
    
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];//围绕自己的y轴转动
    
    animation.repeatCount = FLT_MAX;
    
    [_moonNode addAnimation:animation forKey:@"moon-rotation"]; //月球自转
    
    //设置月球公转
    CABasicAnimation * moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    
    moonRotationAnimation.duration = 5;//速度
    
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];//围绕自己的y轴转动
    
    moonRotationAnimation.repeatCount = FLT_MAX;
    
    [_moonRotationNode  addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
    
    
}


//MARK：设置地球公转
-(void) sunTurn {
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    
    animation.duration = 10;//速度
    
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI* 2)];//围绕自己的y轴转动
    
    animation.repeatCount = FLT_MAX;
    
    [_earthGroupNode addAnimation:animation forKey:@"earth rotation around sun"];//月球自转
    
}


//MARK://设置太阳光晕和被光找到的地方
-(void)  addLight {
    
    SCNNode *lightNode = [SCNNode new];
    lightNode.light = [SCNLight new];
    lightNode.light.color = [UIColor redColor]; //被光找到的地方颜色
    
    [_sunNode addChildNode:lightNode];
    
    lightNode.light.attenuationEndDistance = 20.0; //光照的亮度随着距离改变
    lightNode.light.attenuationStartDistance = 1.0;
    
    [SCNTransaction begin];
    
    SCNTransaction.animationDuration = 1;
    
    lightNode.light.color =  [UIColor whiteColor];
    lightNode.opacity = 0.5; // make the halo stronger
    
    [SCNTransaction commit];
    
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:25 height:25];
    
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"earth.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = false; // 不要有厚度，看起来薄薄的一层
    _sunHaloNode.opacity = 5;
    
    [_sunHaloNode addChildNode:_sunHaloNode];
}

#pragma mark handleTap

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
    
    //2.设置视图会话
    _arSCNView.session = self.arSession;
    
    //3.自动刷新灯光（3D游戏用到，此处可忽略）
    _arSCNView.automaticallyUpdatesLighting = YES;
    
    // 4.显示统计信息
    _arSCNView.showsStatistics = YES;
    
    //5.允许相机控制
    _arSCNView.allowsCameraControl = YES;
    
    //6.调试信息
//    _arSCNView.debugOptions =
//    ARSCNDebugOptionShowWorldOrigin |
//    ARSCNDebugOptionShowFeaturePoints;
    
    return _arSCNView;
}


@end
