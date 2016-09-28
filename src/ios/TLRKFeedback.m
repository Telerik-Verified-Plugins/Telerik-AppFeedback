//
//  TLRKFeedback.m
//  Telerik AppFeedback Plugin
//
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "TLRKFeedback.h"
#import "CDVDevice.h"
#import <TelerikAppFeedback/TelerikAppFeedback.h>
#import <objc/message.h>

@implementation TLRKFeedback

static NSString * const kFeedbackSentAlertTitleSettingName = @"feedbackSentAlertTitle";
static NSString * const kFeedbackSentAlertTextSettingName = @"feedbackSentAlertText";
static NSString * const kFeedbackTitleSettingName = @"feedbackTitle";
static NSString * const kIOSFeedbackOptionsKeyName = @"iOS";

@synthesize webView;

-(void)initialize: (CDVInvokedUrlCommand *)command
{
    NSString *apiKey = command.arguments[0];
    NSString *apiUrl = command.arguments[1];
    NSString *uid;

    CDVDevice *device = CDVDevice.new;
    SEL devicePropertiesSEL = NSSelectorFromString(@"deviceProperties");
    SEL identifierForVendorSEL = NSSelectorFromString(@"identifierForVendor");

    if ([device respondsToSelector:devicePropertiesSEL]) {
        // Use the core plugin 'cordova-plugin-device' to get the uid value.
        // For more details see: https://github.com/apache/cordova-ios/blob/master/guides/API%20changes%20in%204.0.md
        NSDictionary *properties = objc_msgSend(device, devicePropertiesSEL);
        uid = properties[@"uuid"];
    } else if ([UIDevice.currentDevice respondsToSelector:identifierForVendorSEL]) {
        // Fallback to UIDevice's 'identifierForVendor' method.
        uid = objc_msgSend(objc_msgSend(UIDevice.currentDevice, identifierForVendorSEL), @selector(UUIDString));
    }

   	// iOS localization specific options
    // using UTF8 strings to allow displaying Chinese, Cyrillic, etc. chars 
    NSDictionary *feedbackOptions = command.arguments.count > 2 ? command.arguments[2] : nil;

    NSDictionary *iOSLocalizationOptions = [feedbackOptions valueForKey:kIOSFeedbackOptionsKeyName];
    
    NSString *feedbackSentAlertTitle = [iOSLocalizationOptions valueForKey:kFeedbackSentAlertTitleSettingName];
    if (feedbackSentAlertTitle !=nil && ![feedbackSentAlertTitle isKindOfClass:[NSNull class]]) {	
    	const char *cString = [feedbackSentAlertTitle UTF8String];
    	[TKFeedback feedbackSettings].feedbackSentAlertTitle = [NSString stringWithUTF8String:cString];
    }

    NSString *feedbackSentAlertText = [iOSLocalizationOptions valueForKey:kFeedbackSentAlertTextSettingName];
    if (feedbackSentAlertText != nil && ![feedbackSentAlertText isKindOfClass:[NSNull class]]) {
    	const char *cString = [feedbackSentAlertText UTF8String];
    	[TKFeedback feedbackSettings].feedbackSentAlertText = [NSString stringWithUTF8String:cString];
    }

    NSString *feedbackTitle = [iOSLocalizationOptions valueForKey:kFeedbackTitleSettingName];
    if (feedbackTitle != nil && ![feedbackTitle isKindOfClass:[NSNull class]]) {
    	const char *cString = [feedbackTitle UTF8String];
    	[TKFeedback feedbackSettings].feedbackTitle  = [NSString stringWithUTF8String:cString];
    }
	// end iOS localization options
	
    TKFeedback.dataSource = [[TKPlatformFeedbackSource alloc] initWithKey:apiKey uid:uid apiBaseURL:apiUrl parameters:NULL];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

-(void)showFeedback: (CDVInvokedUrlCommand *)command
{
    [TKFeedback showFeedback];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

-(void)GetVariables:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    int i;
    for (i = 0; i < [command.arguments count]; i++)
    {
        @try
        {
            NSString *variableName = [command argumentAtIndex:i];
            NSString *variableValue = [[[NSBundle mainBundle] infoDictionary] objectForKey:variableName];
            [values setObject:variableValue forKey:variableName];
        }
        @catch (NSException *exception)
        {
        }
    }

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:values];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end