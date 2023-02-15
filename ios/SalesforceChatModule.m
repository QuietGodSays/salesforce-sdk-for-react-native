#import "SalesforceChatModule.h"

@implementation SalesforceChatModule

NSMutableArray *chatUserData;
NSMutableArray *chatEntities;
SCSChatConfiguration *chatConfiguration;

NSString* ChatSessionStateChanged = @"ChatSessionStateChanged";
NSString* ChatSessionEnd = @"ChatSessionEnd";

NSString* Connecting = @"Connecting";
NSString* Queued = @"Queued";
NSString* Connected = @"Connected";
NSString* Ending = @"Ending";
NSString* Disconnected = @"Disconnected";

NSString* EndReasonUser = @"EndReasonUser";
NSString* EndReasonAgent = @"EndReasonAgent";
NSString* EndReasonNoAgentsAvailable = @"EndReasonNoAgentsAvailable";
NSString* EndReasonTimeout = @"EndReasonTimeout";
NSString* EndReasonSessionError = @"EndReasonSessionError";

NSString* BrandPrimary = @"BrandPrimary";
NSString* BrandSecondary = @"BrandSecondary";
NSString* BrandSecondaryInverted = @"BrandSecondaryInverted";
NSString* ContrastPrimary = @"ContrastPrimary";
NSString* ContrastQuaternary = @"ContrastQuaternary";
NSString* ContrastInverted = @"ContrastInverted";
NSString* NavbarBackground = @"NavbarBackground";
NSString* NavbarInverted = @"NavbarInverted";

NSArray *colorTokens = @[
        BrandPrimary,
        BrandSecondary,
        BrandSecondaryInverted,
        ContrastPrimary,
        ContrastQuaternary,
        ContrastInverted,
        NavbarBackground,
        NavbarInverted
];

// To export a module named SalesforceChatModule
RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSDictionary *)constantsToExport
{
  return @{
      ChatSessionStateChanged:ChatSessionStateChanged,
      ChatSessionEnd: ChatSessionEnd,
      Connecting: Connecting,
      Queued: Queued,
      Connected: Connected,
      Ending: Ending,
      Disconnected: Disconnected,
      EndReasonUser: EndReasonUser,
      EndReasonAgent: EndReasonAgent,
      EndReasonNoAgentsAvailable: EndReasonNoAgentsAvailable,
      EndReasonTimeout: EndReasonTimeout,
      EndReasonSessionError: EndReasonSessionError,
      BrandPrimary: BrandPrimary,
      BrandSecondary: BrandSecondary,
      BrandSecondaryInverted: BrandSecondaryInverted,
      ContrastPrimary: ContrastPrimary,
      ContrastQuaternary: ContrastQuaternary,
      ContrastInverted: ContrastInverted,
      NavbarBackground: NavbarBackground,
      NavbarInverted: NavbarInverted,
  };
}

//MARK: Public Methods
RCT_EXPORT_METHOD(initializePreChatUserData)
{
    chatUserData = [[NSMutableArray alloc] init];

    SCSPrechatTextInputObject* firstName = [[SCSPrechatTextInputObject alloc] initWithLabel:@"First Name"];
    firstName.required = YES;
    [chatUserData addObject:firstName];

    SCSPrechatTextInputObject* lastName = [[SCSPrechatTextInputObject alloc] initWithLabel:@"Last Name"];
    lastName.required = YES;
    [chatUserData addObject:lastName];

    SCSPrechatTextInputObject* email = [[SCSPrechatTextInputObject alloc] initWithLabel:@"Email"];
    email.required = YES;
    email.keyboardType = UIKeyboardTypeEmailAddress;
    [chatUserData addObject:email];

    SCSPrechatObject* subject = [[SCSPrechatObject alloc] initWithLabel:@"Subject" value:@"Chat Conversation"];
    subject.displayToAgent = NO;
    [chatUserData addObject:subject];

    SCSPrechatObject* origin = [[SCSPrechatObject alloc] initWithLabel:@"Origin" value:@"Mobile App"];
    origin.displayToAgent = NO;
    [chatUserData addObject:origin];

    chatEntities = [[NSMutableArray alloc] init];

    SCSPrechatEntityField* subjectEntityField = [[SCSPrechatEntityField alloc]
                                                    initWithFieldName:@"Subject" label:@"Subject"];
    subjectEntityField.doFind = NO;
    subjectEntityField.doCreate = YES;
    subjectEntityField.isExactMatch = NO;

    SCSPrechatEntityField* originEntityField = [[SCSPrechatEntityField alloc]
                                                    initWithFieldName:@"Origin" label:@"Origin"];
    originEntityField.doFind = NO;
    originEntityField.doCreate = YES;
    originEntityField.isExactMatch = NO;

    SCSPrechatEntity* caseEntity = [[SCSPrechatEntity alloc] initWithEntityName:@"Case"];
    caseEntity.saveToTranscript = @"Case";
    caseEntity.showOnCreate = YES;
    [caseEntity.entityFieldsMaps addObject:subjectEntityField];
    [caseEntity.entityFieldsMaps addObject:originEntityField];

    SCSPrechatEntityField* firstNameEntityField = [[SCSPrechatEntityField alloc]
                                                    initWithFieldName:@"FirstName" label:@"First Name"];
    firstNameEntityField.doFind = YES;
    firstNameEntityField.doCreate = NO;
    firstNameEntityField.isExactMatch = YES;

    SCSPrechatEntityField* lastNameEntityField = [[SCSPrechatEntityField alloc]
                                                    initWithFieldName:@"LastName" label:@"Last Name"];
    lastNameEntityField.doFind = YES;
    lastNameEntityField.doCreate = NO;
    lastNameEntityField.isExactMatch = YES;

    SCSPrechatEntityField* emailEntityField = [[SCSPrechatEntityField alloc]
                                                initWithFieldName:@"Email" label:@"Email"];
    emailEntityField.doFind = YES;
    emailEntityField.doCreate = NO;
    emailEntityField.isExactMatch = YES;

    SCSPrechatEntity* contactEntity = [[SCSPrechatEntity alloc] initWithEntityName:@"Contact"];
    contactEntity.saveToTranscript = @"Contact";
    contactEntity.showOnCreate = YES;
    contactEntity.linkToEntityName = @"Case";
    contactEntity.linkToEntityField = @"ContactId";
    [contactEntity.entityFieldsMaps addObject:firstNameEntityField];
    [contactEntity.entityFieldsMaps addObject:lastNameEntityField];
    [contactEntity.entityFieldsMaps addObject:emailEntityField];

    SCSPrechatEntityField* personEmailEntityField = [[SCSPrechatEntityField alloc]
                                                    initWithFieldName:@"PersonEmail" label:@"Email"];
    personEmailEntityField.doFind = YES;
    personEmailEntityField.doCreate = NO;
    personEmailEntityField.isExactMatch = YES;

    SCSPrechatEntity* accountEntity = [[SCSPrechatEntity alloc] initWithEntityName:@"Account"];
    accountEntity.saveToTranscript = @"Account";
    accountEntity.showOnCreate = YES;
    [accountEntity.entityFieldsMaps addObject:firstNameEntityField];
    [accountEntity.entityFieldsMaps addObject:lastNameEntityField];
    [accountEntity.entityFieldsMaps addObject:personEmailEntityField];

    [chatEntities addObject:caseEntity];
    [chatEntities addObject:contactEntity];
    [chatEntities addObject:accountEntity];
}

RCT_EXPORT_METHOD(configureChat:(NSString *)orgId buttonId:(NSString *)buttonId deploymentId:(NSString *)deploymentId
                  liveAgentPod:(NSString *)liveAgentPod visitorName:(NSString *)visitorName)
{
    chatConfiguration = [[SCSChatConfiguration alloc] initWithLiveAgentPod:liveAgentPod orgId:orgId
                                                              deploymentId:deploymentId buttonId:buttonId];

    if (visitorName != nil) {
        chatConfiguration.visitorName = visitorName;
    }

    chatConfiguration.prechatFields = chatUserData;
    chatConfiguration.prechatEntities = chatEntities;
}

RCT_EXPORT_METHOD(openChat:(RCTResponseSenderBlock)successCallback
                    failureCallback:(RCTResponseSenderBlock)failureCallback)
{
    [[SCServiceCloud sharedInstance].chatCore
                     determineAvailabilityWithConfiguration:chatConfiguration
                         completion:^(NSError *error, BOOL available,
                                      NSTimeInterval estimatedWaitTime) {
      if (error != nil) {
        // Handle error
        failureCallback(@[@"Unable to get agents availability. Please try again later."]);
      } else if (available) {
        // Enable chat button. Optionally, use the estimatedWaitTime to show an estimated wait time until an agent is
        // available. This value is only valid if SCSChatConfiguration.queueStyle is set to EstimatedWaitTime.
        // Estimate is returned in seconds.
        [[SCServiceCloud sharedInstance].chatCore removeDelegate:self];
        [[SCServiceCloud sharedInstance].chatCore addDelegate:self];
        [[SCServiceCloud sharedInstance].chatUI showChatWithConfiguration:chatConfiguration showPrechat:TRUE];
        successCallback(@[[NSNull null]]);
      } else {
        // Disable button or warn user that no agents are available
        failureCallback(@[@"There are no active agents at the moment. Please contact us later."]);
      }
    }];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[ChatSessionEnd, ChatSessionStateChanged];
}

RCT_EXPORT_METHOD(setupChatColorIOS:(double)redValue greenValue:(double)greenValue blueValue:(double)blueValue
                    alphaValue:(double)alphaValue colorToken:(NSString *)colorToken)
{
    SCAppearanceConfiguration *appearance = [SCServiceCloud sharedInstance].appearanceConfiguration;
    UIColor *color = [UIColor colorWithRed:(float)redValue/255.0f green:(float)greenValue/255.0f
                                blue:(float)blueValue/255.0f alpha:(float) alphaValue];

    int colorIndex = (int)[colorTokens indexOfObject:colorToken];

    switch (colorIndex) {
        case 0:
            [appearance setColor:color forName:SCSAppearanceColorTokenBrandPrimary];
            break;
        case 1:
            [appearance setColor:color forName:SCSAppearanceColorTokenBrandSecondary];
            break;
        case 2:
            [appearance setColor:color forName:SCSAppearanceColorTokenBrandSecondaryInverted];
            break;
        case 3:
            [appearance setColor:color forName:SCSAppearanceColorTokenContrastPrimary];
            break;
        case 4:
            [appearance setColor:color forName:SCSAppearanceColorTokenContrastQuaternary];
            break;
        case 5:
            [appearance setColor:color forName:SCSAppearanceColorTokenContrastInverted];
            break;
        case 6:
            [appearance setColor:color forName:SCSAppearanceColorTokenNavbarBackground];
            break;
        case 7:
            [appearance setColor:color forName:SCSAppearanceColorTokenNavbarInverted];
            break;
        default:
            break;
    }

    [SCServiceCloud sharedInstance].appearanceConfiguration = appearance;
}

- (void)session:(id<SCSChatSession>)session didTransitionFromState:(SCSChatSessionState)previous toState:(SCSChatSessionState)current {

    NSString *state;

    switch (current) {
        case SCSChatSessionStateConnecting:
            state = Connecting;
            break;
        case SCSChatSessionStateQueued:
            state = Queued;
            break;
        case SCSChatSessionStateConnected:
            state = Connected;
            break;
        case SCSChatSessionStateEnding:
            state = Ending;
            break;
        default:
            state = Disconnected;
            break;
    }
    [self sendEventWithName:ChatSessionStateChanged body:@{@"state": state}];
}

- (void)session:(id<SCSChatSession>)session didEnd:(SCSChatSessionEndEvent *)endEvent {

    NSString *endReason;

    switch (endEvent.reason) {
        case SCSChatEndReasonUser:
            endReason = EndReasonUser;
            break;
        case SCSChatEndReasonAgent:
            endReason = EndReasonAgent;
            break;
        case SCSChatEndReasonNoAgentsAvailable:
            endReason = EndReasonNoAgentsAvailable;
            break;
        case SCSChatEndReasonTimeout:
            endReason = EndReasonTimeout;
            break;
        default:
            endReason = EndReasonSessionError;
    }

    [self sendEventWithName:ChatSessionEnd body:@{@"reason": endReason}];
}

- (void)session:(id<SCSChatSession>)session didError:(NSError *)error fatal:(BOOL)fatal {

}

@end
