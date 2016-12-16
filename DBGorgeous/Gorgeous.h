//
//  Gorgeous.h
//  DBGorgeous
//
//  Created by 海啸 on 2016/12/6.
//  Copyright © 2016年 海啸. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GorgeousCategory;
//typedef NS_ENUM(NSInteger, Category) {
//    All     = 0,
//    DaXiong = 2,
//    QiaoTun = 6,
//    HeiSi   = 7,
//    MeiTui  = 3,
//    YanZhi  = 4,
//    ZaHui   = 5,
//    
//};
@interface Gorgeous : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *src;
@end
