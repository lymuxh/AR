//
//  SelectableButton.m
//  AR3DCustomerDemo
//
//  Created by muxiaohui on 2017/11/7.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import "SelectableButton.h"

@implementation SelectableButton

-(void)setSelected:(BOOL)selected{
    
    if (selected) {
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.borderWidth = 3;
    }else{
        self.layer.borderWidth = 0;
    }
}

@end
