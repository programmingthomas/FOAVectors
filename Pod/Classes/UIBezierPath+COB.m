// UIBezierPath+COB.m
//
// Copyright 2014 Programming Thomas
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "UIBezierPath+COB.h"

CGPathRef COBCGPathFromSVG(NSString * svg, CGAffineTransform * transform) {
    if ([svg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NULL;
    }
    NSScanner * scanner = [NSScanner scannerWithString:svg];
    scanner.caseSensitive = YES;
    scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@", "];
    NSCharacterSet * closePathCharacters = [NSCharacterSet characterSetWithCharactersInString:@"Zz"];
    
    //I think these need to be set as 0 by default
    __block double lastX = 0, lastY = 0;
    __block double lastControlX = 0, lastControlY = 0;
    
    __block CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint (^Last)() = ^CGPoint() {
        return CGPointMake(lastX, lastY);
    };
    
    void (^LineToLast)() = ^{
        CGPathAddLineToPoint(path, transform, lastX, lastY);
    };
    
    void (^QuadraticCurveTo)(double, double, double, double) = ^(double controlX, double controlY, double endX, double endY) {
        //We then must use the calculations described on http://support.microsoft.com/kb/q243285 to calculate the TWO control points for the bezier curve based off of the single control point for the cubic curve
        
        //Cubic Control Point 1 in terms of Quadratic controlX/controlY
        double qControl1X = lastX + 2 * (controlX - lastX) / 3;
        double qControl1Y = lastY + 2 * (controlY - lastY) / 3;
        
        //Cubic Control Point 2 in terms of Quadratic controlX/controlY and end point
        double qControl2X = controlX + 1 * (endX - controlX) / 3;
        double qControl2Y = controlY + 1 * (endY - controlY) / 3;
        
        CGPoint endPoint = CGPointMake(endX, endY);
        CGPoint control1 = CGPointMake(qControl1X, qControl1Y);
        CGPoint control2 = CGPointMake(qControl2X, qControl2Y);
        
        CGPathAddCurveToPoint(path, transform, control1.x, control1.y, control2.x, control2.y, endPoint.x, endPoint.y);
    };
    
    while (![scanner isAtEnd]) {
        BOOL absoluteMoveTo = [scanner scanString:@"M" intoString:NULL];
        BOOL relativeMoveTo = [scanner scanString:@"m" intoString:NULL];
        
        BOOL absoluteLineTo = [scanner scanString:@"L" intoString:NULL];
        BOOL relativeLineTo = [scanner scanString:@"l" intoString:NULL];
        
        BOOL absoluteHorizontal = [scanner scanString:@"H" intoString:NULL];
        BOOL relativeHorizontal = [scanner scanString:@"h" intoString:NULL];
        
        BOOL absoluteVertical = [scanner scanString:@"V" intoString:NULL];
        BOOL relativeVertical = [scanner scanString:@"v" intoString:NULL];
        
        BOOL absoluteQuadratic = [scanner scanString:@"Q" intoString:NULL];
        BOOL relativeQuadratic = [scanner scanString:@"q" intoString:NULL];
        
        BOOL absoluteQuadraticTo = [scanner scanString:@"T" intoString:NULL];
        BOOL relativeQuadraticTo = [scanner scanString:@"t" intoString:NULL];
        
        BOOL absoluteCurve = [scanner scanString:@"C" intoString:NULL];
        BOOL relativeCurve = [scanner scanString:@"c" intoString:NULL];
        
        BOOL closePath = [scanner scanCharactersFromSet:closePathCharacters intoString:NULL];
        
        //N.B. Currently unsupported (except for 0 radius)
        BOOL absoluteArc = [scanner scanString:@"A" intoString:NULL];
        BOOL relativeArc = [scanner scanString:@"a" intoString:NULL];
        
        if (absoluteMoveTo || relativeMoveTo) {
            double x, y;
            BOOL useAsLineTo = NO;
            while ([scanner scanDouble:&x] && [scanner scanDouble:&y]) {
                if (relativeMoveTo) {
                    lastX += x;
                    lastY += y;
                }
                else {
                    lastX = x;
                    lastY = y;
                }
                if (!useAsLineTo) {
                    CGPathMoveToPoint(path, transform, lastX, lastY);
                }
                else {
                    CGPathAddLineToPoint(path, transform, lastX, lastY);
                }
                //All coordinates after the first pair are treated as line to instructions
                useAsLineTo = YES;
            }
        }
        else if (relativeLineTo || absoluteLineTo) {
            double x, y;
            
            while ([scanner scanDouble:&x] && [scanner scanDouble:&y]) {
                if (relativeLineTo) {
                    lastX += x;
                    lastY += y;
                }
                else {
                    lastX = x;
                    lastY = y;
                }
                LineToLast();
            }
        }
        else if (closePath) {
            CGPathCloseSubpath(path);
        }
        else if (absoluteHorizontal || relativeHorizontal) {
            double x;
            while ([scanner scanDouble:&x]) {
                if (relativeHorizontal) {
                    x += lastX;
                }
                lastX = x;
                LineToLast();
            }
        }
        else if (absoluteVertical || relativeVertical) {
            double y;
            while ([scanner scanDouble:&y]) {
                if (relativeVertical) {
                    y += lastY;
                }
                lastY = y;
                LineToLast();
            }
        }
        else if (absoluteCurve || relativeCurve) {
            double control1X, control1Y, control2X, control2Y, endX, endY;
            while ([scanner scanDouble:&control1X] && [scanner scanDouble:&control1Y] &&
                   [scanner scanDouble:&control2X] && [scanner scanDouble:&control2Y] &&
                   [scanner scanDouble:&endX] && [scanner scanDouble:&endY]) {
                
                if (relativeCurve) {
                    control1X += lastX;
                    control1Y += lastY;
                    control2X += lastX;
                    control2Y += lastY;
                    endX += lastX;
                    endY += lastY;
                }
                
                lastX = endX;
                lastY = endY;
                
                CGPoint endPoint = Last();
                CGPoint control1 = CGPointMake(control1X, control1Y);
                CGPoint control2 = CGPointMake(control2X, control2Y);
                
                CGPathAddCurveToPoint(path, transform, control1.x, control1.y, control2.x, control2.y, endPoint.x, endPoint.y);
            }
        }
        //I am currently not implementing the S/s curves
        //Absolute quadratic curve
        else if (absoluteQuadratic || relativeQuadratic) {
            double controlX, controlY, endX, endY;
            while ([scanner scanDouble:&controlX] && [scanner scanDouble:&controlY] &&
                   [scanner scanDouble:&endX] && [scanner scanDouble:&endY]) {
                if (relativeQuadratic) {
                    controlX += lastX;
                    controlY += lastY;
                    endX += lastX;
                    endY += lastY;
                }
                
                lastControlX = controlX;
                lastControlY = controlY;
                
                QuadraticCurveTo(controlX, controlY, endX, endY);
                
                lastX = endX;
                lastY = endY;
            }
        }
        else if (absoluteQuadraticTo || relativeQuadraticTo) {
            double endX, endY;
            while ([scanner scanDouble:&endX] && [scanner scanDouble:&endY]) {
                if (relativeQuadraticTo) {
                    endX += lastX;
                    endY += lastY;
                }
                
                double controlX = lastX + (lastX - lastControlX);
                double controlY = lastY + (lastY - lastControlY);
                
                QuadraticCurveTo(controlX, controlY, endX, endY);
                
                lastControlX = controlX;
                lastControlY = controlY;
                lastX = endX;
                lastY = endY;
            }
        }
        //Again, I am skipping quadratic curves with reflection because it looks hard
        //Arcs
        else if (relativeArc || absoluteArc) {
            //This implementation is currently incomplete because it is an arse
            //It is very different to canvas arcs
            //http://www.w3.org/TR/SVG11/implnote.html#ArcImplementationNotes
            double rx, ry, rotation, largeArcFlag, sweepFlag, x, y;
            while ([scanner scanDouble:&rx] && [scanner scanDouble:&ry] &&
                   [scanner scanDouble:&rotation] && [scanner scanDouble:&largeArcFlag] &&
                   [scanner scanDouble:&sweepFlag] &&
                   [scanner scanDouble:&x] && [scanner scanDouble:&y]) {
                if (relativeArc) {
                    x += lastX;
                    y += lastY;
                }
                
                //Don't draw if end point is the same as the start point
                if (x == lastX && y == lastY) {
                    continue;
                }
                
                rx = MAX(0, ABS(rx));
                ry = MAX(0, ABS(ry));
                
                if (rx == 0 || ry == 0) {
                    CGPathAddLineToPoint(path, transform, x, y);
                    continue;
                }
                
                lastX = x;
                lastY = y;
            }
        }
    }
    
    return path;
}

@implementation UIBezierPath (COB)

+ (UIBezierPath*)cob_bezierPathWithSVG:(NSString *)svg transform:(CGAffineTransform*)transform {
    CGPathRef path = COBCGPathFromSVG(svg, transform);
    if (path != NULL) {
        return [UIBezierPath bezierPathWithCGPath:path];
    }
    return nil;
}

@end
