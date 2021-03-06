//
//  SLFTheme.m
//  Created by Greg Combs on 9/22/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTheme.h"
#import "GradientBackgroundView.h"
#import "SLFDrawingExtensions.h"
#import "TableSectionHeaderView.h"

RKTableSection* SLFAddTableControllerSectionWithTitle(RKTableController *controller, NSString *title) {
    if (IsEmpty(title))
        return nil;
    RKTableSection *section = [controller sectionWithHeaderTitle:title];
    if (!section) {
        UITableViewStyle style = controller.tableView.style;
        section = [RKTableSection section];
        section.headerTitle = title;
        section.headerHeight = [TableSectionHeaderView heightForTableViewStyle:style];
        TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:title width:300.f style:style];
        section.headerView = headerView;
        [headerView release];
        [controller addSection:section];
    }
    return section;
}

BOOL SLFAlternateCellForIndexPath(UITableViewCell *cell, NSIndexPath * indexPath) {
    BOOL useDark;
    BOOL inverse = (indexPath.section % 2 == 0);
    if (indexPath.row == 0 || indexPath.row % 2 == 0)
        useDark = inverse ? NO : YES;
    else
        useDark = inverse ? YES : NO;
    cell.backgroundColor = useDark ? [SLFAppearance cellBackgroundDarkColor] : [SLFAppearance cellBackgroundLightColor];
    cell.opaque = YES;
    return useDark;
}

UIBarButtonItem* SLFToolbarButton(UIImage *image, id target, SEL selector) {
    UIImage *normalImage = [image imageWithOverlayColor:[SLFAppearance tableBackgroundLightColor]];
    UIImage *selectedImage = [image imageWithOverlayColor:[SLFAppearance menuTextColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];    
    return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

// ex: red = 145, blue = 144, green = 130
NSArray* SLFBarStyleButtonImageGradientsWithSizeAndBaseColorRGB(CGSize imageSize, int red, int blue, int green) { 
    CGRect rect = CGRectMake(0,0,imageSize.width,imageSize.height);
    GradientBackgroundView *view = [[GradientBackgroundView alloc] initWithFrame:rect];
    [view loadLayerAndGradientColors];
    CAGradientLayer *grad = (CAGradientLayer *)view.layer;
    UIColor *mid = SLFColorWithRGB(red, blue, green);
    UIColor *light = SLFColorWithRGBShift(mid, +45);
    UIColor *dark = SLFColorWithRGBShift(mid, -20);
    grad.colors = [NSArray arrayWithObjects:(id)light.CGColor, (id)mid.CGColor, (id)dark.CGColor, nil];
    view.layer.frame = rect;
    UIImage *gradNormal = [UIImage imageFromView:view];
    
    red-=50, green-=50, blue-=50;
    mid = SLFColorWithRGB(red, blue, green);
    light = SLFColorWithRGBShift(mid, +45);
    dark = SLFColorWithRGBShift(mid, -20);
    grad.colors = [NSArray arrayWithObjects:(id)light.CGColor, (id)mid.CGColor, (id)dark.CGColor, nil];
    UIImage *gradSelected = [UIImage imageFromView:view];
    
    NSArray *gradientImages = [NSArray arrayWithObjects:gradNormal, gradSelected, nil];
    [view release];
    return gradientImages;
}

@implementation UIButton (SLFTintedButtons)

+ (UIButton *)buttonWithTitle:(NSString *)title orange:(BOOL)isOrange width:(CGFloat)width target:(id)target action:(SEL)action {
    NSString *normalPath = @"BarButtonGreenNormal";
    NSString *highlightPath = @"BarButtonGreenHighlight";
    if (isOrange) {
        normalPath = @"BarButtonNormal";
        highlightPath = @"BarButtonHighlight";
    }
    UIImage *normal = [[UIImage imageNamed:normalPath] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImage *highlight = [[UIImage imageNamed:highlightPath] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.frame = CGRectMake(0, 0, width, 30);
    
    [button setBackgroundImage:normal forState:UIControlStateNormal];
    [button setBackgroundImage:highlight forState:UIControlStateHighlighted];
    return button;
}

@end

@implementation UIBarButtonItem (SLFTintedButtons)

- (id)initWithTitle:(NSString *)title orange:(BOOL)isOrange width:(CGFloat)width target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithTitle:title orange:isOrange width:width target:target action:action];
    return (self = [self initWithCustomView:button]);
}

@end