//
//  BKScanCardViewController.m
//  BESTKEEP
//
//  Created by 毛韶谦 on 16/6/20.
//  Copyright © 2016年 YISHANG. All rights reserved.
//

#import "MSQScanCardViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import "CJCategory.h"
#import <LBProgressHUD/LBProgressHUD.h>

#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width

#define COLOR_14 [UIColor fromHexValue:0x03B598] //BESTKEEP绿

@interface MSQScanCardViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, assign) BOOL isReading;

// 捕捉会话 捕捉外界信息，并将信息呈现在手机上
@property(nonatomic, retain) AVCaptureSession *captureSession;

//@property (nonatomic, strong) AVCaptureDevice *Device;

// 用来展示捕捉到的外界信息
@property(nonatomic, retain) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) UIView *saoView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) UIButton *Button;

@property (nonatomic, strong) UIImageView *line;//交互线

@property (nonatomic, strong) CAShapeLayer * shadowLayer; //阴影层；

@property (nonatomic, strong) UILabel *markLabel;  //提示语标签；

@property (nonatomic, strong) NSTimer *timer;  //定时器；

@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@property (nonatomic, strong)  AVCaptureDeviceInput *input;

@end

@implementation MSQScanCardViewController

#pragma mark ----------懒加载，防止重复创建-----------
- (UIView *)saoView {
    
    if (!_saoView) {
        _saoView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH/6, IPHONE_HEIGHT/4, IPHONE_WIDTH/3*2, IPHONE_WIDTH/3*2)];
        
        [self.view addSubview:_saoView];
    }
    return _saoView;
}
- (CAShapeLayer *)shadowLayer {
    
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds].CGPath;
        _shadowLayer.fillColor = [UIColor grayColor].CGColor;
        _shadowLayer.opacity = 0.3;
        _shadowLayer.mask = [self generateMaskLayerWithRect:[UIScreen mainScreen].bounds exceptRect:self.saoView.frame];
    }
    return _shadowLayer;
}
- (UILabel *)markLabel {
    
    if (!_markLabel) {
        _markLabel = [[UILabel alloc] init];
        [self.view addSubview:_markLabel];
        _markLabel.textColor = [UIColor whiteColor];
        [_markLabel setTextAlignment:NSTextAlignmentCenter];
        [_markLabel setFont:[UIFont systemFontOfSize:14]];
        [_markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(self.saoView.mas_centerX);
            make.bottom.mas_equalTo(self.saoView.mas_top).mas_offset(-10);
            make.width.mas_equalTo(self.saoView.mas_width);
            make.height.mas_equalTo(@20);
        }];
    }
    return _markLabel;
}
- (NSTimer *)timer {
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(moveScanLayer) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (UIImageView *)line {
    
    if (!_line) {
        //画中间的基准线
        _line = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH/6+5, IPHONE_HEIGHT/4, IPHONE_WIDTH/3*2-10, 12)];
        [_line setImage:[UIImage imageNamed:@"QRCodeLine"]];
//        _line.backgroundColor = COLOR_14;
    }
    return _line;
}

- (AVCaptureDeviceInput *)input {  //  1
    
    if (!_input) {
        //用Device创建输入流  捕捉完结内容 到设备中 也就是手机
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice: device error: nil];
    }
    return _input;
}
-(AVCaptureMetadataOutput *)output {   //  2
    
    if (!_output) {
        //创建媒体数据输出流
        _output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理来处理输出流中的信息
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _output.rectOfInterest = CGRectMake(0.1, 0.1, 0.8, 0.8);
        
    }
    return _output;
}
- (AVCaptureSession *)captureSession {   //  3
    
    if (!_captureSession) {
        // 4.   实例化捕捉绘画
        _captureSession = [[AVCaptureSession alloc] init];
        
        // 4.1  设置绘画的采集率 属性 决定了
        [_captureSession setSessionPreset:AVCaptureSessionPreset3840x2160];
    }
    return _captureSession;
}
-(AVCaptureVideoPreviewLayer *)videoPreviewLayer {   //   4
    
    if (!_videoPreviewLayer) {
        //实例化
        _videoPreviewLayer  = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        //设置预览图层的frame
        _videoPreviewLayer.frame = self.view.frame;
    }
    return _videoPreviewLayer;
}
- (UIView *)boxView {
    
    if (!_boxView) {
        //  6.1.扫描框
        _boxView = [[UIView alloc] initWithFrame:self.saoView.frame];
        _boxView.layer.borderColor = COLOR_14.CGColor;
        _boxView.layer.borderWidth = 1.0f;
    }
    return _boxView;
}


#pragma mark -------视图生命周期---------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.saoView.backgroundColor = [UIColor clearColor];
    self.saoView.alpha = 1;
    self.navigationItem.title = @"扫一扫";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //是导航栏透明；
    self.navigationController.navigationBar.translucent = YES;
    UIColor *color = [UIColor clearColor];
    CGRect rect = CGRectMake(0, 0, IPHONE_WIDTH, 64);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFillRect(contextRef, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"灯光" style:UIBarButtonItemStylePlain target:self action:@selector(openLight)];
    //UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    //添加按钮到BarButton
    _Button = [UIButton buttonWithType:UIButtonTypeSystem];
    [_Button setTitle:@"开灯" forState:UIControlStateNormal];
    [_Button setTitle:@"关灯" forState:UIControlStateSelected];
    [_Button addTarget:self action:@selector(openLight:) forControlEvents:UIControlEventTouchUpInside];
    _Button.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_Button];
    [_Button mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.saoView.mas_bottom).mas_offset(30);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.saoView.mas_width).multipliedBy(0.6);
        make.height.mas_equalTo(@30);
    }];
    _Button.hidden = YES;
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isReading = NO;
    if ([self startReading]) {
        
        [LBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.view.layer addSublayer:self.shadowLayer];
        //  6.2.扫描线
        [self.view addSubview:self.line];
        [self.timer setFireDate:[NSDate distantPast]];
        self.markLabel.text = @"对准二维码到框内即可扫描";
        self.view.layer.masksToBounds = YES;
        _Button.hidden = NO;
    }else {
        
        [LBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self alertViewWithMessage:@"请打开摄像头" title:@"友情提示" object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LBProgressHUD showHUDto:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---------方法-----------

- (void)alertViewWithMessage:(NSString *)message title:(NSString *)title object:(AVMetadataMachineReadableCodeObject *)object{
    
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        if ([message isEqualToString:@"请打开摄像头"]) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    UIAlertAction *alertOpenAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([message isEqualToString:@"请打开摄像头"]) {
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:object.stringValue]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertC addAction:alertAction];
    [alertC addAction:alertOpenAction];
    [self presentViewController:alertC animated:YES completion:nil];
    
}

- (BOOL)startReading{
    
    if ([self setupIODevice]) {
        
    }else {
        
        return NO;
    }
    
    [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    [self.view addSubview:self.boxView];
    //设置图层内容的填充防腐蚀
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //开始扫描
    [self.captureSession startRunning];
    return YES;
    
}

#pragma mark - setup
/**
 *  配置输入输出设置
 */
- (BOOL)setupIODevice
{
    if ([self.captureSession canAddInput: self.input]) {
        //将输入流添加到绘画
        [_captureSession addInput: _input];
        
        if ([self.captureSession canAddOutput: self.output]) {
            //将输出流添加到绘画
            [_captureSession addOutput: _output];
            //设置媒体数据类型 二维码和条形码
            _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code];
            
            return YES;
            
        }else {
            
             return NO;
        }
    }else {
        
        return NO;
    }
    
}

/**
 *  @param captureOutput                输出流
 *  @param didOutputMetadataObjects     信息在哪存储
 *  @param connection
 */

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //处理捕捉到的内容
    if ([metadataObjects count]>0&&metadataObjects !=nil) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects objectAtIndex:0];
        if ([[object type] isEqualToString:AVMetadataObjectTypeQRCode] |  [[object type] isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            
            NSString *urlStr = [object stringValue];
            if ([urlStr hasPrefix:@"http"]) {
                
                [self alertViewWithMessage:urlStr title:@"可能存在风险，是否打开" object:object];
                
            }else {
                
                //                GoodsDetailController  *goodsDetailVc = [[GoodsDetailController alloc]init];
                //                // goodsDetailVc.goods_Id = [object stringValue];
                //                goodsDetailVc.goods_Id = @"Ujyug0u7QzegugYW0QALqw";
                //                [self.navigationController  pushViewController:goodsDetailVc  animated:YES];
                //
                //                [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            }
            
        }
    }
}

- (void)stopReading{
    //结束扫描
    [self.captureSession stopRunning];
}

- (void)moveScanLayer {
    
    __block CGRect frame = self.line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = IPHONE_HEIGHT/4;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 10;
            self.line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (self.line.frame.origin.y >= IPHONE_HEIGHT/4)
        {
            if (self.line.frame.origin.y >= IPHONE_HEIGHT/4+IPHONE_WIDTH/3*2 - 15)
            {
                frame.origin.y = IPHONE_HEIGHT/4;
                self.line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 10;
                    self.line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
    
}

//打开或关闭闪光灯
- (void)openLight:(UIButton *)sender {
    
    //用Device创建输入流  捕捉完结内容 到设备中 也就是手机
    AVCaptureDevice * Device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if (_isReading) {
        
        if ([Device hasTorch]) {
            
            [Device lockForConfiguration:nil];
            [Device setTorchMode:AVCaptureTorchModeOff];
            [Device unlockForConfiguration];
            sender.selected = NO;
        }
    }else {
        
        if ([Device hasTorch]) {
            
            [Device lockForConfiguration:nil];
            [Device setTorchMode:AVCaptureTorchModeOn];
            [Device unlockForConfiguration];
            sender.selected = YES;
        }
    }
    _isReading = !_isReading;
}

//生成空缺layer 层；
- (CAShapeLayer *)generateMaskLayerWithRect: (CGRect)rect exceptRect: (CGRect)exceptRect {
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        
        return nil;
    }
    else if (CGRectEqualToRect(exceptRect, CGRectZero)) {
        maskLayer.path = [UIBezierPath bezierPathWithRect: rect].CGPath;
        return maskLayer;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    
    /** 添加路径*/
    UIBezierPath * path = [UIBezierPath bezierPathWithRect: CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
