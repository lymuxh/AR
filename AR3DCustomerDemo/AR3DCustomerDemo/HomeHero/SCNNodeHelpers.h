//
//  SCNNodeHelpers.h
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/11/8.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import <Foundation/Foundation.h>
//3D游戏框架
#import <SceneKit/SceneKit.h>
//ARKit框架
#import <ARKit/ARKit.h>

@interface SCNNodeHelpers : NSObject

+(SCNNode *)nodeWithModelName:(NSString *)modelName;

+(SCNNode *)createPlaneNode:(vector_float3)center Extent:(vector_float3)extent;

+(void)updatePlaneNode:(SCNNode *)node Center:(vector_float3)center Extent:(vector_float3)extent;

+(void)removeChildren:(SCNNode *)node;

+(SCNNode *)createSphereNode:(CGFloat)radius;

+(SCNNode *)createLineNode:(SCNNode *)fromNode to:(SCNNode *)toNode;

+(SCNGeometry *)lineFrom:(SCNVector3)vector1 to:(SCNVector3)vector2;


@end
