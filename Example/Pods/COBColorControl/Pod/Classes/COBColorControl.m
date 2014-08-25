// COBColorControl.m
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


#import "COBColorControl.h"
#import "COBGLProgram.h"

#pragma mark - Loupe defaults

//The duration of the animation used for loupe expanding, shrinking and animating
const NSTimeInterval kLoupeAnimationDuration = 0.25;
//Other defaults for the loupe
const CGFloat kLoupeDefaultRadius = 15;
const CGFloat kLoupeZoomedRadius = 40;
const CGFloat kLoupeDefaultShadowRadius = 2;
const CGFloat kLoupeZoomedShadowRadius = 5;
const CGFloat kLoupeDefaultLineWidth = 2;
const CGFloat kLoupeZoomedLineWidth = 5;

#pragma mark - Loupe

/**
 The loupe view is a private internal class which displays a single color inside a black circle with a shadow. The color of the shadow is inversly proportional to the brightness of the color inside the circle to ensure that it constrasts with the background. Internally this class uses a CAShapeLayer to render the circle, so it performs very well in animation.
 
 In order to give the perception of depth there are two methods, drop and lift, that appear to either shrink or grow the shape layer respectively.
 
 @note User interaction is disabled by default.
 */
@interface COBLoupeView : UIView

/**
 The internal color of the loupe. Default is white.
 */
@property (nonatomic) UIColor * color;

/**
 The layer that contains a circle rendered centrally within the view.
 */
@property CAShapeLayer * circleLayer;

/**
 Reduces the size of the circle, width of the border and radius of the shadow to the default size.
 */
- (void)drop;

/**
 Increases the size of the circle, width of the border and radius of the shadow so that the user can more easily see the color of the loupe when the finger is over it.
 */
- (void)lift;

@end

@implementation COBLoupeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.color = [UIColor whiteColor];
        self.circleLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.circleLayer];
        [self configureShape];
    }
    return self;
}

- (void)configureShape {
    self.circleLayer.path = [self droppedPath].CGPath;
    self.circleLayer.strokeColor = [UIColor blackColor].CGColor;
    self.circleLayer.lineWidth = kLoupeDefaultLineWidth;
    self.circleLayer.shadowOffset = CGSizeZero;
    self.circleLayer.shadowRadius = kLoupeDefaultShadowRadius;
    self.circleLayer.shadowOpacity = 1;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.circleLayer.fillColor = color.CGColor;
    CGFloat brightness;
    [color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    self.circleLayer.shadowColor = [UIColor colorWithWhite:1 - brightness alpha:0.25].CGColor;
}

- (void)drop {
    self.circleLayer.lineWidth = kLoupeDefaultLineWidth;
    self.circleLayer.shadowRadius = kLoupeDefaultShadowRadius;
    self.circleLayer.path = [self droppedPath].CGPath;
    
    CABasicAnimation * lineWidth = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidth.fromValue = @(kLoupeZoomedLineWidth);
    lineWidth.toValue = @(kLoupeDefaultLineWidth);
    
    CABasicAnimation * shadowRadius = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowRadius.fromValue = @(kLoupeZoomedShadowRadius);
    shadowRadius.toValue = @(kLoupeDefaultShadowRadius);
    
    CABasicAnimation * path = [CABasicAnimation animationWithKeyPath:@"path"];
    path.fromValue = [self liftedPath];
    path.toValue = [self droppedPath];
    
    CAAnimationGroup * dropAnimationGroup = [CAAnimationGroup animation];
    dropAnimationGroup.animations = @[lineWidth, shadowRadius, path];
    dropAnimationGroup.duration = kLoupeAnimationDuration;
    dropAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.circleLayer addAnimation:dropAnimationGroup forKey:@"drop"];
    
}

- (void)lift {
    CGFloat originalLineWidth = self.circleLayer.lineWidth;
    CGFloat originalShadowRadius = self.circleLayer.shadowRadius;
    
    self.circleLayer.lineWidth = kLoupeZoomedLineWidth;
    self.circleLayer.shadowRadius = kLoupeZoomedShadowRadius;
    self.circleLayer.path = [self liftedPath].CGPath;
    
    CABasicAnimation * lineWidth = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidth.fromValue = @(originalLineWidth);
    lineWidth.toValue = @(kLoupeZoomedLineWidth);
    
    CABasicAnimation * shadowRadius = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowRadius.fromValue = @(originalShadowRadius);
    shadowRadius.toValue = @(kLoupeZoomedShadowRadius);
    
    CABasicAnimation * path = [CABasicAnimation animationWithKeyPath:@"path"];
    path.fromValue = [self droppedPath];
    path.toValue = [self liftedPath];
    
    CAAnimationGroup * dropAnimationGroup = [CAAnimationGroup animation];
    dropAnimationGroup.animations = @[lineWidth, shadowRadius, path];
    dropAnimationGroup.duration = kLoupeAnimationDuration;
    dropAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.circleLayer addAnimation:dropAnimationGroup forKey:@"lift"];
}

- (UIBezierPath*)droppedPath {
    return [self bezierPathWithRadius:kLoupeDefaultRadius];
}

- (UIBezierPath*)liftedPath {
    return [self bezierPathWithRadius:kLoupeZoomedRadius];
}

- (UIBezierPath*)bezierPathWithRadius:(CGFloat)radius {
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
}

@end

#pragma mark - Hue slider

/**
 The hue slider is used internally within the color control as a vertical slider. It is a custom control that presents an image view behind a loupe. The hue image is generated pragmatically.
 */
@interface COBHueSlider : UIControl

/**
 The current selected hue on the vertical slider
 */
@property (nonatomic) CGFloat hue;

/**
 The image view which is presented behind the thumb.
 */
@property UIImageView * trackingView;

/**
 A loupe which is used as the thumb to present the currently selected hue. Please note that this loupe doesn't change size when the user interacts with it.
 */
@property COBLoupeView * loupeView;

@end

@implementation COBHueSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.trackingView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 1, 20, 2, CGRectGetHeight(self.frame) - 40)];
        self.trackingView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.trackingView];

        self.loupeView = [[COBLoupeView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 25, -25, 50, 50)];
        self.loupeView.userInteractionEnabled = YES;
        self.hue = 0;
        [self addSubview:self.loupeView];

        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        [self.loupeView addGestureRecognizer:panGesture];

        [self prepareHueImage];
    }
    return self;
}

- (void)prepareHueImage {
    NSInteger width = 1;
    NSInteger height = 512;

    unsigned char * data = (unsigned char *)malloc(width * height * 4);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);

    //This code is derived from Wikipedia's HSV code http://en.wikipedia.org/wiki/HSL_and_HSV#From_HSV
    for (GLuint y = 0; y < 512; y++) {
        GLuint index = y * 4;
        GLfloat hue = (1 - (GLfloat)y / 512.0) * 360;
        GLfloat x = 1 - ABS(fmod(hue / 60.0, 2) - 1);

        GLfloat r = 0, g = 0, b = 0;

        if (hue < 60) {
            r = 1;
            g = x;
        }
        else if (hue < 120) {
            r = x;
            g = 1;
        }
        else if (hue < 180) {
            g = 1;
            b = x;
        }
        else if (hue < 240) {
            g = x;
            b = 1;
        }
        else if (hue < 300) {
            r = x;
            b = 1;
        }
        else {
            r = 1;
            b = x;
        }

        data[index] = (GLubyte)(255.0 * r);
        data[index + 1] = (GLubyte)(255.0 * g);
        data[index + 2] = (GLubyte)(255.0 * b);
        data[index + 3] = 255; //a
    }

    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * image = [UIImage imageWithCGImage:imageRef];
    self.trackingView.image = image;
}

- (void)setHue:(CGFloat)hue {
    _hue = MAX(MIN(1, hue), 0);
    self.loupeView.color = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    self.loupeView.center = CGPointMake(CGRectGetMidX(self.bounds), (1 - self.hue) * CGRectGetHeight(self.trackingView.frame) + CGRectGetMinY(self.trackingView.frame));
}

- (void)panned:(UIPanGestureRecognizer*)panGesture {
    CGFloat y = [panGesture locationInView:self].y - CGRectGetMinX(self.trackingView.frame) + 15;
    self.hue = 1 - y / CGRectGetHeight(self.trackingView.frame);
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    }
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
}

#pragma mark - Hue slider accessibility

- (BOOL)isAccessibilityElement {
    return self.enabled;
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitAdjustable;
}

- (NSString*)accessibilityLabel {
    return @"Hue";
//    return NSLocalizedString(@"Hue", nil);
}

- (void)accessibilityIncrement {
    [self _adjustHueBy:15];
}

- (void)accessibilityDecrement {
    [self _adjustHueBy:-15];
}

- (void)_adjustHueBy:(CGFloat)increment {
    self.hue += increment / 360.0f;
    [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

- (NSString*)accessibilityValue {
    NSString * colorName = @"Red";
    CGFloat hue = self.hue * 360;
    if (hue >= 15 && hue <= 345) {
        if (hue <= 45) {
            colorName = @"Orange";
        }
        else if (hue <= 75) {
            colorName = @"Yellow";
        }
        else if (hue <= 160) {
            colorName = @"Green";
        }
        else if (hue <= 190) {
            colorName = @"Cyan";
        }
        else if (hue <= 270) {
            colorName = @"Blue";
        }
        else if (hue <= 285) {
            colorName = @"Purple";
        }
        else if (hue <= 300) {
            colorName = @"Pink";
        }
    }
    
    return [NSString stringWithFormat:@"%@, %d degrees", colorName, (int)round(hue)];
}

@end

#pragma mark - Accessible value changer

/**
 A very simple interface that can be used to represent values that can be changed using accessibility gestures, but that the view doesn't provide a UISlider for. You need to set the hint, label and frame yourself.
 */
@interface COBAccessibleValue : UIAccessibilityElement {
    NSString * _accessibilityValueOverride;
}

/**
 Mimic UISlider
 */
@property CGFloat minValue;
@property CGFloat maxValue;

/**
 Observe this
 */
@property CGFloat value;

@property CGFloat incrementAmount;

/**
 Default is %. If the units are % then the range should be from 0 to 1
 */
@property NSString * units;

/**
 Default is YES. This prevents VoiceOver from reading out stupidly long numbers.
 */
@property BOOL round;

@property CGRect viewFrame;

@end

@implementation COBAccessibleValue

- (instancetype)initWithAccessibilityContainer:(id)container {
    self = [super initWithAccessibilityContainer:container];
    if (self) {
        self.minValue = 0;
        self.maxValue = 1;
        self.value = 0.5;
        self.incrementAmount = 0.1;
        self.units = @"%";
        self.round = YES;
    }
    return self;
}

- (BOOL)isAccessibilityElement {
    return YES;
}

- (void)setAccessibilityValue:(NSString *)accessibilityValue {
    [super setAccessibilityValue:accessibilityValue];
    _accessibilityValueOverride = accessibilityValue;
}

- (NSString*)accessibilityValue {
    if (_accessibilityValueOverride) {
        return _accessibilityValueOverride;
    }
    
    CGFloat valueToRead = self.value;
    NSString * unitsString = self.units;
    
    if ([self.units isEqualToString:@"%"]) {
        valueToRead *= 100;
    }
    else {
        unitsString = [@" " stringByAppendingString:unitsString];
    }
    
    if (self.round) {
        return [NSString stringWithFormat:@"%d%@", (int)round(valueToRead), unitsString];
    }
    else {
        return [NSString stringWithFormat:@"%f%@", valueToRead, unitsString];
    }
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitAdjustable;
}

- (void)accessibilityIncrement {
    [self _change:self.incrementAmount];
}

- (void)accessibilityDecrement {
    [self _change:-self.incrementAmount];
}

- (void)_change:(CGFloat)change {
    self.value = MAX(MIN(self.value + change, self.maxValue), self.minValue);
}

- (CGRect)accessibilityFrame {
    UIView * parent = (UIView*)self.accessibilityContainer;
    CGPoint parentPointOnScreen = parent.accessibilityFrame.origin;
    return CGRectMake(parentPointOnScreen.x + self.viewFrame.origin.x, parentPointOnScreen.y + self.viewFrame.origin.y, self.viewFrame.size.width, self.viewFrame.size.height);
}

@end

#pragma mark - Color control

typedef struct {
    GLfloat position[2];
    GLfloat uv[2];
} COBPoint3D;

@interface COBColorControl () {
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    COBPoint3D _colorSquare[6];
}

@property COBLoupeView * loupeView;
@property COBHueSlider * hueSlider;

@property GLKView * saturationBrightnessView;
@property EAGLContext * context;

/**
 In order to reduce the rendering time for the saturation-brightness square as much as possible all branching was removed from the original shader and instead six individual shaders are compiled because a maximum of six branches per frame on the CPU is way better than several million on the GPU.
 */
@property NSArray * squarePrograms;

//@property COBAccessibleValue * hueAccessibleValue;
@property COBAccessibleValue * saturationAccessibleValue;
@property COBAccessibleValue * brightnessAccessibleValue;

@property NSArray * accessibleElements;

@end

@implementation COBColorControl

- (void)dealloc {
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    self.context = nil;
    
    if (self.accessibleElements) {
        [self.brightnessAccessibleValue removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
        [self.saturationAccessibleValue removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
    }
}

#pragma mark - Color control initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _generalInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _generalInit];
    }
    return self;
}

- (void)_generalInit {
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Couldn't create OpenGL context. Something is very wrong");
    }
    [EAGLContext setCurrentContext:self.context];
    
    
    [self _initViews];
    
    [self _initGL];
    
    
    [self placeLoupeAnimated:NO];
    
    self.enabled = YES;
}

- (void)_initViews {
    self.saturationBrightnessView = [[GLKView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetHeight(self.bounds) - 40, CGRectGetHeight(self.frame) - 40) context:self.context];
    
    self.saturationBrightnessView.delegate = self;
    self.saturationBrightnessView.drawableMultisample = GLKViewDrawableMultisample4X;
    [self addSubview:self.saturationBrightnessView];
    
    self.hueSlider = [[COBHueSlider alloc] initWithFrame:CGRectMake(CGRectGetHeight(self.frame), 0, CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    [self.hueSlider addTarget:self action:@selector(hueSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.hueSlider addTarget:self action:@selector(hueSliderEditingComplete:) forControlEvents:UIControlEventEditingDidEnd];
    [self addSubview:self.hueSlider];
    
    self.loupeView = [[COBLoupeView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self addSubview:self.loupeView];
    
    self.color = [UIColor colorWithHue:0 saturation:1 brightness:1 alpha:1];
    
    [self.saturationBrightnessView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInSquare:)]];
}

- (void)_initGL {
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    [self compilePrograms];
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    COBPoint3D topLeft = {{-1, -1}, {0, 0}};
    COBPoint3D topRight = {{1, -1}, {1, 0}};
    COBPoint3D bottomLeft =  {{-1, 1}, {0, 1}};
    COBPoint3D bottomRight =  {{1, 1}, {1, 1}};
    
    _colorSquare[0] = topLeft; _colorSquare[1] = topRight; _colorSquare[2] = bottomLeft;
    _colorSquare[3] = topRight; _colorSquare[4] = bottomLeft; _colorSquare[5] = bottomRight;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(COBPoint3D) * 6, _colorSquare, GL_DYNAMIC_DRAW);
    
    COBGLProgram * firstProgram = (COBGLProgram*)self.squarePrograms[0];
    glEnableVertexAttribArray(firstProgram.position);
    glVertexAttribPointer(firstProgram.position, 2, GL_FLOAT, GL_FALSE, sizeof(COBPoint3D), offsetof(COBPoint3D, position));
    glEnableVertexAttribArray(firstProgram.uv);
    glVertexAttribPointer(firstProgram.uv, 4, GL_FLOAT, GL_FALSE, sizeof(COBPoint3D), (const GLvoid*)offsetof(COBPoint3D, uv));
}

- (void)compilePrograms {
    //Square programs
    NSArray * orders = @[@"c,x,0", @"x,c,0", @"0,c,x", @"0,x,c", @"x,0,c", @"c,0,x"];
    NSMutableArray * programs = [NSMutableArray new];
    NSString * VertexShader = @"attribute vec4 position;attribute vec2 uv;varying lowp vec2 outUV;void main() {gl_Position = position;outUV = uv;}";

    for (NSString * order in orders) {
        NSString * fragmentShader = [NSString stringWithFormat:@"varying lowp vec2 outUV;uniform lowp float cMultiplier;void main() {lowp float c = outUV.y * outUV.x;lowp float x = c * cMultiplier;gl_FragColor = vec4(vec3(%@) + outUV.y - c, 1.0);}", order];
        [programs addObject:[[COBGLProgram alloc] initWithVertexShader:VertexShader fragmentShader:fragmentShader attributes:@[@"position", @"uv"]]];
    }
    self.squarePrograms = programs;
}

#pragma mark - OpenGL

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [EAGLContext setCurrentContext:self.context];
    
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat h = fmod(MIN(MAX(0, self.hue), 1) * 360, 360);
    COBGLProgram * squareProgram = self.squarePrograms[(NSInteger)floorf(h / 60)];
    [squareProgram use];
    
    glBindVertexArrayOES(_vertexArray);
    GLfloat cMultiplier = 1 - ABS(fmod(h / 60.0, 2) - 1);
    glUniform1f([squareProgram uniform:@"cMultiplier"], cMultiplier);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

#pragma mark - Touch tracking

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //This is always called because the pan gesture will only start tracking after there is a movement
    UITouch * touch = [touches anyObject];
    if (CGRectContainsPoint(self.saturationBrightnessView.frame, [touch locationInView:self.saturationBrightnessView])) {
        [self beginLoupeMovement:[touch locationInView:self.saturationBrightnessView]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //This is called if the user only taps rather than pans
    UITouch * touch = [touches anyObject];
    if (CGRectContainsPoint(self.saturationBrightnessView.frame, [touch locationInView:self.saturationBrightnessView])) {
        [self.loupeView drop];
        [self placeLoupeAnimated:NO];
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)panInSquare:(UIPanGestureRecognizer*)sender {
    CGPoint location = [sender locationInView:self.saturationBrightnessView];
    self.saturation = location.x / CGRectGetWidth(self.saturationBrightnessView.bounds);
    self.brightness = 1 - location.y / CGRectGetHeight(self.saturationBrightnessView.bounds);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.loupeView lift];
        [self placeLoupeAnimated:YES];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        [self.loupeView drop];
        [self placeLoupeAnimated:NO];
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else {
        [self placeLoupeAnimated:NO];
    }
}

#pragma mark - Loupe animation

- (void)beginLoupeMovement:(CGPoint)location {
    self.saturation = location.x / CGRectGetWidth(self.saturationBrightnessView.bounds);
    self.brightness = 1 - location.y / CGRectGetHeight(self.saturationBrightnessView.bounds);
    [self.loupeView lift];
    [self placeLoupeAnimated:YES];
}

- (void)placeLoupeAnimated:(BOOL)animated {
    self.loupeView.color = [self color];
    CGPoint location = CGPointMake(self.saturation * CGRectGetWidth(self.saturationBrightnessView.frame), (1 - self.brightness) * CGRectGetHeight(self.saturationBrightnessView.frame));
    location = CGPointMake(location.x + CGRectGetMinX(self.saturationBrightnessView.frame), location.y + CGRectGetMinY(self.saturationBrightnessView.frame));
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.loupeView.center = location;
        }];
    }
    else {
        self.loupeView.center = location;
    }
}

#pragma mark - Getters and setters

- (UIColor*)color {
    return [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1];
}

- (void)setColor:(UIColor *)color {
    CGFloat hue, saturation, brightness;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
    self.hue = hue;
    self.saturationAccessibleValue.value = self.saturation = saturation;
    self.brightnessAccessibleValue.value = self.brightness = brightness;
    [self placeLoupeAnimated:NO];
}

- (void)setHue:(CGFloat)hue {
    CGFloat newHue = MAX(MIN(1, hue), 0);
    if (newHue != _hue) {
        _hue = newHue;
        self.hueSlider.hue = hue;
        self.loupeView.color = [self color];
        [self.saturationBrightnessView setNeedsDisplay];
    }
}

- (void)setBrightness:(CGFloat)brightness {
    _brightness = MAX(MIN(1, brightness), 0);
}

- (void)setSaturation:(CGFloat)saturation {
    _saturation = MAX(MIN(1, saturation), 0);
}

- (void)hueSliderChanged:(id)sender {
    if ([sender respondsToSelector:@selector(hue)]) {
        _hue = [sender hue];
    }
    else if ([sender respondsToSelector:@selector(value)]) {
        _hue = [(COBAccessibleValue*)sender value] / 360.0;
        self.hueSlider.hue = _hue;
    }
    self.loupeView.color = [self color];
    [self.saturationBrightnessView setNeedsDisplay];
}

- (void)hueSliderEditingComplete:(id)sender {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.hueSlider.enabled = enabled;
    [UIView animateWithDuration:kLoupeAnimationDuration animations:^{
        self.alpha = enabled ? 1 : 0.5;
    }];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    if (!self.accessibleElements) {
        //Defaults are already percentages
        self.saturationAccessibleValue = [[COBAccessibleValue alloc] initWithAccessibilityContainer:self];
        self.saturationAccessibleValue.accessibilityLabel = @"Saturation";
        self.saturationAccessibleValue.value = self.saturation;
        self.saturationAccessibleValue.viewFrame = self.saturationBrightnessView.frame;
        
        self.brightnessAccessibleValue = [[COBAccessibleValue alloc] initWithAccessibilityContainer:self];
        self.brightnessAccessibleValue.accessibilityLabel = @"Brightness";
        self.brightnessAccessibleValue.value = self.brightness;
        self.brightnessAccessibleValue.viewFrame = self.saturationBrightnessView.frame;
        
        //KVO
        [self.brightnessAccessibleValue addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:0 context:nil];
        [self.saturationAccessibleValue addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:0 context:nil];
        
        self.accessibleElements = @[self.brightnessAccessibleValue, self.saturationAccessibleValue, self.hueSlider];
    }
    return self.enabled ? self.accessibleElements.count : 0;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return self.accessibleElements[index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [self.accessibleElements indexOfObject:element];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(value))] && self.enabled) {
        if (object == self.saturationAccessibleValue) {
            self.saturation = self.saturationAccessibleValue.value;
            [self placeLoupeAnimated:NO];
        }
        else if (object == self.brightnessAccessibleValue) {
            self.brightness = self.brightnessAccessibleValue.value;
            [self placeLoupeAnimated:NO];
        }
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
