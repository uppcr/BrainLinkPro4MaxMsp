#import "ReciveViewController.h"
#import "Blue4Manager.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

typedef enum : NSUInteger {
    SIGNAL_STATE_NOSIGNAL = 0,
    SIGNAL_STATE_WEAK,
    SIGNAL_STATE_GENERAL,
    SIGNAL_STATE_GOOD,
    SIGNAL_STATE_VERYGOOD
} SignalState;

@interface ReciveViewController () {
    NSMutableArray *rawDataBuffer;
    int lastEyeblinkValue;
    SignalState signalState;
    int baseCount;
    BOOL isAcceptable4;

    int lastXValue;
    int lastYValue;
    int lastZValue;
}

@property (weak) IBOutlet NSView *signalview;
@property (weak) IBOutlet NSTextField *rawLabel;
@property (weak) IBOutlet NSTextField *eyeblinkLabel;
@property (weak) IBOutlet NSTextField *electricityLabel;
@property (weak) IBOutlet NSTextField *attentionlabel;
@property (weak) IBOutlet NSTextField *medlabel;
@property (weak) IBOutlet NSTextField *favrouteRateLabel;
@property (weak) IBOutlet NSTextField *circleRateLabel;
@property (weak) IBOutlet NSTextField *otherLabel;
@property (strong) NSImageView *signalImageView;
@property (strong) NSImageView *signalInstructions;

@end

@implementation ReciveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self.view setNeedsDisplay:YES];
    
    rawDataBuffer = [NSMutableArray array];
    lastEyeblinkValue = -1;
    lastXValue = -1;
    lastYValue = -1;
    lastZValue = -1;
    
    [Blue4Manager logEnable:YES];
    [[Blue4Manager shareInstance] configureBlueNames:@[@"BrainLink_Pro"] ableDeviceSum:1];
    __weak ReciveViewController *weakSelf = self;
    
    [Blue4Manager shareInstance].blueConBlock = ^(NSString *markKey) {
        NSLog(@"Bluetooth connected");
    };
    
    [Blue4Manager shareInstance].blueDisBlock = ^(NSString *markKey) {
        weakSelf.signalImageView.image = [NSImage imageNamed:@"noSignal"];
        weakSelf.rawLabel.stringValue = @"";
        weakSelf.eyeblinkLabel.stringValue = @"";
        weakSelf.electricityLabel.stringValue = @"";
        weakSelf.attentionlabel.stringValue = @"";
        weakSelf.medlabel.stringValue = @"";
        weakSelf.favrouteRateLabel.stringValue = @"";
        weakSelf.circleRateLabel.stringValue = @"";
        weakSelf.otherLabel.stringValue = @"";
        NSLog(@"Bluetooth disconnected");
    };
    
    [Blue4Manager shareInstance].hzlblueDataBlock_A = ^(HZLBlueData *hzlBlueData, BlueType conBT, BOOL isFalseCon) {
        
        if (hzlBlueData.bleDataType == BLEMIND) {
            weakSelf.attentionlabel.stringValue = [NSString stringWithFormat:@"Attention: %d", hzlBlueData.attention];
            weakSelf.medlabel.stringValue = [NSString stringWithFormat:@"Meditation: %d", hzlBlueData.meditation];
            weakSelf.electricityLabel.stringValue = [NSString stringWithFormat:@"Battery: %d", hzlBlueData.batteryCapacity];
            weakSelf.favrouteRateLabel.stringValue = [NSString stringWithFormat:@"Favrate: %d", hzlBlueData.ap];
            weakSelf.otherLabel.stringValue = [NSString stringWithFormat:@"Brainwave: Delta:%d Theta:%d LowAlpha:%d HighAlpha:%d LowBeta:%d HighBeta:%d LowGamma:%d HighGamma:%d", hzlBlueData.delta, hzlBlueData.theta, hzlBlueData.lowAlpha, hzlBlueData.highAlpha, hzlBlueData.lowBeta, hzlBlueData.highBeta, hzlBlueData.lowGamma, hzlBlueData.highGamma];
            
            NSArray *brainwaveData = @[
                @(hzlBlueData.signal),
                @(hzlBlueData.batteryCapacity),
                hzlBlueData.grind,
                @([hzlBlueData.temperature floatValue]),
                hzlBlueData.heartRate,
                @(hzlBlueData.attention),
                @(hzlBlueData.meditation),
                @(hzlBlueData.ap),
                @(hzlBlueData.delta),
                @(hzlBlueData.theta),
                @(hzlBlueData.lowAlpha),
                @(hzlBlueData.highAlpha),
                @(hzlBlueData.lowBeta),
                @(hzlBlueData.highBeta),
                @(hzlBlueData.lowGamma),
                @(hzlBlueData.highGamma),
            ];
            [weakSelf sendOSCMessageWithAddress:@"/brainwave" andArguments:brainwaveData onPort:11123];
            
        } else if (hzlBlueData.bleDataType == BLEGRAVITY) {
            int currentXValue = hzlBlueData.xvlaue;
            int currentYValue = hzlBlueData.yvlaue;
            int currentZValue = hzlBlueData.zvlaue;

            if (currentXValue != self->lastXValue) {
                [self sendOSCMessageWithAddress:@"/x" andArguments:@[@(currentXValue)] onPort:11126];
                self->lastXValue = currentXValue;
            }
            
            if (currentYValue != self->lastYValue) {
                [self sendOSCMessageWithAddress:@"/y" andArguments:@[@(currentYValue)] onPort:11127];
                self->lastYValue = currentYValue;
            }
            
            if (currentZValue != self->lastZValue) {
                [self sendOSCMessageWithAddress:@"/z" andArguments:@[@(currentZValue)] onPort:11128];
                self->lastZValue = currentZValue;
            }
        } else if (hzlBlueData.bleDataType == BLERaw) {
            weakSelf.rawLabel.stringValue = [NSString stringWithFormat:@"Raw: %d Blink: %d", hzlBlueData.raw, hzlBlueData.blinkeye];
            [self->rawDataBuffer addObject:@(hzlBlueData.raw)];
            
            if (self->rawDataBuffer.count >= 10) {
                [self sendOSCMessageWithAddress:@"/sensordataraw" andArguments:self->rawDataBuffer onPort:11124];
                [self->rawDataBuffer removeAllObjects];
            }
            
            if (hzlBlueData.blinkeye != self->lastEyeblinkValue) {
                int eyeblinkValue = hzlBlueData.blinkeye;
                weakSelf.eyeblinkLabel.stringValue = [NSString stringWithFormat:@"Eyeblink: %d", eyeblinkValue];
                NSArray *eyeblinkData = @[@(eyeblinkValue)];
                [self sendOSCMessageWithAddress:@"/eyeblink" andArguments:eyeblinkData onPort:11125];
                self->lastEyeblinkValue = eyeblinkValue;
            }
        }
    };

    [[Blue4Manager shareInstance] connectBlue4];
}

- (void)sendOSCMessageWithAddress:(NSString *)address andArguments:(NSArray *)arguments onPort:(int)port {
    NSMutableData *data = [NSMutableData data];
    
    // 添加地址并确保4字节对齐
    NSData *addressData = [address dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:addressData];
    NSUInteger paddingLength = 4 - (data.length % 4);
    if (paddingLength != 4) {
        [data appendBytes:"\0\0\0\0" length:paddingLength];
    }
    
    // 动态生成类型标记
    NSMutableString *typeTag = [NSMutableString stringWithString:@","];
    for (id argument in arguments) {
        [typeTag appendString:[argument isKindOfClass:[NSNumber class]] ? @"f" : @"s"];
    }
    NSData *typeTagData = [typeTag dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:typeTagData];
    paddingLength = 4 - (data.length % 4);
    if (paddingLength != 4) {
        [data appendBytes:"\0\0\0\0" length:paddingLength];
    }
    
    // 添加参数数据，并确保每个数据按4字节对齐
    for (NSNumber *argument in arguments) {
        float value = [argument floatValue];
        uint32_t networkValue;
        memcpy(&networkValue, &value, sizeof(value)); // 将浮点值复制为二进制
        networkValue = htonl(networkValue); // 转换为网络字节顺序
        [data appendBytes:&networkValue length:sizeof(networkValue)];
    }
    
    // 配置 UDP 套接字
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in servaddr;
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(port);
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    
    sendto(sockfd, [data bytes], [data length], 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
    close(sockfd);
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewController:self];
}

@end
