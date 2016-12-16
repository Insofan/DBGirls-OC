//
//  GorgeousCollectionViewController.m
//  DBGorgeous
//
//  Created by 海啸 on 2016/12/4.
//  Copyright © 2016年 海啸. All rights reserved.
//

#import "GorgeousCollectionViewController.h"
#import "GorgeousCollectionViewCell.h"
#import "Gorgeous.h"
#import <Masonry.h>
#import <JGProgressHUD.h>
#import <AFNetworking.h>
#import <Ono.h>
#import <MJExtension.h>
#import <MJRefresh.h>
#import "SDPhotoBrowser.h"
@interface GorgeousCollectionViewController ()<SDPhotoBrowserDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (assign, nonatomic) NSUInteger type;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSMutableArray <Gorgeous *> *gorgeousUrlsArray;
@property (strong, nonatomic) AFHTTPSessionManager *manager;


@end

@implementation GorgeousCollectionViewController

static NSString  *reuseIdentifier = @"Cell";
#pragma mark: Property
//NSMutableArray

- (NSMutableArray *)gorgeousUrlsArray {
    
    if (!_gorgeousUrlsArray) {
        _gorgeousUrlsArray = [[NSMutableArray alloc] init];
    }

    return _gorgeousUrlsArray;
}

#pragma mark: UI
//ScrollView And Button
//Set ScrollView

- (void)setScrollView {
    NSArray *buttonArray = @[@"所有", @"大胸妹",@"美腿控",@"有颜值",@"黑丝袜",@"小翘臀",@"大杂烩"];
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 35)];
    
    for (int i = 0; i < buttonArray.count; i++)
    {
        CGFloat btnX = i * titleView.bounds.size.width / buttonArray.count;
        CGFloat btnW = titleView.bounds.size.width / buttonArray.count;
        UIButton  *btn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, 0, btnW, 35)];
        btn.tag = i ;
        [btn setTitle:buttonArray[i] forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        titleView.backgroundColor =  [UIColor grayColor];
        
        [btn addTarget:self action:@selector(typeWith:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:btn];
    }
    [self.view addSubview: titleView];
}

//button的响应

- (void)typeWith:(UIButton *)sender {
    //当时写了个dispatch_sync(dispatch_get_main_queue()死锁！！！
    NSInteger tag = sender.tag;
    NSArray *buttonArray = @[@"所有", @"大胸妹",@"美腿控",@"有颜值",@"黑丝袜",@"小翘臀",@"大杂烩"];
    self.navigationItem.title = buttonArray[tag];
    /*
     All     = 0,
     DaXiong = 2,
     QiaoTun = 6,
     HeiSi   = 7,
     MeiTui  = 3,
     YanZhi  = 4,
     ZaHui   = 5,
     */
    switch (tag) {
        case  0:
            self.type = 0;
            break;
        case 1:
            self.type = 2;
            break;
        case 2:
            self.type = 3;
            break;
        case 3:
            self.type = 4;
            break;
        case 4:
            self.type = 7;
            break;
        case 5:
            self.type = 6;
            break;
        default:
            
            self.type = 5;
    }
    dispatch_sync(dispatch_queue_create(0, NULL), ^{
        
        [self.gorgeousUrlsArray removeAllObjects];
        [self.collectionView reloadData];
        
        [self.collectionView.mj_header beginRefreshing];
        [self loadGoregeousWith:self.type];
        
    });
}

//FlowLayout

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 94, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout: self.layout];
        [_collectionView registerClass:[GorgeousCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _collectionView;
}

//Set CollectionView

- (void)setCollectionView {
    [self.view addSubview:self.collectionView];
}

#pragma mark:view生命周期

//MjHeader And Footer

- (void)setRefresh {
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.collectionView.mj_header.automaticallyChangeAlpha = true;
        [self loadGoregeousWith:0];
    }];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self.collectionView.mj_footer beginRefreshing];
        self.collectionView.mj_footer.automaticallyChangeAlpha = true;
        [self loadNextPageWith:self.page];
    }];
    [self.collectionView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setScrollView];
    [self setCollectionView];
    [self setRefresh];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"所有";
    
}

#pragma mark:Collection Delegate & DataSources
//Collection Delegate & DataSources

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSMutableArray *array;
    
    if ((array = self.gorgeousUrlsArray) ) {
        return self.gorgeousUrlsArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GorgeousCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell setCellImageWith:self.gorgeousUrlsArray[indexPath.row]];
    cell.backgroundColor = [UIColor grayColor];
    
    return cell;
}

// Photo Browser

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SDPhotoBrowser *photoBrowser = [[SDPhotoBrowser alloc] init];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = indexPath.item;
    photoBrowser.imageCount = self.gorgeousUrlsArray.count;
    photoBrowser.sourceImagesContainerView = self.collectionView;
    photoBrowser.titleLabel.text = self.gorgeousUrlsArray[indexPath.row].title;
    [photoBrowser show];
    
}

//Photo Browser Delegate

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    GorgeousCollectionViewCell *cell = (GorgeousCollectionViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    return cell.imageView.image;
}

#pragma mark:Collection Flowlayout Delegate & DataSources
//Collection flowlayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.bounds.size.width - 30)/2, (self.view.bounds.size.height - 30)/3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

#pragma mark:HTTP Request And Load Gorgeous Data

//AFHTTPSessionManager 部分
-(AFHTTPSessionManager *)manager
{
    if (_manager == nil)
    {
        NSString * randomUserAgent = ({
            
            NSArray * userAgents = @[@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36",
                                     @"Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36",
                                     @"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:36.0) Gecko/20100101 Firefox/36.0",
                                     @"Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36",
                                     @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27"];
            
            randomUserAgent =  userAgents[arc4random() % userAgents.count];
            randomUserAgent;
            
        });
        
        _manager =({
            _manager =  [[AFHTTPSessionManager alloc]init];
            
            _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
            _manager;
        });
        
        [_manager.requestSerializer setValue:randomUserAgent forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

//Set Http Error HUD

- (void)setErrorHUD {
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"加载错误";
    HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init]; //JGProgressHUDSuccessIndicatorView is also available
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:3.0];
}

//Get Gorgeous Url
- (void)loadGoregeousWith:(NSInteger )type {
    
    NSString *url =  [NSString stringWithFormat:@"http://www.dbmeinv.com/dbgroup/show.htm?cid=%ld&pager_offset=1", type];
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         
         NSLog(@"%0.2f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"sucess");
         //取回xml
         NSData *data = responseObject;
         //开始用ono解析
         ONOXMLDocument *ulDoc = [ONOXMLDocument XMLDocumentWithData:data error:nil];
         //取回所有的ul节点
         [ulDoc enumerateElementsWithXPath:@"//*[@id=\"main\"]/div[2]/div[2]/ul" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
             //找出element的个数
             NSInteger count = element.children.count;
             
             for (int i = 0; i < count; i++) {
                 //idx is 0
                 NSString *img = [NSString stringWithFormat:@"//li[%d]/div/div[1]/a/img", i+1];
                 ONOXMLElement *imgElement = [element firstChildWithXPath:img];
                 Gorgeous *gorgeousUrl = [Gorgeous mj_objectWithKeyValues:imgElement.attributes];
                 /*
                  解决self.gorgeousUrls 没有添加gorgeousUrl因为使用NSMutable需要提前懒加载
                  */
                 [self.gorgeousUrlsArray addObject:gorgeousUrl];
             }
             self.page = 1;
             [self.collectionView.mj_header endRefreshing];
             [self.collectionView reloadData];
         }];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         NSLog(@"%@",error.localizedDescription);
         [self.collectionView.mj_header endRefreshing];
         [self setErrorHUD];
     }];

}
//Got Next Page

- (void)loadNextPageWith:(NSInteger )type {
    
    NSString *url =  [NSString stringWithFormat:@"http://www.dbmeinv.com/dbgroup/show.htm?cid=%ld&pager_offset=%ld", type,self.page + 1];
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         
         NSLog(@"%0.2f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"sucess");
         //取回xml
         NSData *data = responseObject;
         //开始用ono解析
         ONOXMLDocument *ulDoc = [ONOXMLDocument XMLDocumentWithData:data error:nil];
         //取回所有的ul节点
         [ulDoc enumerateElementsWithXPath:@"//*[@id=\"main\"]/div[2]/div[2]/ul" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
             //找出element的个数
             NSInteger count = element.children.count;
             
             for (int i = 0; i < count; i++) {
                 //idx is 0
                 NSString *img = [NSString stringWithFormat:@"//li[%d]/div/div[1]/a/img", i+1];
                 ONOXMLElement *imgElement = [element firstChildWithXPath:img];
                 Gorgeous *gorgeousUrl = [Gorgeous mj_objectWithKeyValues:imgElement.attributes];
                 /*
                  解决self.gorgeousUrls 没有添加gorgeousUrl因为使用NSMutable需要提前懒加载
                  */
                 [self.gorgeousUrlsArray addObject:gorgeousUrl];
             }
             self.page += 1;
             [self.collectionView reloadData];
             [self.collectionView.mj_footer endRefreshing];
             
         }];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         NSLog(@"%@",error.localizedDescription);
         [self.collectionView.mj_footer endRefreshing];
         [self setErrorHUD];
     }];
    
}


@end
