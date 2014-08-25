//
//  FOAGlyphViewController.m
//  FOAVectors
//
//  Created by Thomas Denney on 25/08/2014.
//  Copyright (c) 2014 Programming Thomas. All rights reserved.
//

#import "FOAGlyphViewController.h"

@interface FOAGlyphViewController ()

@end

@implementation FOAGlyphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.glyphView.fillColor = self.colorControl.color = [UIColor blackColor];
    [self _configureView];
}

- (void)_configureView {
    self.glyphView.glyph = self.glyph;
    self.nameLabel.text = self.glyph.name;
}

- (void)setGlyph:(FOAGlyph *)glyph {
    _glyph = glyph;
    [self _configureView];
}

- (IBAction)colorChanged:(id)sender {
    self.glyphView.fillColor = self.colorControl.color;
}

@end
