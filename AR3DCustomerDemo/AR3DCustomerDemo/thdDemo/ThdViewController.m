//
//  ThdViewController.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/11/7.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "ThdViewController.h"

@interface ThdViewController ()<ARSCNViewDelegate>

//返回按钮
@property(nonatomic,strong)UIButton *backButton;

@property (nonatomic, strong) ARSCNView *sceneView;

@end

@implementation ThdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sceneView = [[ARSCNView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.sceneView];
    
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"3dart.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    
     [self.view insertSubview:self.backButton aboveSubview:self.sceneView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

/*
 // Override to create and configure nodes for anchors added to the view's session.
 - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
 SCNNode *node = [SCNNode new];
 
 // Add geometry to the node...
 
 return node;
 }
 */

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

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

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
