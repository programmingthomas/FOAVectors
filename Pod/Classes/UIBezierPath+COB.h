// UIBezierPath+COB.h
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

/**
 Creates a CGPath object from a given SVG path string. Currently it will correctly support move to, line to, quadratic curve to and cubic curve to (along with all of their relative/absolute alternatives). It uses NSScanner to do the parsing.
 @param svg The SVG path data
 @param transform A transformation to apply to all path data (use CGAffineTransformIdentity if you don't need this)
 @see http://www.w3.org/TR/SVG11/paths.html#PathData and https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
 @warning Arcs aren't yet support, and neither are S/sT/t reflected curves
 @note Quadratic curves are converted to cubic curves to maintain compatibility with NSBezierPath (this doesn't affect their appearance)
 @return A path object create from the source SVG
 */
extern CGPathRef COBCGPathFromSVG(NSString* svg, CGAffineTransform * transform);

@interface UIBezierPath (COB)

///-------------------
///@name Path creation
///-------------------

/**
 Creates a path object from SVG path data
 @param svg The SVG path data
 @param transform A transformation that is applied to all points of the path data. Use CGAffineTransformIdentity or NULL if you don't need this
 @see COBCGPathFromSVG
 @return A path based off of the provided SVG
 */
+ (UIBezierPath*)cob_bezierPathWithSVG:(NSString*)svg transform:(CGAffineTransform*)transform;

@end
