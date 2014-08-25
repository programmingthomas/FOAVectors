// FOAGlyph.h
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

#import "FOAGlyph.h"
#import "UIBezierPath+COB.h"

@implementation FOAGlyph

- (CGAffineTransform)transform {
    CGFloat targetSize = 44;
    //Deal with the horizontal advance, units, etc
    CGFloat scale = targetSize / MAX(self.unitsPerEM, self.horizontalAdvance);
    
    //Firstly flip the coordinate system
    CGAffineTransform transform  = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, targetSize);
    transform = CGAffineTransformScale(transform, 1, -1);
    
    transform = CGAffineTransformScale(transform, scale, scale);
    
    if (self.horizontalAdvance < self.unitsPerEM) {
        transform = CGAffineTransformTranslate(transform, (self.unitsPerEM - self.horizontalAdvance) / 2, 0);
    }
    transform = CGAffineTransformTranslate(transform, 0, -self.descent);
    return transform;
}

- (UIBezierPath*)path {
    CGAffineTransform transform = [self transform];
    return [UIBezierPath cob_bezierPathWithSVG:self.pathData transform:&transform];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Glyph: %@ %@", self.unicode, self.pathData];
}

- (void)drawInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, CGRectGetWidth(rect) / 44.0, CGRectGetHeight(rect) / 44.0);
    [[self path] fill];
    CGContextRestoreGState(context);
}

- (UIImage*)imageAtSize:(CGSize)size color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
