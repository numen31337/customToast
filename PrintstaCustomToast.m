//
//  PrintstaCustomToast.m
//  Printsta
//
//  Created by Oleksandr Kirichenko on 11/21/13.
//  Copyright (c) 2013 Artem Myagkov. All rights reserved.
//

#import "PrintstaCustomToast.h"
#import "FXLabel.h"
#import "Constants.h"

@implementation PrintstaCustomToast
{
    CAShapeLayer *_firstCircle;
    CAShapeLayer *_secondCircle;
    CAShapeLayer *_thirdCircle;
    UIView *_boxView;
    UILabel *_title;
    UIButton *_bigButton;
    UIButton *_smallButton;
    UILabel *_message;
    UIImageView *_iconView;
    NSString *_iconImageName;
}

@synthesize delegate = _delegate;

 // window constants
CGFloat const boxHeight				= 300.f/2;
CGFloat const boxWidth				= 400.f/2;
CGFloat const fromButtonToBox		= 54.f /2;
CGFloat const fromBoxTopToMessage	= 146.f/2;
CGFloat const fromBoxTopToLabel		= 90.f /2;
CGFloat const fromImageToLabelSpace = 20.f /2;
CGFloat const esteticMessageOffset	= 16.f /2;
CGFloat const bigButtonWidth		= 320.f/2;
CGFloat const smallButtonWidth		= 140.f/2;
CGFloat const buttonHeight			= 84.f /2;
CGFloat const fromBoxToAnimation	= 26.f /2;
CGFloat const marginBetweenBoxes	= 13.f;

//animation constants
CGFloat const circleSize	 = 5.f;
CGFloat const animationSpeed = 0.3f;
CGFloat const maxOpacity	 = 0.9f;
CGFloat const minOpacity	 = 0.2f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _firstCircle  = [CAShapeLayer layer];
        _secondCircle = [CAShapeLayer layer];
        _thirdCircle  = [CAShapeLayer layer];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:(CGRect) {{0, 0}, {circleSize, circleSize}}];
        CGColorRef circleColor = [UIColor whiteColor].CGColor;
        CGPathRef circlePath = bezierPath.CGPath;
        [_firstCircle setPath:circlePath];
        [_firstCircle setFillColor:circleColor];
        [_secondCircle setPath:circlePath];
        [_secondCircle setFillColor:circleColor];
        [_thirdCircle setPath:circlePath];
        [_thirdCircle setFillColor:circleColor];
    }
    return self;
}

-(NSString *)title{
    return _title.text;
}

-(NSString*)selectedImageName:(NSString*)name
{
    NSArray	 *nameParts	   = [name componentsSeparatedByString:@"."];
    NSString *selectedPart = @"_selected";
    NSString *selectedName = [NSString stringWithFormat:@"%@%@.%@",[nameParts objectAtIndex:0],selectedPart,[nameParts objectAtIndex:1]];
    return selectedName;
}

-(FXLabel *)addLabelToButton:(UIButton*)button
					withText:(NSString*)text
					   color:(UIColor*)color
			  andShadowColor:(UIColor*)shadowColor
{
    UIFont *buttonFont = [UIFont fontWithName:kFontCommonBold size:15];
    CGSize labelSize = [text sizeWithFont:buttonFont];
	labelSize.height += 10;
    FXLabel *label = [[FXLabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = buttonFont;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = shadowColor;
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowBlur = 2.0;
	label.oversampling = 4;
    label.text = text;
    CGRect labelFrame = CGRectMake(1.f + (button.frame.size.width - labelSize.width) / 2, 0.f + (button.frame.size.height - labelSize.height) / 2, labelSize.width, labelSize.height);
    [label setFrame:labelFrame];
    [button addSubview:label];
	
	return label;
}

-(void)makeButtonsWithBigButtonTitle:(NSString*)bigButtonTitle
				  bigButtonImageName:(NSString*)bigButtonImageName
					smallButtonTitle:(NSString*)smallButtonTitle
				smallButtonImageName:(NSString*)smallButtonImageName
			invertButtonLabelsColors:(BOOL)invert
{
		//set default button backgrounds if nil
    NSLog(@"toast called");
    if (!bigButtonImageName)   { bigButtonImageName	  = @"blue_button.png"; }
    if (!smallButtonImageName) { smallButtonImageName = @"white_button.png"; }
    
    [_bigButton removeFromSuperview];
    _bigButton = nil;
    [_smallButton removeFromSuperview];
    _smallButton = nil;
    
    if (bigButtonTitle){
        CGFloat buttonTopOffset = _boxView.frame.origin.y + boxHeight + fromButtonToBox;
        CGFloat buttonOffset = ([UIScreen mainScreen].bounds.size.width - bigButtonWidth) / 2.f;
		
		if (smallButtonTitle) {	buttonOffset -= marginBetweenBoxes / 2.f; }
        
        _bigButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonOffset, buttonTopOffset, bigButtonWidth, buttonHeight)];
        
        [_bigButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *bigButtonImage = [[UIImage imageNamed:bigButtonImageName]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        UIImage *bigButtonImageHighlight = [[UIImage imageNamed:[self selectedImageName:bigButtonImageName]]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        [_bigButton setBackgroundImage:bigButtonImage forState:UIControlStateNormal];
        [_bigButton setBackgroundImage:bigButtonImage forState:UIControlStateDisabled];
        [_bigButton setBackgroundImage:bigButtonImageHighlight forState:UIControlStateHighlighted];
        _bigButton.tag = 1;
        [self addSubview:_bigButton];
        
        //add button label
        if (!invert){
			[self addLabelToButton:_bigButton
						  withText:bigButtonTitle
							 color:[UIColor whiteColor]
					andShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
        } else {
            [self addLabelToButton:_bigButton
						  withText:bigButtonTitle
							 color:[UIColor colorWithWhite:0.0 alpha:0.50]
					andShadowColor:[UIColor colorWithWhite:1.0 alpha:0.70]];
        }
        
        //add small button and shift bigone
        if (smallButtonTitle)
		{
            //position calculation
            CGRect bigButtonFrame = _bigButton.frame;
            bigButtonFrame.origin.x -= smallButtonWidth / 2;
            _bigButton.frame = bigButtonFrame;
            CGFloat smallButtonX = bigButtonFrame.origin.x + bigButtonFrame.size.width + marginBetweenBoxes;
            
            _smallButton = [[UIButton alloc] initWithFrame:CGRectMake(smallButtonX, buttonTopOffset, smallButtonWidth, buttonHeight)];
            [_smallButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            UIImage *smallButtonImage = [[UIImage imageNamed:smallButtonImageName]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
            UIImage *smallButtonImageHighlight = [[UIImage imageNamed:[self selectedImageName:smallButtonImageName]]
                                                  resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
            [_smallButton setBackgroundImage:smallButtonImage forState:UIControlStateNormal];
            [_smallButton setBackgroundImage:smallButtonImage forState:UIControlStateDisabled];
            [_smallButton setBackgroundImage:smallButtonImageHighlight forState:UIControlStateHighlighted];
            _smallButton.tag = 2;
            [self addSubview:_smallButton];
            
            //add button label
            if (!invert){
				FXLabel *label = [self addLabelToButton:_smallButton withText:smallButtonTitle
												  color:[UIColor colorWithWhite:0.0 alpha:0.5]
										 andShadowColor:[UIColor colorWithWhite:1.0 alpha:0.70]];
				label.shadowBlur = 1.0;
				label.innerShadowColor = [UIColor colorWithWhite:0.0 alpha:0.20];
				label.innerShadowOffset = (CGSize) { 0, 1 };
            } else {
                FXLabel *label = [self addLabelToButton:_smallButton
											   withText:smallButtonTitle
												  color:[UIColor whiteColor]
										 andShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
				label.shadowBlur = 1.0;
				label.innerShadowColor = [UIColor colorWithWhite:0.0 alpha:0.20];
				label.innerShadowOffset = (CGSize) { 0, 1 };
            }
        }
    }
}

-(void)setTitleImageNamed:(NSString*)toastTitleImageName
{
    [_iconView removeFromSuperview];
    _iconView = nil;
    
    if (toastTitleImageName) {
        //title must be seted first
        //save name and ask in setTitle
        _iconImageName = toastTitleImageName;
        if (_title.text == nil) { return; }
        
        UIImage *icon = [UIImage imageNamed:toastTitleImageName];
        _iconView = [[UIImageView alloc] initWithImage:icon];
        _iconView.center = _title.center;
        CGRect titleFrame = _title.frame;
        //shift label
        titleFrame.origin.x = _boxView.center.x - (_title.frame.size.width/2);
        titleFrame.origin.x += (fromImageToLabelSpace + _iconView.bounds.size.width)/2;
        _title.frame = titleFrame;
        
        CGRect iconFrame = _iconView.frame;
        if (![_title.text isEqualToString:@""]){ iconFrame.origin.x = titleFrame.origin.x - _iconView.bounds.size.width - fromImageToLabelSpace; }
        _iconView.frame = iconFrame;
        [self addSubview:_iconView];
    }
}

-(void)removeButtons
{
    [self makeButtonsWithBigButtonTitle:nil
					 bigButtonImageName:nil
					   smallButtonTitle:nil
				   smallButtonImageName:nil
			   invertButtonLabelsColors:NO];
}

-(void)setTitle:(NSString*)toastTitle
{
    UIFont *titleFont = [UIFont fontWithName:kFontCommonBold size:17];
    if (!toastTitle) { toastTitle = @""; }
    
    CGSize titleSize = [toastTitle sizeWithFont:titleFont];
    CGFloat labelYOrigin = _boxView.frame.origin.y + fromBoxTopToLabel;
    CGFloat labelXOrigin = _boxView.center.x - (titleSize.width/2);
    
    [_title removeFromSuperview];
    _title = nil;
    
    _title = [[UILabel alloc] initWithFrame:CGRectIntegral( (CGRect) { { labelXOrigin, labelYOrigin }, titleSize })];
    _title.font = titleFont;
    _title.text = toastTitle;
    _title.backgroundColor = [UIColor clearColor];
	_title.textColor = [UIColor colorWithWhite:0.31 alpha:1.f];
    [self addSubview:_title];
    
    if (_iconImageName && _iconImageName.length) { [self setTitleImageNamed:_iconImageName]; }
}

-(void)setMessage:(NSString*)toastMessage
{
    [_message removeFromSuperview];
    _message = nil;
    
    if (!toastMessage) { toastMessage = @""; }
    UIFont *messageFont = [UIFont fontWithName:kFontCommon size:12];
    CGFloat messageWidth = boxWidth-(esteticMessageOffset*2);
    CGFloat messageMaxHight = boxHeight-fromBoxTopToMessage-esteticMessageOffset;
    CGSize messageSize = [toastMessage sizeWithFont:messageFont
								  constrainedToSize:CGSizeMake(messageWidth,boxHeight-messageMaxHight)
									  lineBreakMode:NSLineBreakByWordWrapping];
	
    _message = [[UILabel alloc] initWithFrame:CGRectMake(_boxView.frame.origin.x+esteticMessageOffset,
                                                         _boxView.frame.origin.y+fromBoxTopToMessage,
                                                         messageWidth,
                                                         messageSize.height+2)];
    _message.textAlignment = NSTextAlignmentCenter;
    _message.numberOfLines = 0;
    _message.font = messageFont;
    _message.text = toastMessage;
    _message.backgroundColor = [UIColor clearColor];
	_message.textColor = [UIColor colorWithWhite:0.31 alpha:1.f];
    [self addSubview:_message];
}

-(void)setAttriburedMessage:(NSAttributedString*)string
{
    /*
    //HOW TO USE EXAMPLE:
    NSMutableAttributedString *msg=[[NSMutableAttributedString alloc]initWithString:@"Unfortunately we can't print this\n photo."];
    UIFont *messageBigFont = [UIFont fontWithName:kFontCommon size:12];
    UIFont *messageSmallFont = [UIFont fontWithName:kFontCommon size:10];
    NSDictionary *bigAttrs = [NSDictionary dictionaryWithObjectsAndKeys:messageBigFont, NSFontAttributeName, nil];
    NSDictionary *smallAttrs = [NSDictionary dictionaryWithObjectsAndKeys:messageSmallFont, NSFontAttributeName, nil];
    [msg addAttributes:smallAttrs range:NSMakeRange(0, msg.length)]; //special case first
    [msg addAttributes:bigAttrs range:NSMakeRange(0, 10)]; //overall last
    [toast setAttriburedMessage:msg];
    */
    
    [_message removeFromSuperview];
    _message = nil;
    
    //UIFont *messageFont = [UIFont fontWithName:kFontCommon size:10];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.maximumLineHeight = 0;
    NSUInteger length = [string length];
    NSRange effectiveRange = NSMakeRange(0, length);
    
    NSMutableAttributedString *attributedMessage = [string mutableCopy];
    NSDictionary *attributes = @{//NSFontAttributeName:messageFont,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    [attributedMessage addAttributes:attributes range:effectiveRange];
    
    CGSize messageSize = attributedMessage.size;
    
    CGFloat messageWidth = boxWidth-(esteticMessageOffset*2);
    _message = [[UILabel alloc] initWithFrame:CGRectMake(_boxView.frame.origin.x+esteticMessageOffset,
                                                         _boxView.frame.origin.y+fromBoxTopToMessage,
                                                         messageWidth,
                                                         messageSize.height)];
    _message.backgroundColor = [UIColor clearColor];
    _message.attributedText = attributedMessage;
    _message.numberOfLines = 0;

    [self addSubview:_message];
}

-(PrintstaCustomToast*)initWithTitle:(NSString *)toastTitle titleImageName:(NSString *)toastTitleImageName message:(NSString *)toastMessage bigButtonTitle:(NSString *)bigButtonTitle bigButtonImageName:(NSString *)bigButtonImageName smallButtonTitle:(NSString *)smallButtonTitle smallButtonImageName:(NSString *)smallButtonImageName invertButtonLabelsColors:(BOOL)invert delegate:(id<PrintstaCustomToastProtocol>)delegate
{
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    CGRect rootViewFrame = rootView.frame;
    
    self = [self initWithFrame:rootViewFrame];
    if (!self){ return self; }
    
    [self setDelegate:delegate];
    
    self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8f];
    
		// White view
    CGFloat boxTopOffset = (([UIScreen mainScreen].bounds.size.height - boxHeight - fromButtonToBox - buttonHeight) / 2);
    CGFloat boxLeftOffset = ([UIScreen mainScreen].bounds.size.width - boxWidth) / 2;
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] < 7) {
        rootViewFrame.origin.y -= 20;
        boxTopOffset -= 20;
    }
	
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, boxWidth, boxHeight);
    maskLayer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0].CGColor;
	maskLayer.cornerRadius = 10.f;
	maskLayer.masksToBounds = YES;
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(boxLeftOffset, boxTopOffset, boxWidth, boxHeight)];
    [[_boxView layer] addSublayer:maskLayer];
    [self addSubview:_boxView];
    
    [self setMessage:toastMessage];
    [self setTitle:toastTitle];
    [self setTitleImageNamed:toastTitleImageName];
    [self makeButtonsWithBigButtonTitle:bigButtonTitle
					 bigButtonImageName:bigButtonImageName
					   smallButtonTitle:smallButtonTitle
				   smallButtonImageName:smallButtonImageName
			   invertButtonLabelsColors:invert];
    
		// Adding animation layers
    CGRect circleFrame = _firstCircle.frame;
    circleFrame.origin.y = boxTopOffset + boxHeight + fromBoxToAnimation - circleSize/2;
    circleFrame.origin.x = _boxView.center.x - (circleSize*2.5);
    _firstCircle.frame = circleFrame;

    circleFrame.origin.x += circleSize*2;
    _secondCircle.frame = circleFrame;
	
    circleFrame.origin.x += circleSize*2;
    _thirdCircle.frame = circleFrame;
    
    [self.layer addSublayer:_firstCircle];
    [self.layer addSublayer:_secondCircle];
    [self.layer addSublayer:_thirdCircle];
    
    _firstCircle.opacity = 0.f;
    _secondCircle.opacity = 0.f;
    _thirdCircle.opacity = 0.f;
    
    [rootView addSubview:self];
    return self;
}

- (CABasicAnimation *)opacityAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:minOpacity];
    animation.toValue = [NSNumber numberWithFloat:maxOpacity];
    animation.duration = animationSpeed;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	return animation;
}

-(void)startAnimation
{
    self.isAnimating = YES;
    
	CABasicAnimation *animation = [self opacityAnimation];
	animation.beginTime = CACurrentMediaTime();
    [_firstCircle addAnimation:animation forKey:@"opacity_animation"];
    
	animation = [self opacityAnimation];
    animation.beginTime = CACurrentMediaTime()+(animationSpeed/3);
    [_secondCircle addAnimation:animation forKey:@"opacity_animation"];
    
	animation = [self opacityAnimation];
    animation.beginTime = CACurrentMediaTime()+(animationSpeed*2/3);
    [_thirdCircle addAnimation:animation forKey:@"opacity_animation"];
}

-(void)stopAnimation
{
    self.isAnimating = NO;
    
    [_firstCircle removeAllAnimations];
    [_secondCircle removeAllAnimations];
    [_thirdCircle removeAllAnimations];
    _firstCircle.opacity = 0.f;
    _secondCircle.opacity = 0.f;
    _thirdCircle.opacity = 0.f;
    
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    self.alpha = 0.f;
}

-(void)didMoveToSuperview{
    [UIView animateWithDuration:0.15f animations:^{self.alpha = 1.0f;}];
}

-(void)buttonClicked:(UIButton*)sender
{
    //Tags:
    //bigButton.tag   = 1
    //smallButton.tag = 2
    [self.delegate customToast:self clickedButtonAtIndex:sender.tag];

	[UIView animateWithDuration:0.15f
					 animations:^{
						 self.alpha = 0.f;
					 } completion:^(BOOL finished) {
						 [self removeFromSuperview];
					 }];
}

+(NSInteger)customToastBigButton{
    return 1;
}

+(NSInteger)customToastSmallButton{
    return 2;
}

-(void)dismissToast
{
    [self removeFromSuperview];
}

@end
