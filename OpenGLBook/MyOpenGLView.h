//
//  MyOpenGLView.h
//  OpenGLBook
//
//  Created by Christopher Richard Wojno on 2014/3/22.
//  Copyright (c) 2014 Christopher Richard Wojno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NSOpenGLContext, NSOpenGLPixelFormat;

@interface MyOpenGLView : NSView
{
    UInt frameCount;
    GLuint
    VertexShaderId,
    FragmentShaderId,
    ProgramId,
    VaoId,
    VboId,
    IndexBufferId;
    
    NSString* vertexShader;
    NSString* fragmentShader;
    
@private
    NSOpenGLContext* _openGLContext;
    NSOpenGLPixelFormat* _pixelFormat;
}
+ (NSOpenGLPixelFormat*)defaultPixelFormat;
- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat*)format;
- (void)setOpenGLContext:(NSOpenGLContext*)context;
- (NSOpenGLContext*)openGLContext;
- (void)clearGLContext;
- (void)prepareOpenGL;
- (void)update;
- (void)setPixelFormat:(NSOpenGLPixelFormat*)pixelFormat;
- (NSOpenGLPixelFormat*)pixelFormat;


@property (weak) NSTimer* frameCountTimer;

-(void)drawRect: (NSRect) bounds;

-(void)frameTimerCallback:(NSTimer*)theTimer;

-(void)cleanup;
-(void)createVBO;
-(void)destroyVBO;
-(void)createShaders;
-(void)destroyShaders;

-(void)drawScene;



@end
