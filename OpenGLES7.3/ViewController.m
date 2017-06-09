//
//  ViewController.m
//  OpenGLES7.3
//
//  Created by ShiWen on 2017/6/8.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"
#import "AGLKContext.h"
@interface ViewController ()
@property (nonatomic,strong)UtilityModelManager *modelManager;
@property (nonatomic,strong)UtilityArmatureBaseEffect *mBaseEffect;
@property (nonatomic,strong) UtilityModel *modelBone0;
@property (nonatomic,strong) UtilityModel *modelBone1;
@property (nonatomic,strong) UtilityModel *modelBone2;
//@property (nonatomic,assign) float

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glView = (GLKView *)self.view;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glView.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:glView.context];
    
    [((AGLKContext *)glView.context) enable:GL_DEPTH_TEST];
    self.mBaseEffect = [[UtilityArmatureBaseEffect alloc] init];
    self.mBaseEffect.light0.enabled = GL_TRUE;
    self.mBaseEffect.light0.ambientColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);
    self.mBaseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.mBaseEffect.light0Position = GLKVector4Make(1.0, 0.8, .04, 0.0);
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelPath];
    self.modelBone0 = [self.modelManager modelNamed:@"bone0"];
    [self.modelBone0 assignJoint:0];
    self.modelBone1 = [self.modelManager modelNamed:@"bone1"];
    [self.modelBone1 assignJoint:1];
    self.modelBone2 = [self.modelManager modelNamed:@"bone2"];
    [self.modelBone2 assignJoint:2];
    //    创建关节点
    UtilityJoint *bone0Joint = [[UtilityJoint alloc]initWithDisplacement:GLKVector3Make(0, 0, 0) parent:nil];
    //    计算模型0的长度
    float bone0Lenth = self.modelBone0.axisAlignedBoundingBox.max.y - self.modelBone0.axisAlignedBoundingBox.min.y;
    UtilityJoint *bone1Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone0Lenth, 0) parent:bone0Joint];
    float bone1Lenth = self.modelBone1.axisAlignedBoundingBox.max.y - self.modelBone1.axisAlignedBoundingBox.min.y;
    UtilityJoint *bone2Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone1Lenth, 0) parent:bone1Joint];
    self.mBaseEffect.jointsArray = @[bone0Joint,bone1Joint,bone2Joint];
    self.mBaseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(5.0, 10.0, 15.0, 0.0, 2.0, 0.0, 0.0, 1.0, 0.0);
    
    
    
    
}
- (IBAction)valueChange:(UISlider *)sender {
    
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(sender.value * M_PI * 0.5, 0, 0, 1);
//    通过Tag即可获取里面的modelUtility
    [(UtilityJoint *)[self.mBaseEffect.jointsArray objectAtIndex:sender.tag]
     setMatrix:rotateZMatrix];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [(AGLKContext *)view.context enable:GL_CULL_FACE];
    const GLfloat ratio = (GLfloat)view.drawableWidth/(GLfloat)view.drawableHeight;
    self.mBaseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0), ratio, 4.0f, 20.0f);
    [self.modelManager prepareToDrawWithJointInfluence];
    [self.mBaseEffect prepareToDrawArmature];
    [self.modelBone0 draw];
    [self.modelBone1 draw];
    [self.modelBone2 draw];

}


@end
