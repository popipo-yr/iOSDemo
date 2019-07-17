//
//  WaterMarkPro.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/9.
//  Copyright © 2019 py. All rights reserved.
//

#import "WaterMarkPro.h"
#import <CoreText/CoreText.h>

@implementation WaterMarkPro

+ (UIImage *)py_ProWaterMarkWithInfo:(WaterMarkInfo*)info
{
    CGRect drawRect = [info drawTextRect];
    CGFloat fontSize = [info autoFontSize];
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    
    NSArray* points = [self drawPointsAboutStr:info.text
                                          rect:drawRect
                                          font:font];
    
    return nil;
}


+ (NSArray *) drawPointsAboutStr:(NSString *)str
                            rect:(CGRect)rect
                            font:(UIFont*)font{
    
    NSMutableArray* retPoints = NSMutableArray.new;
    
    NSAttributedString *attrStr =
    [[NSAttributedString alloc]
     initWithString:str
     attributes:@{NSFontAttributeName: font}];
    
    CTFramesetterRef frameSetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    
    //创建可变path
    CGMutablePathRef mutPath = CGPathCreateMutable();
    CGPathAddRect(mutPath, NULL, rect);
    
    //遍历数据，获取frame
    CTFrameRef frame =
    CTFramesetterCreateFrame(frameSetter,
                             CFRangeMake(0, str.length), mutPath, NULL);
    //获取行信息
    CFArrayRef lineRefs =
    CTFrameGetLines(frame);
    
    for (CFIndex lineIndex = 0; lineIndex < CFArrayGetCount(lineRefs); lineIndex++)
    {
        CTLineRef aLineRef = (CTLineRef)CFArrayGetValueAtIndex(lineRefs, lineIndex);
        //获取Run信息
        CFArrayRef runRefs = CTLineGetGlyphRuns(aLineRef);
        
        for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runRefs); runIndex++)
        {
            CTRunRef aRunRef =
            (CTRunRef)CFArrayGetValueAtIndex(runRefs, runIndex);
            
            NSArray* points = [self pointsInRunRef:aRunRef];
            [retPoints addObjectsFromArray:points];
        }
        
    }
    //    UIBezierPath *path = [UIBezierPath bezierPath];
    //    [path moveToPoint:CGPointZero];
    //    [path appendPath:[UIBezierPath bezierPathWithCGPath:mutPath]];
    CGPathRelease(mutPath);
    //    CFRelease(font);
    return retPoints;
}


+ (NSArray*) pointsInRunRef:(CTRunRef)aRunRef
{
    NSMutableArray* retPoints = NSMutableArray.new;
    
    CTFontRef fontRef = CFDictionaryGetValue(CTRunGetAttributes(aRunRef),
                                             kCTFontAttributeName);
    
    //获取Glyph信息
    for (CFIndex glyphIndex = 0; glyphIndex < CTRunGetGlyphCount(aRunRef); glyphIndex++)
    {
        CFRange glyphRange = CFRangeMake(glyphIndex, 1);
        
        CGGlyph glyph;
        CGPoint position;
        
        CTRunGetGlyphs(aRunRef, glyphRange, &glyph);
        CTRunGetPositions(aRunRef, glyphRange, &position);
        
        //获取Path 然后获取点信息
        CGPathRef pathRef = CTFontCreatePathForGlyph(fontRef, glyph, NULL);
        //        CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
        //
        //        CGPathAddPath(mutPath, &t, pathRef);
        NSArray* points = [self pointsInPathRef:pathRef];
        [retPoints addObjectsFromArray:points];
        
        CGPathRelease(pathRef);
    }
    
    return retPoints;
}

+ (NSArray*) pointsInPathRef:(CGPathRef)aPathRef
{
    NSMutableArray* retPoints = NSMutableArray.new;
    
    CGPathApply(aPathRef, (__bridge void * _Nullable)(retPoints), CGPathApplier);
    
    return retPoints;
}



void CGPathApplier(void * __nullable info,
                   const CGPathElement *  element){
    
    NSMutableArray* retPoints = (__bridge NSMutableArray *)(info);
    
    //获取最后一个控制点
    CGPoint lastPoint = CGPointZero;
    
    NSValue* lastV = retPoints.lastObject;
    if (nil != lastV) {
        lastPoint = [lastV CGPointValue];
    }
    
    switch (element->type) {
        case kCGPathElementMoveToPoint: {
            CGPoint point = element->points[0];
            [retPoints addObject:[NSValue valueWithCGPoint:point]];
            break;
        }
        case kCGPathElementAddLineToPoint: {
            
            CGPoint startP = lastPoint;
            CGPoint endP =  element->points[0];
            
            if (CGPointEqualToPoint(startP, endP)) {
                break;
            }
            
            CGFloat vector = endP.y > startP.y ? 1 : -1; //方向
            CGFloat y = startP.y;
            
            if (startP.x == endP.x) { //Y轴方向同轴，只做Y的递增处理
                
                do {
                    y = y + vector;
                    
                    CGPoint point = CGPointMake(startP.x, y);
                    [retPoints addObject:[NSValue valueWithCGPoint:point]];
                } while ((vector > 0 && y < endP.y) ||
                         (vector < 0 && y > endP.y));
            }else{ //通过斜率计算
                
                CGFloat slope = (endP.y - startP.y) / (endP.x - startP.x);
                
                do {
                    y = y + vector;
                    CGFloat x = (y - startP.y) / slope + startP.x;
                    
                    CGPoint point = CGPointMake(x, y);
                    [retPoints addObject:[NSValue valueWithCGPoint:point]];
                } while ((vector > 0 && y < endP.y) ||
                         (vector < 0 && y > endP.y));
            }
            
            break;
        }
        case kCGPathElementAddQuadCurveToPoint: {
            
            CGPoint startP = lastPoint;
            CGPoint endP = element->points[0];
            CGPoint ctrlP = element->points[1];
            
            if (CGPointEqualToPoint(startP, endP)) {
                break;
            }
            
            if (startP.y == endP.y) { //X轴方向同轴，只做X的递增处理
                
                CGFloat vector = endP.x > startP.x ? 1 : -1; //方向
                CGFloat x = startP.x;
                
                do {
                    x = x + vector;
                    CGFloat y = getYFromBezierPath(x, startP, ctrlP, endP);
                    
                    CGPoint point = CGPointMake(x, y);
                    [retPoints addObject:[NSValue valueWithCGPoint:point]];
                } while ((vector > 0 && x < endP.x) ||
                         (vector < 0 && x > endP.x));
            }else{ //
                
                CGFloat vector = endP.y > startP.y ? 1 : -1; //方向
                CGFloat y = startP.y;
                
                do {
                    y = y + vector;
                    CGFloat x = getYFromBezierPath(y, startP, ctrlP, endP);
                    
                    CGPoint point = CGPointMake(x, y);
                    [retPoints addObject:[NSValue valueWithCGPoint:point]];
                    
                } while ((vector > 0 && y < endP.y) ||
                         (vector < 0 && y > endP.y));
                
            }
            
            break;
        }
        case kCGPathElementAddCurveToPoint: {
            
            CGPoint startP = lastPoint;
            CGPoint endP = element->points[0];
            CGPoint ctrP_1 = element->points[1];
            CGPoint ctrP_2 = element->points[2];
            
            if (CGPointEqualToPoint(startP, endP)) {
                break;
            }
            
            if (startP.y == endP.y) { //X轴方向同轴，只做X的递增处理
                
                CGFloat vector = endP.x > startP.x ? 1 : -1; //方向
                CGFloat x = startP.x;
                
                do {
                    x = x + vector;
                    CGFloat y = getTvalFromThrBezierPath(x, startP.x, ctrP_1.x, ctrP_2.x, endP.x);
                    
                    CGPoint point = CGPointMake(x, y);
                    [retPoints addObject:[NSValue valueWithCGPoint:point]];
                } while ((vector > 0 && x < endP.x) ||
                         (vector < 0 && x > endP.x));
            }else{ //
                
                CGFloat vector = endP.y > startP.y ? 1 : -1; //方向
                CGFloat y = startP.y;
                
                do {
                    y = y + vector;
                    CGFloat x = getTvalFromThrBezierPath(y, startP.y, ctrP_1.y, ctrP_2.y, endP.y);
                    
                    CGPoint point = CGPointMake(x, y);
                    [retPoints addObject:[NSValue valueWithCGPoint:point]];
                    
                } while ((vector > 0 && y < endP.y) ||
                         (vector < 0 && y > endP.y));
            }
            
            break;
        }
            
        case kCGPathElementCloseSubpath: {
            break;
        }
            
    }
}

/* https://stackoverflow.com/questions/26857850/get-points-from-a-uibezierpath/26858983
 Given the equation
 
 X = (1-t)^2*X0 + 2*t*(1-t)*X1 + t^2 *X2
 I solve for t
 
 t = ((2.0 * x0 - x1) + sqrt(((-2.0 * x0 + x1) ** 2.0)
 - ((4 * (x0 - 2.0 * x1 + x2)) * (x0 - x)))) / (2.0 * (x0 - 2.0 * x1 + x2))
 or
 
 t = ((2.0 * x0 - x1) - sqrt(((-2.0 * x0 + x1) ** 2.0)
 - ((4 * (x0 - 2.0 * x1 + x2)) * (x0 - x)))) / (2.0 * (x0 - 2.0 * x1 + x2))
 Using this value, find Y that corresponds to X (we used X to find the above t value)
 
 Y = (1-t)^2*Y0 + 2*t*(1-t)*Y1 + t^2 *Y2
 */

//两阶
float getYFromBezierPath(float x, CGPoint startP,
                         CGPoint ctrlP, CGPoint endp){
    
    float y;
    float t;
    
    t = getTvalFromBezierPath(x, startP.x, ctrlP.x, endp.x);
    y = getCoordFromBezierPath(t, startP.y, ctrlP.y, endp.y);
    return y;
}

// x0 start point x, x1 control point x, x2 end point x
float getTvalFromBezierPath(float x, float x0, float x1, float x2){
    float t = (x - x0) / (2 * (x1 - x0));
    return t;
}

//y0 start point y, y1 control point y, y2 end point y
float getCoordFromBezierPath(float t, float y0, float y1, float y2){
    return (pow((1 - t), 2) * y0) + (2 * t * (1 - t) * y1) + (pow(t, 2) * y2);
}

//三阶
CGFloat bezierInterpolation(CGFloat t, CGFloat a, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat t2 = t * t;
    CGFloat t3 = t2 * t;
    return a + (-a * 3 + t * (3 * a - a * t)) * t
    + (3 * b + t * (-6 * b + b * 3 * t)) * t
    + (c * 3 - c * 3 * t) * t2
    + d * t3;
}

float f(float a,float b,float c,float d,float x)
{
    float f;
    f=((a*x+b)*x+c)*x+d;
    return f;
}
float f1(float a,float b,float c,float x)
{
    float f;
    f=(x*3*a+2*b)*x+c;
    return f;
}
float root_V(float a,float b,float c,float d)
{
    float x0,x1=1;
    do
    {
        x0=x1;
        x1=x0-f(a,b,c,d,x0)/f1(a,b,c,x0);
    }while(fabs(x1-x0)>=1e-6);
    return x0;
}


float getTvalFromThrBezierPath(float val, float a, float b, float c, float d){
    
    CGFloat C1 = ( d - (3.0 * c) + (3.0 * b) - a );
    CGFloat C2 = ( (3.0 * c) - (6.0 * b) + (3.0 * a) );
    CGFloat C3 = ( (3.0 * b) - (3.0 * a) );
    CGFloat C4 = ( a );
    
    //C1*t*t*t + C2*t*t + C3*t + (C4 - val) = 0;
    
    return root_V(C1, C2, C3, C4 - val);
}


//
//- (UIColor *) getPixelColorAtLocation:(CGPoint)point {
//    UIColor* color = nil;
//    CGImageRef inImage = self.image.CGImage;
//    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
//    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
//    if (cgctx == NULL) {
//        return nil; /* error */
//    }
//
//    size_t w = CGImageGetWidth(inImage);
//    size_t h = CGImageGetHeight(inImage);
//    CGRect rect = {{0,0},{w,h}};
//
//    // Draw the image to the bitmap context. Once we draw, the memory
//    // allocated for the context for rendering will then contain the
//    // raw image data in the specified color space.
//    CGContextDrawImage(cgctx, rect, inImage);
//
//    // Now we can get a pointer to the image data associated with the bitmap
//    // context.
//    unsigned char* data = CGBitmapContextGetData (cgctx);
//    if (data != NULL) {
//        //offset locates the pixel in the data from x,y.
//        //4 for 4 bytes of data per pixel, w is width of one row of data.
//        int offset = 4*((w*round(point.y))+round(point.x));
//        int alpha =  data[offset];
//        int red = data[offset+1];
//        int green = data[offset+2];
//        int blue = data[offset+3];
//        //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
//        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
//
//    }
//
//    // When finished, release the context
//    CGContextRelease(cgctx);
//    // Free image data memory for the context
//    if (data) { free(data); }
//    return color;
//}
//
//- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
//
//    CGContextRef    context = NULL;
//    CGColorSpaceRef colorSpace;
//    void *          bitmapData;
//    int             bitmapByteCount;
//    int             bitmapBytesPerRow;
//
//    // Get image width, height. We'll use the entire image.
//    size_t pixelsWide = CGImageGetWidth(inImage);
//    size_t pixelsHigh = CGImageGetHeight(inImage);
//
//    // Declare the number of bytes per row. Each pixel in the bitmap in this
//    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
//    // alpha.
//    bitmapBytesPerRow   = (pixelsWide * 4);
//    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
//
//    // Use the generic RGB color space.
//    colorSpace = CGColorSpaceCreateDeviceRGB();
//
//    if (colorSpace == NULL)
//    {
//        fprintf(stderr, "Error allocating color space\n");
//        return NULL;
//    }
//
//    // Allocate memory for image data. This is the destination in memory
//    // where any drawing to the bitmap context will be rendered.
//    bitmapData = malloc( bitmapByteCount );
//    if (bitmapData == NULL)
//    {
//        fprintf (stderr, "Memory not allocated!");
//        CGColorSpaceRelease( colorSpace );
//        return NULL;
//    }
//
//    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
//    // per component. Regardless of what the source image format is
//    // (CMYK, Grayscale, and so on) it will be converted over to the format
//    // specified here by CGBitmapContextCreate.
//    context = CGBitmapContextCreate (bitmapData,
//                                     pixelsWide,
//                                     pixelsHigh,
//                                     8,      // bits per component
//                                     bitmapBytesPerRow,
//                                     colorSpace,
//                                     kCGImageAlphaPremultipliedFirst);
//    if (context == NULL)
//    {
//        free (bitmapData);
//        fprintf (stderr, "Context not created!");
//    }
//    
//    // Make sure and release colorspace before returning
//    CGColorSpaceRelease( colorSpace );
//
//    return context;
//}

@end

