//
//  FOAViewController.m
//  FOAVectors
//
//  Created by Programming Thomas on 08/25/2014.
//  Copyright (c) 2014 Programming Thomas. All rights reserved.
//

#import "FOAViewController.h"
#import "FOAGlyphViewController.h"

@interface FOAViewController ()

@end

@implementation FOAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FOALibrary load];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [FOALibrary glyphs].count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FOAGlyphCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.glyphView.glyph = [FOALibrary glyphs][indexPath.row];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"glyphSegue"]) {
        FOAGlyphViewController * vc = segue.destinationViewController;
        vc.glyph = [FOALibrary glyphs][[self.collectionView.indexPathsForSelectedItems[0] row]];
    }
}

@end
