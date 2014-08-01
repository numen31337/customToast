//
//  PrintstaCustomToast.h
//  Printsta
//
//  Created by Oleksandr Kirichenko on 11/21/13.
//  Copyright (c) 2013 Artem Myagkov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PrintstaCustomToast;

@protocol PrintstaCustomToastProtocol
@required
-(void)customToast:(PrintstaCustomToast*)customView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface PrintstaCustomToast : UIView
+(NSInteger)customToastBigButton;
+(NSInteger)customToastSmallButton;

-(PrintstaCustomToast*)initWithTitle:(NSString*)toastTitle
      titleImageName:(NSString*)toastTitleImageName
             message:(NSString*)toastMessage
      bigButtonTitle:(NSString*)bigButtonTitle
  bigButtonImageName:(NSString*)bigButtonImageName
    smallButtonTitle:(NSString*)smallButtonTitle
smallButtonImageName:(NSString*)smallButtonImageName
invertButtonLabelsColors:(BOOL)invert
            delegate:(id <PrintstaCustomToastProtocol>)delegate;

@property (readwrite, strong) NSString *toastId;
@property (weak) id <PrintstaCustomToastProtocol> delegate;
@property (assign, nonatomic) BOOL isAnimating;

-(void)startAnimation;
-(void)stopAnimation;
-(void)makeButtonsWithBigButtonTitle:(NSString*)bigButtonTitle
                  bigButtonImageName:(NSString*)bigButtonImageName
                    smallButtonTitle:(NSString*)smallButtonTitle
                smallButtonImageName:(NSString*)smallButtonImageName
            invertButtonLabelsColors:(BOOL)invert;
-(void)removeButtons;
-(void)dismissToast;
-(void)setTitleImageNamed:(NSString*)toastTitleImageName;
-(NSString*)title;
-(void)setTitle:(NSString*)toastTitle;
-(void)setMessage:(NSString*)toastMessage;
-(void)setAttriburedMessage:(NSAttributedString*)attributedMessage;
@end