
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@import ServiceCore;
@import ServiceChat;

@interface SalesforceChatModule : NSObject <RCTBridgeModule>
@end
