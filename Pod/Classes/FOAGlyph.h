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

@import UIKit;

@interface FOAGlyph : NSObject

@property CGFloat horizontalAdvance;
@property CGFloat unitsPerEM;
@property CGFloat ascent;
@property CGFloat descent;
@property NSString * pathData;
@property NSString * unicode;
@property NSString * name;

/**
 This method generates a UIBezierPath that can be used to render the path on screen. The icon will be centered within the bounds of a rectangle {0,0,44,44}. You can therefore scale or translate this for your own presentation.
 */
- (UIBezierPath*)path;

/**
 Applys the appropriate transform and renders the path. The fill color and stroke color will not be affected
 @param rect The bounds in which to draw the glyph
 */
- (void)drawInRect:(CGRect)rect;

/**
 Renders the glyph at the screen's scale factor.
 @param size The dimensions of the image to render
 @param color The fill color to use
 @return A UIImage that contains the glyph rendered in the provided color
 */
- (UIImage*)imageAtSize:(CGSize)size color:(UIColor*)color;

@end
