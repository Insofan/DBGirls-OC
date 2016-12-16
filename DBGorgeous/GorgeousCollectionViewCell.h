//
//  GorgeousCollectionViewCell.h
//  DBGorgeous
//
//  Created by 海啸 on 2016/12/4.
//  Copyright © 2016年 海啸. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gorgeous.h"

@interface GorgeousCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;

- (void)setCellImageWith:(Gorgeous *)gorgeous;
@end
