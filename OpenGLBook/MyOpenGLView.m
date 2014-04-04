//
//  MyOpenGLView.m
//  OpenGLBook
//
//  Created by Christopher Richard Wojno on 2014/3/22.
//  Copyright (c) 2014 Christopher Richard Wojno. All rights reserved.
//

#import "MyOpenGLView.h"
#import "Vertex.h"

@implementation MyOpenGLView

@synthesize frameCountTimer;

- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format
{
    self = [super initWithFrame:frameRect];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_surfaceNeedsUpdate:)
                                                     name:NSViewGlobalFrameDidChangeNotification
                                                   object:self];
        
        frameCount = 0;
        frameCountTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(frameTimerCallback:) userInfo:self repeats:true];
        
        vertexShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vertexShader" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
        fragmentShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fragmentShader" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
        
        
        // Create pixel format
        _pixelFormat = format;
        
        // Create OpenGL context
        _openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:NULL];
        [_openGLContext setView:self];
        [_openGLContext makeCurrentContext];
        
        
        
        
        
    }
    return self;
}


- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_surfaceNeedsUpdate:)
                                                     name:NSViewGlobalFrameDidChangeNotification
                                                   object:self];
        
        frameCount = 0;
        frameCountTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(frameTimerCallback:) userInfo:self repeats:true];
        
        vertexShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vertexShader" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
        fragmentShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fragmentShader" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
        
        
        // Create pixel format
        _pixelFormat = [MyOpenGLView defaultPixelFormat];
        
        // Create OpenGL context
        _openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:NULL];
        [_openGLContext setView:self];
        [_openGLContext makeCurrentContext];
        
        
        
        
        
    }
    return self;
}


- (void) _surfaceNeedsUpdate:(NSNotification*)notification
{
    [self update];
}


+ (NSOpenGLPixelFormat*)defaultPixelFormat {
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core, // Ensure we're using 3.2 or 4.0
        0
    };
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}


- (void)setOpenGLContext:(NSOpenGLContext*)context {
    _openGLContext = context;
}
- (NSOpenGLContext*)openGLContext{
    return _openGLContext;
}
- (void)clearGLContext
{
    [[self openGLContext] clearDrawable];
}

- (void)lockFocus
{
    NSOpenGLContext* context = [self openGLContext];
    [super lockFocus];
    if ([context view] != self) {
        [context setView:self];
    }
    [context makeCurrentContext];
}

- (void)prepareOpenGL {
    // OpenGL must already be initialized
    [self createVBO];
    [self createShaders];
}

- (void)update {
    [[self openGLContext] update];
}

-(void)drawScene{
    [[self openGLContext] update];
    glClearColor(0,0,0,0);
    
    ++frameCount;
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawElements(GL_TRIANGLES, 48, GL_UNSIGNED_BYTE, (GLvoid*)0);

    
    
    // Apply camera rotations
    glFlush();
}

- (void)setPixelFormat:(NSOpenGLPixelFormat*)pixelFormat {
    _pixelFormat = pixelFormat;
}
- (NSOpenGLPixelFormat*)pixelFormat {
    return _pixelFormat;
}

-(void) viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window] == nil)
        [_openGLContext clearDrawable];
}


- (void)drawRect:(NSRect)dirtyRect
{
    [[self openGLContext] makeCurrentContext];
    [self drawScene];
    [[self openGLContext] flushBuffer];
}
- (BOOL)acceptsFirstResponder {
    return YES;
}


-(void)frameTimerCallback:(NSTimer*)theTimer {
    [self.window setTitle:
     [NSString stringWithFormat:@"OpenGLBook Chapter 3 %d fps @ %d x %d",
      frameCount*4,
      (int)self.window.frame.size.width,
      (int)self.window.frame.size.height
    ]
    ];
     frameCount = 0;
}


-(void)cleanup {
    [self.frameCountTimer invalidate]; // stop the timer
    [self destroyShaders];
    [self destroyVBO];
}

-(void)createVBO {
    Vertex Vertices[] =
    {
        { { 0.0f, 0.0f, 0.0f, 1.0f }, { 1.0f, 1.0f, 1.0f, 1.0f } },
        // Top
        { { -0.2f, 0.8f, 0.0f, 1.0f }, { 0.0f, 1.0f, 0.0f, 1.0f } },
        { { 0.2f, 0.8f, 0.0f, 1.0f }, { 0.0f, 0.0f, 1.0f, 1.0f } },
        { { 0.0f, 0.8f, 0.0f, 1.0f }, { 0.0f, 1.0f, 1.0f, 1.0f } },
        { { 0.0f, 1.0f, 0.0f, 1.0f }, { 1.0f, 0.0f, 0.0f, 1.0f } },
        // Bottom
        { { -0.2f, -0.8f, 0.0f, 1.0f }, { 0.0f, 0.0f, 1.0f, 1.0f } },
        { { 0.2f, -0.8f, 0.0f, 1.0f }, { 0.0f, 1.0f, 0.0f, 1.0f } },
        { { 0.0f, -0.8f, 0.0f, 1.0f }, { 0.0f, 1.0f, 1.0f, 1.0f } },
        { { 0.0f, -1.0f, 0.0f, 1.0f }, { 1.0f, 0.0f, 0.0f, 1.0f } },
        // Left
        { { -0.8f, -0.2f, 0.0f, 1.0f }, { 0.0f, 1.0f, 0.0f, 1.0f } },
        { { -0.8f, 0.2f, 0.0f, 1.0f }, { 0.0f, 0.0f, 1.0f, 1.0f } },
        { { -0.8f, 0.0f, 0.0f, 1.0f }, { 0.0f, 1.0f, 1.0f, 1.0f } },
        { { -1.0f, 0.0f, 0.0f, 1.0f }, { 1.0f, 0.0f, 0.0f, 1.0f } },
        // Right
        { { 0.8f, -0.2f, 0.0f, 1.0f }, { 0.0f, 0.0f, 1.0f, 1.0f } },
        { { 0.8f, 0.2f, 0.0f, 1.0f }, { 0.0f, 1.0f, 0.0f, 1.0f } },
        { { 0.8f, 0.0f, 0.0f, 1.0f }, { 0.0f, 1.0f, 1.0f, 1.0f } },
        { { 1.0f, 0.0f, 0.0f, 1.0f }, { 1.0f, 0.0f, 0.0f, 1.0f } }
    };
    
    GLubyte Indices[] = {
        // Top
        0, 1, 3,
        0, 3, 2,
        3, 1, 4,
        3, 4, 2,
        // Bottom
        0, 5, 7,
        0, 7, 6,
        7, 5, 8,
        7, 8, 6,
        // Left
        0, 9, 11,
        0, 11, 10,
        11, 9, 12,
        11, 12, 10,
        // Right
        0, 13, 15,
        0, 15, 14,
        15, 13, 16,
        15, 16, 14
    };


    
    GLenum ErrorCheckValue = glGetError();
    const size_t BufferSize = sizeof(Vertices);
    const size_t VertexSize = sizeof(Vertices[0]);
    const size_t RgbOffset = sizeof(Vertices[0].XYZW);
    
    glGenBuffers(1, &VboId);
    
    glGenVertexArrays(1, &VaoId);
    glBindVertexArray(VaoId);
    
    glBindBuffer(GL_ARRAY_BUFFER, VboId);
    glBufferData(GL_ARRAY_BUFFER, BufferSize, Vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, VertexSize, 0);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, VertexSize, (GLvoid*)RgbOffset);
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    glGenBuffers(1, &IndexBufferId);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndexBufferId);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);

    
    ErrorCheckValue = glGetError();
    if (ErrorCheckValue != GL_NO_ERROR)
    {
        [NSAlert alertWithMessageText:[NSString stringWithFormat:@"ERROR: Count not create a VBO: %d ", ErrorCheckValue] defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"Nothing else here..."];
    }
}
-(void)destroyVBO {
    GLenum ErrorCheckValue = glGetError();
    
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDeleteBuffers(1, &VboId);

    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glDeleteBuffers(1, &IndexBufferId);

    
    glBindVertexArray(0);
    glDeleteVertexArrays(1, &VaoId);
    
    ErrorCheckValue = glGetError();
    if (ErrorCheckValue != GL_NO_ERROR)
    {
        [NSAlert alertWithMessageText:[NSString stringWithFormat:@"ERROR: Count not destroy a VBO: %d ", ErrorCheckValue] defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"Nothing else here..."];
    }

}
-(void)createShaders {
    GLenum ErrorCheckValue = glGetError();
    
    VertexShaderId = glCreateShader(GL_VERTEX_SHADER);
    GLboolean support;
    glGetBooleanv(GL_SHADER_COMPILER,&support);
    
    const char *tmp1 = [vertexShader UTF8String];
    glShaderSource(VertexShaderId, 1, &tmp1, NULL);
    glCompileShader(VertexShaderId);
    
    FragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
    const char *tmp2 = [fragmentShader UTF8String];
    glShaderSource(FragmentShaderId, 1, &tmp2, NULL);
    glCompileShader(FragmentShaderId);
    
    ProgramId = glCreateProgram();
    glAttachShader(ProgramId, VertexShaderId);
    glAttachShader(ProgramId, FragmentShaderId);
    glLinkProgram(ProgramId);
    glUseProgram(ProgramId);
    
    ErrorCheckValue = glGetError();
    if (ErrorCheckValue != GL_NO_ERROR)
    {
        [NSAlert alertWithMessageText:[NSString stringWithFormat:@"ERROR: Count not create a Shader: %d ", ErrorCheckValue] defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"Nothing else here..."];
    }

}
-(void)destroyShaders {
    
    GLenum ErrorCheckValue = glGetError();
    
    glUseProgram(0);
    
    glDetachShader(ProgramId, VertexShaderId);
    glDetachShader(ProgramId, FragmentShaderId);
    
    glDeleteShader(FragmentShaderId);
    glDeleteShader(VertexShaderId);
    
    glDeleteProgram(ProgramId);
    
    ErrorCheckValue = glGetError();
    if (ErrorCheckValue != GL_NO_ERROR)
    {
        [NSAlert alertWithMessageText:[NSString stringWithFormat:@"ERROR: Count not destroy a Shader: %d ", ErrorCheckValue] defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"Nothing else here..."];
    }

}

@end
