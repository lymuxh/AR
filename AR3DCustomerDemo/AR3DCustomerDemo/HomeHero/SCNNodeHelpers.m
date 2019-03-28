//
//  SCNNodeHelpers.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/11/8.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "SCNNodeHelpers.h"

@implementation SCNNodeHelpers


+(SCNNode *)nodeWithModelName:(NSString *)modelName{
    
    SCNScene *scene = [SCNScene sceneNamed:modelName];
    if(scene){
        return [scene.rootNode clone];
    }
    return nil;
}


+(SCNNode *)createPlaneNode:(vector_float3)center Extent:(vector_float3)extent{
    
    SCNPlane *plane = [SCNPlane planeWithWidth:extent.x height:extent.z];
    SCNMaterial *planeMaterial =[SCNMaterial new];
    planeMaterial.diffuse.contents = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.4];
    plane.materials = @[planeMaterial];
    SCNNode* planeNode = [SCNNode nodeWithGeometry:plane];
    planeNode.position = SCNVector3Make(center.x, 0, center.z);
    planeNode.transform = SCNMatrix4MakeRotation(-M_PI / 2, 1, 0, 0);
    
    return planeNode;
}

+(void)updatePlaneNode:(SCNNode *)node Center:(vector_float3)center Extent:(vector_float3)extent{
    SCNPlane *geometry = (SCNPlane *) node.geometry;
    geometry.width = extent.x;
    geometry.height = extent.z;
}

+(void)removeChildren:(SCNNode *)node{
    for (SCNNode *n in node.childNodes) {
        [n removeFromParentNode];
    }
}

+(SCNNode *)createSphereNode:(CGFloat)radius{
    
    SCNSphere *sphere = [SCNSphere sphereWithRadius:radius];
    sphere.firstMaterial.diffuse.contents=[UIColor redColor];
    return [SCNNode nodeWithGeometry:sphere];
}

+(SCNNode *)createLineNode:(SCNNode *)fromNode to:(SCNNode *)toNode{
    
    SCNGeometry *geometry = [self lineFrom:fromNode.position to:toNode.position];
    SCNNode *lineNode = [SCNNode nodeWithGeometry:geometry];
    SCNMaterial *planMaterial = [SCNMaterial new];
    planMaterial.diffuse.contents =[UIColor redColor];
    geometry.materials =@[planMaterial];
    
    return lineNode;
}


+(SCNGeometry *)lineFrom:(SCNVector3)vector1 to:(SCNVector3)vector2{
    
    // baseGeometry
    SCNVector3 positions[] = {
        vector1,
        vector2
    };
    
    SCNGeometrySource * baseGeometrySource = [SCNGeometrySource geometrySourceWithVertices:positions count:2];
    
    typedef struct {
        uint16_t a;
    } Triangles;
    
    Triangles tVectors[2] = {
        0,1
    };
    
    NSData *triangleData = [NSData dataWithBytes:tVectors length:sizeof(tVectors)];
    
    SCNGeometryElement * baseGeometryElement = [SCNGeometryElement geometryElementWithData:triangleData primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:2 bytesPerIndex:sizeof(uint16_t)];
    
    SCNGeometry * baseGeometry = [SCNGeometry geometryWithSources:[NSArray arrayWithObject:baseGeometrySource] elements:[NSArray arrayWithObject:baseGeometryElement]];
    
    return baseGeometry;
}

@end
