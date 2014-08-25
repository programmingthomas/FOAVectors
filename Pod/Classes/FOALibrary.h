// FOALibrary.h
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

#import "FOAGlyph.h"

/**
 This class provides an opaque singleton interface to all of the icons. Call +load on application launch to load all of the data
 */
@interface FOALibrary : NSObject<NSXMLParserDelegate>

/**
 You must call this method to load the library on your app's launch, otherwise no icons will be available
 */
+ (void)load;

/**
 @return An array of FOAGlyph objects that were loaded from the library
 */
+ (NSArray*)glyphs;

/**
 @param A Font Awesome name for a glyph, such as fa-github
 @return A glyph if the name is known, or null otherwise
 */
+ (FOAGlyph*)glyphWithName:(NSString*)name;

@end
