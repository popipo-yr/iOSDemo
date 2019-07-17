//
//  WMOpenGL.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/12.
//  Copyright © 2019 py. All rights reserved.
//

#import "WMOpenGL.h"
#import <GLKit/GLKit.h>

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;


@implementation WMOpenGL{
    EAGLContext* _glContext;
    
    GLuint _bgImg_t_id;
    GLuint _textImg_t_id;
    GLuint _frameBuffer;
    GLuint _texture_render_id;
    
    CGSize _bgSize;
    
    SenceVertex *_vertices; // 顶点数组
}

-(instancetype)init
{
    if (self = [super init]) {
        [self setupGL];
    }
    
    return self;
}


- (void)dealloc {
    
    if ([EAGLContext currentContext] == _glContext) {
        [EAGLContext setCurrentContext:nil];
        glBindBuffer(GL_FRAMEBUFFER, 0);
    }
    
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_bgImg_t_id) {
        glDeleteTextures(1, &_bgImg_t_id);
        _bgImg_t_id = 0;
    }
    
    if (_textImg_t_id) {
        glDeleteTextures(1, &_textImg_t_id);
        _textImg_t_id = 0;
    }
    
    if (_texture_render_id) {
        glDeleteTextures(1, &_texture_render_id);
        _texture_render_id = 0;
    }
}

- (void) setupGL
{
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_glContext];
    
    // 创建顶点数组
    _vertices = malloc(sizeof(SenceVertex) * 4); // 4 个顶点
    
    _vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上角
    _vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下角
    _vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}}; // 右上角
    _vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}}; // 右下角
    
    // 帧缓存
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
}

-(void)setBgImage:(UIImage *)bgImage
{
    if (bgImage == _bgImage) {
        return;
    }
    
    _bgImage = bgImage;
    _bgSize = bgImage.size;
    
    if (_texture_render_id) {
        glDeleteTextures(1, &_texture_render_id);
    }
    
    glGenTextures(1, &_texture_render_id);
    glBindTexture(GL_TEXTURE_2D, _texture_render_id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _bgSize.width, _bgSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    //将纹理图像附加到帧缓冲对象
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture_render_id, 0);
}

- (UIImage*) resultImage
{
    if (_bgImg_t_id) {
        glDeleteTextures(1, &_bgImg_t_id);
    }
    
    if (_textImg_t_id) {
        glDeleteTextures(1, &_textImg_t_id);
    }

    // 创建纹理
    _bgImg_t_id = [self createTextureWithImage:self.bgImage];
    _textImg_t_id = [self createTextureWithImage:self.textImage];

    // 设置视口尺寸
    glViewport(0, 0, _bgSize.width, _bgSize.height);
    
    // 编译链接 shader
    GLuint program = [self programWithShaderName:@"glsl"]; // glsl.vsh & glsl.fsh
    glUseProgram(program);
    
    // 获取 shader 中的参数，然后传数据进去
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    GLuint bgTextureSlot = glGetUniformLocation(program, "bg_t");
    GLuint textTextureSlot = glGetUniformLocation(program, "text_t");
    GLuint textRangeSlot = glGetUniformLocation(program, "textRange");
    GLuint bgSizeSlot = glGetUniformLocation(program, "bgSize");

    
    // 将纹理 ID 传给着色器程序
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _bgImg_t_id);
    glUniform1i(bgTextureSlot, 0);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _textImg_t_id);
    glUniform1i(textTextureSlot, 1);
    
    
    GLfloat rect_p[] = {_textRect.origin.x, _textRect.origin.y, _textRect.size.width, _textRect.size.height};
    glUniform4fv(textRangeSlot, 1, rect_p);
    
    GLenum er = glGetError();
    
    glUniform2f(bgSizeSlot, _bgSize.width, _bgSize.height);

    er = glGetError();
    
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, _vertices, GL_STATIC_DRAW);
    
    // 设置顶点数据
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    // 设置纹理数据
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    // 开始绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    UIImage* image =
    [self imageFromPixelWithWidth:_bgSize.width
                           height:_bgSize.height];
    
    // 删除顶点缓存
    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
    
    return image;
}

- (UIImage*) imageFromPixelWithWidth:(CGFloat)width
                              height:(CGFloat)height
{
    NSInteger dataLength = width * height * 4;
    GLubyte *data = malloc(dataLength * sizeof(GLubyte));
 
    glReadPixels(0, 0, width, height,
                 GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    //创建图片
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef dataRef =
    CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGImageRef imgRef =
    CGImageCreate(width, height, 8, 32, width * 4, colorspace,
                  kCGBitmapByteOrder32Big | kCGImageAlphaNone,
                  dataRef, NULL, true, kCGRenderingIntentDefault);

    // 此时的 imageRef 是上下颠倒的，调用 CG 的方法重新绘制一遍，刚好翻转过来
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef contexRef = UIGraphicsGetCurrentContext();
    CGContextDrawImage(contexRef, CGRectMake(0, 0, width, height), imgRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (data) {
        free(data);
        data = NULL;
    }

    return image;
}

// 通过一张图片来创建纹理
- (GLuint)createTextureWithImage:(UIImage *)image {
    // 将 UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 绘制图片
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    // 生成纹理
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData); // 将图片数据写入纹理缓存
    
    // 设置如何把纹素映射成像素
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 解绑
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 释放内存
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

// 将一个顶点着色器和一个片段着色器挂载到一个着色器程序上，并返回程序的 id
- (GLuint)programWithShaderName:(NSString *)shaderName {
    // 编译两个着色器
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    // 挂载 shader 到 program 上
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 链接 program
    glLinkProgram(program);
    
    // 检查链接是否成功
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program链接失败：%@", messageString);
        exit(1);
    }
    return program;
}

// 编译一个 shader，并返回 shader 的 id
- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    // 查找 shader 文件
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"]; // 根据不同的类型确定后缀名
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    // 创建一个 shader 对象
    GLuint shader = glCreateShader(shaderType);
    
    // 获取 shader 的内容
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)strlen(shaderStringUTF8);
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 编译shader
    glCompileShader(shader);
    
    // 查询 shader 是否编译成功
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    
    return shader;
}

@end
