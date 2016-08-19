//
//  TLRKFeedback.m
//  Telerik AppFeedback Plugin
//
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "TLRKFeedback.h"
#import <Cordova/UIDevice+Extensions.h>
#import <TelerikAppFeedback/TelerikAppFeedback.h>

@implementation TLRKFeedback

NSString* const feedbackSentAlertTitleSettingName = @"feedbackSentAlertTitle";
NSString* const feedbackSentAlertTextSettingName = @"feedbackSentAlertText";
NSString* const feedbackTitleSettingName = @"feedbackTitle";
NSString* const iOSFeedbackOptionsKeyName = @"iOS";


@synthesize webView;

-(void)initialize: (CDVInvokedUrlCommand *)command
{
    NSString *apiKey = command.arguments[0];
    NSString *apiUrl = command.arguments[1];

	// iOS localization specific options
    // TODO: Dont' repeat yourself
    // using UTF8 strings to allow dispalying Chinese and Cyrillic chars 
    // using NSNull comparison for JSON values set to null
	if(command.arguments.count == 3 && command.arguments[2]) {
		NSDictionary *feedbackOptions = command.arguments[2];

		NSDictionary *iOSLocalizationOptions = [feedbackOptions valueForKey:iOSFeedbackOptionsKeyName];
		if(iOSLocalizationOptions != nil ) {
			NSString* feedbackSentAlertTitle = [iOSLocalizationOptions valueForKey:feedbackSentAlertTitleSettingName];
			if (feedbackSentAlertTitle != nil && ![feedbackSentAlertTitle isKindOfClass:[NSNull class]]) {	
				char *cString = [feedbackSentAlertTitle UTF8String];
				[TKFeedback feedbackSettings].feedbackSentAlertTitle = [[NSString alloc] initWithUTF8String:cString];
		    }

			NSString* feedbackSentAlertText = [iOSLocalizationOptions valueForKey:feedbackSentAlertTextSettingName];
			if (feedbackSentAlertText != nil && ![feedbackSentAlertText isKindOfClass:[NSNull class]]) {
				char *cString = [feedbackSentAlertText UTF8String];
				[TKFeedback feedbackSettings].feedbackSentAlertText = [[NSString alloc] initWithUTF8String:cString];
			}

			NSString* feedbackTitle = [iOSLocalizationOptions valueForKey:feedbackTitleSettingName];
			if (feedbackTitle != nil && ![feedbackTitle isKindOfClass:[NSNull class]]) {
				char *cString = [feedbackTitle UTF8String];
				[TKFeedback feedbackSettings].feedbackTitle  = [[NSString alloc] initWithUTF8String:cString];
			}
		}
	}
    // end iOS localization options


    NSString *uid = [[[UIDevice currentDevice] uniqueAppInstanceIdentifier] lowercaseString];
    
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
    NSString *callbackId = [command callbackId];
    [self success:result callbackId:callbackId];
}

@end

