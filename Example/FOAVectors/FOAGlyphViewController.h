//
//  FOAGlyphViewController.h
//  FOAVectors
//
//  Created by Thomas Denney on 25/08/2014.
//  Copyright (c) 2014 Programming Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FOALibrary.h>
#import <COBColorControl.h>
#import "FOAGlyphView.h"

@interface FOAGlyphViewController : UIViewController

@property (nonatomic) FOAGlyph * glyph;
@property (weak, nonatomic) IBOutlet FOAGlyphView *glyphView;
@property (weak, nonatomic) IBOutlet COBColorControl *colorControl;
- (IBAction)colorChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
