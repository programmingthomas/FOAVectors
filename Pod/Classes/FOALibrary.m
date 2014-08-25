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

#import "FOALibrary.h"

@interface FOALibrary ()

@property NSMutableArray * glyphs;

@property CGFloat horizontalAdvance;
@property CGFloat unitsPerEM;
@property CGFloat ascent;
@property CGFloat descent;

+ (FOALibrary*)library;

@end

@implementation FOALibrary



+ (FOALibrary*)library {
    static FOALibrary * library;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [FOALibrary new];
    });
    return library;
}

+ (void)load {
    [[FOALibrary library] load];
}

+ (NSArray*)glyphs {
    return [[FOALibrary library] glyphs];
}

+ (FOAGlyph*)glyphWithName:(NSString *)name {
    NSString * unicode = [[FOALibrary library] namesToUnicode][name];
    for (FOAGlyph * glyph in [self glyphs]) {
        if ([glyph.unicode isEqualToString:unicode]) {
            return glyph;
        }
    }
    return nil;
}

#pragma mark - Private instance methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.glyphs = [NSMutableArray new];
    }
    return self;
}

- (void)load {
    self.glyphs = [NSMutableArray new];
    NSURL * svgFileURL = [[NSBundle mainBundle] URLForResource:@"fontawesome-webfont" withExtension:@"svg"];
    NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:svgFileURL];
    parser.delegate = self;
    parser.shouldResolveExternalEntities = YES;
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"font"]) {
        self.horizontalAdvance = [attributeDict[@"horiz-adv-x"] floatValue];
    }
    else if ([elementName isEqualToString:@"font-face"]) {
        self.unitsPerEM = [attributeDict[@"units-per-em"] floatValue];
        self.ascent = [attributeDict[@"ascent"] floatValue];
        self.descent = [attributeDict[@"descent"] floatValue];
    }
    else if ([elementName isEqualToString:@"glyph"]) {
        FOAGlyph * glyph = [self defaultGlpyh];
        if (attributeDict[@"horiz-adv-x"]) {
            glyph.horizontalAdvance = [attributeDict[@"horiz-adv-x"] floatValue];
        }
        glyph.unicode = attributeDict[@"unicode"];
        glyph.pathData = attributeDict[@"d"];
        glyph.name = [[[self namesToUnicode] allKeysForObject:glyph.unicode] firstObject];
        if (glyph.pathData) {
            [self.glyphs addObject:glyph];
        }
    }
}

- (FOAGlyph*)defaultGlpyh {
    FOAGlyph * glyph = [FOAGlyph new];
    glyph.horizontalAdvance = self.horizontalAdvance;
    glyph.unitsPerEM = self.unitsPerEM;
    glyph.ascent = self.ascent;
    glyph.descent = self.descent;
    return glyph;
}


- (NSDictionary*)namesToUnicode {
    static NSDictionary * namesToUnicode;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        namesToUnicode = @{
                           @"fa-adjust": @"\uf042",
                           @"fa-adn": @"\uf170",
                           @"fa-align-center": @"\uf037",
                           @"fa-align-justify": @"\uf039",
                           @"fa-align-left": @"\uf036",
                           @"fa-align-right": @"\uf038",
                           @"fa-ambulance": @"\uf0f9",
                           @"fa-anchor": @"\uf13d",
                           @"fa-android": @"\uf17b",
                           @"fa-angle-double-down": @"\uf103",
                           @"fa-angle-double-left": @"\uf100",
                           @"fa-angle-double-right": @"\uf101",
                           @"fa-angle-double-up": @"\uf102",
                           @"fa-angle-down": @"\uf107",
                           @"fa-angle-left": @"\uf104",
                           @"fa-angle-right": @"\uf105",
                           @"fa-angle-up": @"\uf106",
                           @"fa-apple": @"\uf179",
                           @"fa-archive": @"\uf187",
                           @"fa-arrow-circle-down": @"\uf0ab",
                           @"fa-arrow-circle-left": @"\uf0a8",
                           @"fa-arrow-circle-o-down": @"\uf01a",
                           @"fa-arrow-circle-o-left": @"\uf190",
                           @"fa-arrow-circle-o-right": @"\uf18e",
                           @"fa-arrow-circle-o-up": @"\uf01b",
                           @"fa-arrow-circle-right": @"\uf0a9",
                           @"fa-arrow-circle-up": @"\uf0aa",
                           @"fa-arrow-down": @"\uf063",
                           @"fa-arrow-left": @"\uf060",
                           @"fa-arrow-right": @"\uf061",
                           @"fa-arrow-up": @"\uf062",
                           @"fa-arrows": @"\uf047",
                           @"fa-arrows-alt": @"\uf0b2",
                           @"fa-arrows-h": @"\uf07e",
                           @"fa-arrows-v": @"\uf07d",
                           @"fa-asterisk": @"\uf069",
                           @"fa-automobile": @"\uf1b9",
                           @"fa-backward": @"\uf04a",
                           @"fa-ban": @"\uf05e",
                           @"fa-bank": @"\uf19c",
                           @"fa-bar-chart-o": @"\uf080",
                           @"fa-barcode": @"\uf02a",
                           @"fa-bars": @"\uf0c9",
                           @"fa-beer": @"\uf0fc",
                           @"fa-behance": @"\uf1b4",
                           @"fa-behance-square": @"\uf1b5",
                           @"fa-bell": @"\uf0f3",
                           @"fa-bell-o": @"\uf0a2",
                           @"fa-bitbucket": @"\uf171",
                           @"fa-bitbucket-square": @"\uf172",
                           @"fa-bitcoin": @"\uf15a",
                           @"fa-bold": @"\uf032",
                           @"fa-bolt": @"\uf0e7",
                           @"fa-bomb": @"\uf1e2",
                           @"fa-book": @"\uf02d",
                           @"fa-bookmark": @"\uf02e",
                           @"fa-bookmark-o": @"\uf097",
                           @"fa-briefcase": @"\uf0b1",
                           @"fa-btc": @"\uf15a",
                           @"fa-bug": @"\uf188",
                           @"fa-building": @"\uf1ad",
                           @"fa-building-o": @"\uf0f7",
                           @"fa-bullhorn": @"\uf0a1",
                           @"fa-bullseye": @"\uf140",
                           @"fa-cab": @"\uf1ba",
                           @"fa-calendar": @"\uf073",
                           @"fa-calendar-o": @"\uf133",
                           @"fa-camera": @"\uf030",
                           @"fa-camera-retro": @"\uf083",
                           @"fa-car": @"\uf1b9",
                           @"fa-caret-down": @"\uf0d7",
                           @"fa-caret-left": @"\uf0d9",
                           @"fa-caret-right": @"\uf0da",
                           @"fa-caret-square-o-down": @"\uf150",
                           @"fa-caret-square-o-left": @"\uf191",
                           @"fa-caret-square-o-right": @"\uf152",
                           @"fa-caret-square-o-up": @"\uf151",
                           @"fa-caret-up": @"\uf0d8",
                           @"fa-certificate": @"\uf0a3",
                           @"fa-chain": @"\uf0c1",
                           @"fa-chain-broken": @"\uf127",
                           @"fa-check": @"\uf00c",
                           @"fa-check-circle": @"\uf058",
                           @"fa-check-circle-o": @"\uf05d",
                           @"fa-check-square": @"\uf14a",
                           @"fa-check-square-o": @"\uf046",
                           @"fa-chevron-circle-down": @"\uf13a",
                           @"fa-chevron-circle-left": @"\uf137",
                           @"fa-chevron-circle-right": @"\uf138",
                           @"fa-chevron-circle-up": @"\uf139",
                           @"fa-chevron-down": @"\uf078",
                           @"fa-chevron-left": @"\uf053",
                           @"fa-chevron-right": @"\uf054",
                           @"fa-chevron-up": @"\uf077",
                           @"fa-child": @"\uf1ae",
                           @"fa-circle": @"\uf111",
                           @"fa-circle-o": @"\uf10c",
                           @"fa-circle-o-notch": @"\uf1ce",
                           @"fa-circle-thin": @"\uf1db",
                           @"fa-clipboard": @"\uf0ea",
                           @"fa-clock-o": @"\uf017",
                           @"fa-cloud": @"\uf0c2",
                           @"fa-cloud-download": @"\uf0ed",
                           @"fa-cloud-upload": @"\uf0ee",
                           @"fa-cny": @"\uf157",
                           @"fa-code": @"\uf121",
                           @"fa-code-fork": @"\uf126",
                           @"fa-codepen": @"\uf1cb",
                           @"fa-coffee": @"\uf0f4",
                           @"fa-cog": @"\uf013",
                           @"fa-cogs": @"\uf085",
                           @"fa-columns": @"\uf0db",
                           @"fa-comment": @"\uf075",
                           @"fa-comment-o": @"\uf0e5",
                           @"fa-comments": @"\uf086",
                           @"fa-comments-o": @"\uf0e6",
                           @"fa-compass": @"\uf14e",
                           @"fa-compress": @"\uf066",
                           @"fa-copy": @"\uf0c5",
                           @"fa-credit-card": @"\uf09d",
                           @"fa-crop": @"\uf125",
                           @"fa-crosshairs": @"\uf05b",
                           @"fa-css3": @"\uf13c",
                           @"fa-cube": @"\uf1b2",
                           @"fa-cubes": @"\uf1b3",
                           @"fa-cut": @"\uf0c4",
                           @"fa-cutlery": @"\uf0f5",
                           @"fa-dashboard": @"\uf0e4",
                           @"fa-database": @"\uf1c0",
                           @"fa-dedent": @"\uf03b",
                           @"fa-delicious": @"\uf1a5",
                           @"fa-desktop": @"\uf108",
                           @"fa-deviantart": @"\uf1bd",
                           @"fa-digg": @"\uf1a6",
                           @"fa-dollar": @"\uf155",
                           @"fa-dot-circle-o": @"\uf192",
                           @"fa-download": @"\uf019",
                           @"fa-dribbble": @"\uf17d",
                           @"fa-dropbox": @"\uf16b",
                           @"fa-drupal": @"\uf1a9",
                           @"fa-edit": @"\uf044",
                           @"fa-eject": @"\uf052",
                           @"fa-ellipsis-h": @"\uf141",
                           @"fa-ellipsis-v": @"\uf142",
                           @"fa-empire": @"\uf1d1",
                           @"fa-envelope": @"\uf0e0",
                           @"fa-envelope-o": @"\uf003",
                           @"fa-envelope-square": @"\uf199",
                           @"fa-eraser": @"\uf12d",
                           @"fa-eur": @"\uf153",
                           @"fa-euro": @"\uf153",
                           @"fa-exchange": @"\uf0ec",
                           @"fa-exclamation": @"\uf12a",
                           @"fa-exclamation-circle": @"\uf06a",
                           @"fa-exclamation-triangle": @"\uf071",
                           @"fa-expand": @"\uf065",
                           @"fa-external-link": @"\uf08e",
                           @"fa-external-link-square": @"\uf14c",
                           @"fa-eye": @"\uf06e",
                           @"fa-eye-slash": @"\uf070",
                           @"fa-facebook": @"\uf09a",
                           @"fa-facebook-square": @"\uf082",
                           @"fa-fast-backward": @"\uf049",
                           @"fa-fast-forward": @"\uf050",
                           @"fa-fax": @"\uf1ac",
                           @"fa-female": @"\uf182",
                           @"fa-fighter-jet": @"\uf0fb",
                           @"fa-file": @"\uf15b",
                           @"fa-file-archive-o": @"\uf1c6",
                           @"fa-file-audio-o": @"\uf1c7",
                           @"fa-file-code-o": @"\uf1c9",
                           @"fa-file-excel-o": @"\uf1c3",
                           @"fa-file-image-o": @"\uf1c5",
                           @"fa-file-movie-o": @"\uf1c8",
                           @"fa-file-o": @"\uf016",
                           @"fa-file-pdf-o": @"\uf1c1",
                           @"fa-file-photo-o": @"\uf1c5",
                           @"fa-file-picture-o": @"\uf1c5",
                           @"fa-file-powerpoint-o": @"\uf1c4",
                           @"fa-file-sound-o": @"\uf1c7",
                           @"fa-file-text": @"\uf15c",
                           @"fa-file-text-o": @"\uf0f6",
                           @"fa-file-video-o": @"\uf1c8",
                           @"fa-file-word-o": @"\uf1c2",
                           @"fa-file-zip-o": @"\uf1c6",
                           @"fa-files-o": @"\uf0c5",
                           @"fa-film": @"\uf008",
                           @"fa-filter": @"\uf0b0",
                           @"fa-fire": @"\uf06d",
                           @"fa-fire-extinguisher": @"\uf134",
                           @"fa-flag": @"\uf024",
                           @"fa-flag-checkered": @"\uf11e",
                           @"fa-flag-o": @"\uf11d",
                           @"fa-flash": @"\uf0e7",
                           @"fa-flask": @"\uf0c3",
                           @"fa-flickr": @"\uf16e",
                           @"fa-floppy-o": @"\uf0c7",
                           @"fa-folder": @"\uf07b",
                           @"fa-folder-o": @"\uf114",
                           @"fa-folder-open": @"\uf07c",
                           @"fa-folder-open-o": @"\uf115",
                           @"fa-font": @"\uf031",
                           @"fa-forward": @"\uf04e",
                           @"fa-foursquare": @"\uf180",
                           @"fa-frown-o": @"\uf119",
                           @"fa-gamepad": @"\uf11b",
                           @"fa-gavel": @"\uf0e3",
                           @"fa-gbp": @"\uf154",
                           @"fa-ge": @"\uf1d1",
                           @"fa-gear": @"\uf013",
                           @"fa-gears": @"\uf085",
                           @"fa-gift": @"\uf06b",
                           @"fa-git": @"\uf1d3",
                           @"fa-git-square": @"\uf1d2",
                           @"fa-github": @"\uf09b",
                           @"fa-github-alt": @"\uf113",
                           @"fa-github-square": @"\uf092",
                           @"fa-gittip": @"\uf184",
                           @"fa-glass": @"\uf000",
                           @"fa-globe": @"\uf0ac",
                           @"fa-google": @"\uf1a0",
                           @"fa-google-plus": @"\uf0d5",
                           @"fa-google-plus-square": @"\uf0d4",
                           @"fa-graduation-cap": @"\uf19d",
                           @"fa-group": @"\uf0c0",
                           @"fa-h-square": @"\uf0fd",
                           @"fa-hacker-news": @"\uf1d4",
                           @"fa-hand-o-down": @"\uf0a7",
                           @"fa-hand-o-left": @"\uf0a5",
                           @"fa-hand-o-right": @"\uf0a4",
                           @"fa-hand-o-up": @"\uf0a6",
                           @"fa-hdd-o": @"\uf0a0",
                           @"fa-header": @"\uf1dc",
                           @"fa-headphones": @"\uf025",
                           @"fa-heart": @"\uf004",
                           @"fa-heart-o": @"\uf08a",
                           @"fa-history": @"\uf1da",
                           @"fa-home": @"\uf015",
                           @"fa-hospital-o": @"\uf0f8",
                           @"fa-html5": @"\uf13b",
                           @"fa-image": @"\uf03e",
                           @"fa-inbox": @"\uf01c",
                           @"fa-indent": @"\uf03c",
                           @"fa-info": @"\uf129",
                           @"fa-info-circle": @"\uf05a",
                           @"fa-inr": @"\uf156",
                           @"fa-instagram": @"\uf16d",
                           @"fa-institution": @"\uf19c",
                           @"fa-italic": @"\uf033",
                           @"fa-joomla": @"\uf1aa",
                           @"fa-jpy": @"\uf157",
                           @"fa-jsfiddle": @"\uf1cc",
                           @"fa-key": @"\uf084",
                           @"fa-keyboard-o": @"\uf11c",
                           @"fa-krw": @"\uf159",
                           @"fa-language": @"\uf1ab",
                           @"fa-laptop": @"\uf109",
                           @"fa-leaf": @"\uf06c",
                           @"fa-legal": @"\uf0e3",
                           @"fa-lemon-o": @"\uf094",
                           @"fa-level-down": @"\uf149",
                           @"fa-level-up": @"\uf148",
                           @"fa-life-bouy": @"\uf1cd",
                           @"fa-life-ring": @"\uf1cd",
                           @"fa-life-saver": @"\uf1cd",
                           @"fa-lightbulb-o": @"\uf0eb",
                           @"fa-link": @"\uf0c1",
                           @"fa-linkedin": @"\uf0e1",
                           @"fa-linkedin-square": @"\uf08c",
                           @"fa-linux": @"\uf17c",
                           @"fa-list": @"\uf03a",
                           @"fa-list-alt": @"\uf022",
                           @"fa-list-ol": @"\uf0cb",
                           @"fa-list-ul": @"\uf0ca",
                           @"fa-location-arrow": @"\uf124",
                           @"fa-lock": @"\uf023",
                           @"fa-long-arrow-down": @"\uf175",
                           @"fa-long-arrow-left": @"\uf177",
                           @"fa-long-arrow-right": @"\uf178",
                           @"fa-long-arrow-up": @"\uf176",
                           @"fa-magic": @"\uf0d0",
                           @"fa-magnet": @"\uf076",
                           @"fa-mail-forward": @"\uf064",
                           @"fa-mail-reply": @"\uf112",
                           @"fa-mail-reply-all": @"\uf122",
                           @"fa-male": @"\uf183",
                           @"fa-map-marker": @"\uf041",
                           @"fa-maxcdn": @"\uf136",
                           @"fa-medkit": @"\uf0fa",
                           @"fa-meh-o": @"\uf11a",
                           @"fa-microphone": @"\uf130",
                           @"fa-microphone-slash": @"\uf131",
                           @"fa-minus": @"\uf068",
                           @"fa-minus-circle": @"\uf056",
                           @"fa-minus-square": @"\uf146",
                           @"fa-minus-square-o": @"\uf147",
                           @"fa-mobile": @"\uf10b",
                           @"fa-mobile-phone": @"\uf10b",
                           @"fa-money": @"\uf0d6",
                           @"fa-moon-o": @"\uf186",
                           @"fa-mortar-board": @"\uf19d",
                           @"fa-music": @"\uf001",
                           @"fa-navicon": @"\uf0c9",
                           @"fa-openid": @"\uf19b",
                           @"fa-outdent": @"\uf03b",
                           @"fa-pagelines": @"\uf18c",
                           @"fa-paper-plane": @"\uf1d8",
                           @"fa-paper-plane-o": @"\uf1d9",
                           @"fa-paperclip": @"\uf0c6",
                           @"fa-paragraph": @"\uf1dd",
                           @"fa-paste": @"\uf0ea",
                           @"fa-pause": @"\uf04c",
                           @"fa-paw": @"\uf1b0",
                           @"fa-pencil": @"\uf040",
                           @"fa-pencil-square": @"\uf14b",
                           @"fa-pencil-square-o": @"\uf044",
                           @"fa-phone": @"\uf095",
                           @"fa-phone-square": @"\uf098",
                           @"fa-photo": @"\uf03e",
                           @"fa-picture-o": @"\uf03e",
                           @"fa-pied-piper": @"\uf1a7",
                           @"fa-pied-piper-alt": @"\uf1a8",
                           @"fa-pied-piper-square": @"\uf1a7",
                           @"fa-pinterest": @"\uf0d2",
                           @"fa-pinterest-square": @"\uf0d3",
                           @"fa-plane": @"\uf072",
                           @"fa-play": @"\uf04b",
                           @"fa-play-circle": @"\uf144",
                           @"fa-play-circle-o": @"\uf01d",
                           @"fa-plus": @"\uf067",
                           @"fa-plus-circle": @"\uf055",
                           @"fa-plus-square": @"\uf0fe",
                           @"fa-plus-square-o": @"\uf196",
                           @"fa-power-off": @"\uf011",
                           @"fa-print": @"\uf02f",
                           @"fa-puzzle-piece": @"\uf12e",
                           @"fa-qq": @"\uf1d6",
                           @"fa-qrcode": @"\uf029",
                           @"fa-question": @"\uf128",
                           @"fa-question-circle": @"\uf059",
                           @"fa-quote-left": @"\uf10d",
                           @"fa-quote-right": @"\uf10e",
                           @"fa-ra": @"\uf1d0",
                           @"fa-random": @"\uf074",
                           @"fa-rebel": @"\uf1d0",
                           @"fa-recycle": @"\uf1b8",
                           @"fa-reddit": @"\uf1a1",
                           @"fa-reddit-square": @"\uf1a2",
                           @"fa-refresh": @"\uf021",
                           @"fa-renren": @"\uf18b",
                           @"fa-reorder": @"\uf0c9",
                           @"fa-repeat": @"\uf01e",
                           @"fa-reply": @"\uf112",
                           @"fa-reply-all": @"\uf122",
                           @"fa-retweet": @"\uf079",
                           @"fa-rmb": @"\uf157",
                           @"fa-road": @"\uf018",
                           @"fa-rocket": @"\uf135",
                           @"fa-rotate-left": @"\uf0e2",
                           @"fa-rotate-right": @"\uf01e",
                           @"fa-rouble": @"\uf158",
                           @"fa-rss": @"\uf09e",
                           @"fa-rss-square": @"\uf143",
                           @"fa-rub": @"\uf158",
                           @"fa-ruble": @"\uf158",
                           @"fa-rupee": @"\uf156",
                           @"fa-save": @"\uf0c7",
                           @"fa-scissors": @"\uf0c4",
                           @"fa-search": @"\uf002",
                           @"fa-search-minus": @"\uf010",
                           @"fa-search-plus": @"\uf00e",
                           @"fa-send": @"\uf1d8",
                           @"fa-send-o": @"\uf1d9",
                           @"fa-share": @"\uf064",
                           @"fa-share-alt": @"\uf1e0",
                           @"fa-share-alt-square": @"\uf1e1",
                           @"fa-share-square": @"\uf14d",
                           @"fa-share-square-o": @"\uf045",
                           @"fa-shield": @"\uf132",
                           @"fa-shopping-cart": @"\uf07a",
                           @"fa-sign-in": @"\uf090",
                           @"fa-sign-out": @"\uf08b",
                           @"fa-signal": @"\uf012",
                           @"fa-sitemap": @"\uf0e8",
                           @"fa-skype": @"\uf17e",
                           @"fa-slack": @"\uf198",
                           @"fa-sliders": @"\uf1de",
                           @"fa-smile-o": @"\uf118",
                           @"fa-sort": @"\uf0dc",
                           @"fa-sort-alpha-asc": @"\uf15d",
                           @"fa-sort-alpha-desc": @"\uf15e",
                           @"fa-sort-amount-asc": @"\uf160",
                           @"fa-sort-amount-desc": @"\uf161",
                           @"fa-sort-asc": @"\uf0de",
                           @"fa-sort-desc": @"\uf0dd",
                           @"fa-sort-down": @"\uf0dd",
                           @"fa-sort-numeric-asc": @"\uf162",
                           @"fa-sort-numeric-desc": @"\uf163",
                           @"fa-sort-up": @"\uf0de",
                           @"fa-soundcloud": @"\uf1be",
                           @"fa-space-shuttle": @"\uf197",
                           @"fa-spinner": @"\uf110",
                           @"fa-spoon": @"\uf1b1",
                           @"fa-spotify": @"\uf1bc",
                           @"fa-square": @"\uf0c8",
                           @"fa-square-o": @"\uf096",
                           @"fa-stack-exchange": @"\uf18d",
                           @"fa-stack-overflow": @"\uf16c",
                           @"fa-star": @"\uf005",
                           @"fa-star-half": @"\uf089",
                           @"fa-star-half-empty": @"\uf123",
                           @"fa-star-half-full": @"\uf123",
                           @"fa-star-half-o": @"\uf123",
                           @"fa-star-o": @"\uf006",
                           @"fa-steam": @"\uf1b6",
                           @"fa-steam-square": @"\uf1b7",
                           @"fa-step-backward": @"\uf048",
                           @"fa-step-forward": @"\uf051",
                           @"fa-stethoscope": @"\uf0f1",
                           @"fa-stop": @"\uf04d",
                           @"fa-strikethrough": @"\uf0cc",
                           @"fa-stumbleupon": @"\uf1a4",
                           @"fa-stumbleupon-circle": @"\uf1a3",
                           @"fa-subscript": @"\uf12c",
                           @"fa-suitcase": @"\uf0f2",
                           @"fa-sun-o": @"\uf185",
                           @"fa-superscript": @"\uf12b",
                           @"fa-support": @"\uf1cd",
                           @"fa-table": @"\uf0ce",
                           @"fa-tablet": @"\uf10a",
                           @"fa-tachometer": @"\uf0e4",
                           @"fa-tag": @"\uf02b",
                           @"fa-tags": @"\uf02c",
                           @"fa-tasks": @"\uf0ae",
                           @"fa-taxi": @"\uf1ba",
                           @"fa-tencent-weibo": @"\uf1d5",
                           @"fa-terminal": @"\uf120",
                           @"fa-text-height": @"\uf034",
                           @"fa-text-width": @"\uf035",
                           @"fa-th": @"\uf00a",
                           @"fa-th-large": @"\uf009",
                           @"fa-th-list": @"\uf00b",
                           @"fa-thumb-tack": @"\uf08d",
                           @"fa-thumbs-down": @"\uf165",
                           @"fa-thumbs-o-down": @"\uf088",
                           @"fa-thumbs-o-up": @"\uf087",
                           @"fa-thumbs-up": @"\uf164",
                           @"fa-ticket": @"\uf145",
                           @"fa-times": @"\uf00d",
                           @"fa-times-circle": @"\uf057",
                           @"fa-times-circle-o": @"\uf05c",
                           @"fa-tint": @"\uf043",
                           @"fa-toggle-down": @"\uf150",
                           @"fa-toggle-left": @"\uf191",
                           @"fa-toggle-right": @"\uf152",
                           @"fa-toggle-up": @"\uf151",
                           @"fa-trash-o": @"\uf014",
                           @"fa-tree": @"\uf1bb",
                           @"fa-trello": @"\uf181",
                           @"fa-trophy": @"\uf091",
                           @"fa-truck": @"\uf0d1",
                           @"fa-try": @"\uf195",
                           @"fa-tumblr": @"\uf173",
                           @"fa-tumblr-square": @"\uf174",
                           @"fa-turkish-lira": @"\uf195",
                           @"fa-twitter": @"\uf099",
                           @"fa-twitter-square": @"\uf081",
                           @"fa-umbrella": @"\uf0e9",
                           @"fa-underline": @"\uf0cd",
                           @"fa-undo": @"\uf0e2",
                           @"fa-university": @"\uf19c",
                           @"fa-unlink": @"\uf127",
                           @"fa-unlock": @"\uf09c",
                           @"fa-unlock-alt": @"\uf13e",
                           @"fa-unsorted": @"\uf0dc",
                           @"fa-upload": @"\uf093",
                           @"fa-usd": @"\uf155",
                           @"fa-user": @"\uf007",
                           @"fa-user-md": @"\uf0f0",
                           @"fa-users": @"\uf0c0",
                           @"fa-video-camera": @"\uf03d",
                           @"fa-vimeo-square": @"\uf194",
                           @"fa-vine": @"\uf1ca",
                           @"fa-vk": @"\uf189",
                           @"fa-volume-down": @"\uf027",
                           @"fa-volume-off": @"\uf026",
                           @"fa-volume-up": @"\uf028",
                           @"fa-warning": @"\uf071",
                           @"fa-wechat": @"\uf1d7",
                           @"fa-weibo": @"\uf18a",
                           @"fa-weixin": @"\uf1d7",
                           @"fa-wheelchair": @"\uf193",
                           @"fa-windows": @"\uf17a",
                           @"fa-won": @"\uf159",
                           @"fa-wordpress": @"\uf19a",
                           @"fa-wrench": @"\uf0ad",
                           @"fa-xing": @"\uf168",
                           @"fa-xing-square": @"\uf169",
                           @"fa-yahoo": @"\uf19e",
                           @"fa-yen": @"\uf157",
                           @"fa-youtube": @"\uf167",
                           @"fa-youtube-play": @"\uf16a",
                           @"fa-youtube-square": @"\uf166"
                           };
    });
    return namesToUnicode;
}

@end
