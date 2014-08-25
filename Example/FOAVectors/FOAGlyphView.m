//
//  FOAGlyphView.m
//  FOAVectors
//
//  Created by Thomas Denney on 25/08/2014.
//  Copyright (c) 2014 Programming Thomas. All rights reserved.
//

#import "FOAGlyphView.h"

@implementation FOAGlyphView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self.fillColor setFill];
    [self.glyph drawInRect:self.bounds];
}

- (void)setGlyph:(FOAGlyph *)glyph {
    _glyph = glyph;
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

@end
