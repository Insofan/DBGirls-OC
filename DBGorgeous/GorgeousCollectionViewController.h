//
//  GorgeousCollectionViewController.h
//  DBGorgeous
//
//  Created by 海啸 on 2016/12/4.
//  Copyright © 2016年 海啸. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GorgeousCollectionViewController : UIViewController  <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@end
