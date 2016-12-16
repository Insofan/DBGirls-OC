//
//  GorgeousCollectionViewCell.m
//  DBGorgeous
//
//  Created by 海啸 on 2016/12/4.
//  Copyright © 2016年 海啸. All rights reserved.
//

#import "GorgeousCollectionViewCell.h"
#import <Masonry.h>
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
@implementation GorgeousCollectionViewCell

#pragma mark UI
//懒加载imageView
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        
    }
    return _imageView;
}

//Setup imageView
- (void)setupImageView {
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self);
        make.width.height.mas_equalTo(self);
    }];
}
//设置图片

- (void)setCellImageWith:(Gorgeous *)gorgeous {
    NSURL *url = [NSURL URLWithString:gorgeous.src];
    [self.imageView setImageWithURL:url placeholderImage:nil usingActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
}

#pragma mark: Init
//Init GorgeousCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImageView];
    }
    return  self;
}


@end
