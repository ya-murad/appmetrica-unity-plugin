
#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCrashes/AppMetricaCrashes.h>
#import "AMAUAppMetricaProxy.h"
#import "AMAUAdRevenueInfo.h"
#import "AMAUAppMetricaConfiguration.h"
#import "AMAUAppMetricaCrashesConfiguration.h"
#import "AMAUECommerceEvent.h"
#import "AMAUException.h"
#import "AMAUExternalAttribution.h"
#import "AMAULocation.h"
#import "AMAUReporterConfiguration.h"
#import "AMAAppMetrica+PlusKidsExtendedLogs.h"
#import "AMAURevenueInfo.h"
#import "AMAUStartupParamsCallbackProxy.h"
#import "AMAUUserProfile.h"
#import "AMAUUtils.h"

AMAULogCallbackDelegate _unityLogDelegate;

void amau_logStatus()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.status():  isActivated=%s, UUID=%s, deviceId=%s, userProfileId=%s ", AMAAppMetrica.isActivated ? "true" : "false", amau_cStringFromString(AMAAppMetrica.UUID), amau_cStringFromString(AMAAppMetrica.deviceID), amau_cStringFromString(AMAAppMetrica.userProfileID)];
            _unityLogDelegate([logStr UTF8String]);
    }
}

void amau_setUnityLogDelegate(AMAULogCallbackDelegate logger)
{
    _unityLogDelegate = logger;
    if (_unityLogDelegate != nil) {
        NSString* logStr = @"amau_setUnityLogDelegate";
        _unityLogDelegate([logStr UTF8String]);
    }
}

void amau_activate(char *configJson)
{
    [MyLogMiddleware useDefaultLogType];
    [LocalStorageCleaner clean];

    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_activate(): deviceID= %s, config= %s", amau_cStringFromString(AMAAppMetrica.deviceID), configJson];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }

    AMAAppMetricaConfiguration *config = amau_deserializeAppMetricaConfiguration(configJson);
    if (config != nil) {
        // pre-processing of the config
        NSDictionary *dict = amau_dictionaryFromCString(configJson);
        // put ErrorEnvironment from config
        if (dict[@"ErrorEnvironment"] != nil) {
            NSDictionary *env = dict[@"ErrorEnvironment"];
            for (NSString *key in env) {
                [[AMAAppMetricaCrashes crashes] setErrorEnvironmentValue:env[key] forKey:key];
            }
        }
        
        if (AMAAppMetrica.isActivated) {
            NSLog(@"Skip AppMetrica activate. AppMetrica has already been started");
            if (_unityLogDelegate != nil) {
                NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_activate(): Skip AppMetrica activate. AppMetrica has already been started. deviceID= %s", amau_cStringFromString(AMAAppMetrica.deviceID)];
                _unityLogDelegate([logStr UTF8String]);
                amau_logStatus();
            }
        } else {
            [AMAAppMetrica activateWithConfiguration:config];
            NSLog(@"Appmetrica activated with configuration: %s", configJson);
            if (_unityLogDelegate != nil) {
                NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_activate(): Appmetrica activated. deviceID= %s, config= %s", amau_cStringFromString(AMAAppMetrica.deviceID), configJson];
                _unityLogDelegate([logStr UTF8String]);
                amau_logStatus();
            }
        }
        [[AMAAppMetricaCrashes crashes] setConfiguration: amau_deserializeAppMetricaCrashesConfiguration(configJson)];
        [[[AMAAppMetricaCrashes crashes] pluginExtension] handlePluginInitFinished];
    } else {
        if (_unityLogDelegate != nil) {
                NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_activate(): Failed to deserialize AppMetrica configuration. deviceID= %s config= %s", amau_cStringFromString(AMAAppMetrica.deviceID), configJson];
                _unityLogDelegate([logStr UTF8String]);
                amau_logStatus();
            }
        NSLog(@"Failed to deserialize AppMetrica configuration: %s", configJson);
    }
}

void amau_activateReporter(char *configJson)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_activateReporter(): deviceID= %s, config= %s", amau_cStringFromString(AMAAppMetrica.deviceID), configJson];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    AMAReporterConfiguration *config = amau_deserializeReporterConfiguration(configJson);
    if (config != nil) {
        [AMAAppMetrica activateReporterWithConfiguration:config];
        
        // post-processing of the config
        NSDictionary *dict = amau_dictionaryFromCString(configJson);
        id<AMAAppMetricaReporting> reporter = [AMAAppMetrica reporterForAPIKey:config.APIKey];
        // put appEnvironment from config
        if (dict[@"AppEnvironment"] != nil) {
            NSDictionary *env = dict[@"AppEnvironment"];
            for (NSString *key in env) {
                [reporter setAppEnvironmentValue:env[key] forKey:key];
            }
        }
    } else {
        NSLog(@"Failed to deserialize AppMetrica reporter configuration: %s", configJson);
        if (_unityLogDelegate != nil) {
            NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_activateReporter(): Failed to deserialize AppMetrica configuration. deviceID= %s config= %s", amau_cStringFromString(AMAAppMetrica.deviceID), configJson];
            _unityLogDelegate([logStr UTF8String]);
            amau_logStatus();
        }
    }
}

void amau_clearAppEnvironment()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_clearAppEnvironment(): deviceID= %s", amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    [AMAAppMetrica clearAppEnvironment];
}

char *amau_getDeviceID()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_getDeviceID(): AMAAppMetrica.deviceID = %s", amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    
    return amau_cStringFromString(AMAAppMetrica.deviceID);
}

char *amau_getLibraryVersion()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_getLibraryVersion(): AMAAppMetrica.libraryVersion = %s", AMAAppMetrica.libraryVersion];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    return amau_cStringFromString(AMAAppMetrica.libraryVersion);
}

char *amau_getUuid()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_getUuid(): AMAAppMetrica.UUID = %s, deviceID= %s", AMAAppMetrica.UUID, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    return amau_cStringFromString(AMAAppMetrica.UUID);
}

bool amau_isActivated()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_getUuid(): AMAAppMetrica.isActivated = %s, deviceID= %s", AMAAppMetrica.isActivated ? "true" : "false", amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    return AMAAppMetrica.isActivated;
}

void amau_pauseSession()
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_pauseSession(): AMAAppMetrica.pauseSession = %s (deviceID = %s)", AMAAppMetrica.isActivated ? "true" : "false", amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    [AMAAppMetrica pauseSession];
}

void amau_putAppEnvironmentValue(char *key, char *value)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_putAppEnvironmentValue(): %s = %s (deviceID = %s)", key, value, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    [AMAAppMetrica setAppEnvironmentValue:amau_stringFromCString(value) forKey:amau_stringFromCString(key)];
}

void amau_putErrorEnvironmentValue(char *key, char *value)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_putErrorEnvironmentValue(): %s = %s (deviceID = %s)", key, value, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    [[AMAAppMetricaCrashes crashes] setErrorEnvironmentValue:amau_stringFromCString(value) forKey:amau_stringFromCString(key)];
}

void amau_reportAdRevenue(char *adRevenueJson)
{
    AMAAdRevenueInfo *adRevenue = amau_deserializeAdRevenueInfo(adRevenueJson);
    if (adRevenue != nil) {
        [AMAAppMetrica reportAdRevenue:adRevenue onFailure:^(NSError *error) {
            NSLog(@"Failed to report AdRevenue to AppMetrica: %@", [error localizedDescription]);
            if (_unityLogDelegate != nil) {
                NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportAdRevenue(): Failed to report AdRevenue to AppMetrica: %s (deviceID = %s)", [error localizedDescription], amau_cStringFromString(AMAAppMetrica.deviceID)];
                _unityLogDelegate([logStr UTF8String]);
                amau_logStatus();
            }
        }];
    } else {
        if (_unityLogDelegate != nil) {
            NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportAdRevenue(): Failed to deserialize AppMetrica AdRevenue %s  (deviceID = %s)", adRevenueJson, amau_cStringFromString(AMAAppMetrica.deviceID)];
            _unityLogDelegate([logStr UTF8String]);
            amau_logStatus();
        }
        NSLog(@"Failed to deserialize AppMetrica AdRevenue: %s", adRevenueJson);
    }
}

void amau_reportAppOpen(char *deeplink)
{
    NSString *url = amau_stringFromCString(deeplink);
    if (url != nil) {
        [AMAAppMetrica trackOpeningURL:[[NSURL alloc] initWithString:url]];
    } else {
        if (_unityLogDelegate != nil) {
            NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportAppOpen():  Failed to trackOpeningURL %s. Url is nil (deviceID = %s)", deeplink, amau_cStringFromString(AMAAppMetrica.deviceID)];
            _unityLogDelegate([logStr UTF8String]);
            amau_logStatus();
        }
        NSLog(@"Failed to trackOpeningURL %s. Url is nil", deeplink);
    }
}

void amau_reportECommerce(char *eCommerceJson)
{
    AMAECommerce *eCommerce = amau_deserializeECommerce(eCommerceJson);
    if (eCommerce != nil) {
        [AMAAppMetrica reportECommerce:eCommerce onFailure:^(NSError *error) {
            NSLog(@"Failed to report ECommerce to AppMetrica: %@", [error localizedDescription]);
        }];
    } else {
        NSLog(@"Failed to deserialize AppMetrica ECommerce: %s", eCommerceJson);
    }
}

void amau_reportErrorWithoutIdentifier(char *messageCString, char *errorJson)
{
    NSString *message = amau_stringFromCString(messageCString);
    AMAPluginErrorDetails *error = amau_deserializeException(errorJson);
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportErrorWithoutIdentifier():  %s=%s (deviceID = %s)",messageCString, errorJson, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }

    if (error.backtrace.count == 0) {
        [[[AMAAppMetricaCrashes crashes] pluginExtension] reportErrorWithIdentifier:@"Errors without stacktrace"
                                                                            message:message
                                                                            details:error
                                                                          onFailure:^(NSError *error) {
            NSLog(@"Failed to report error to AppMetrica: %@", [error localizedDescription]);
        }];
    } else {
        [[[AMAAppMetricaCrashes crashes] pluginExtension] reportError:error message:message onFailure:^(NSError *error) {
            NSLog(@"Failed to report error to AppMetrica: %@", [error localizedDescription]);
        }];
    }
}

void amau_reportError(char *identifier, char *message, char *error)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportError():  %s: %s=%s (deviceID = %s)",identifier, message, error, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }

    [[[AMAAppMetricaCrashes crashes] pluginExtension] reportErrorWithIdentifier:amau_stringFromCString(identifier)
                                                                        message:amau_stringFromCString(message)
                                                                        details:amau_deserializeException(error)
                                                                      onFailure:^(NSError *error) {
        NSLog(@"Failed to report error to AppMetrica: %@", [error localizedDescription]);
    }];
}

void amau_reportEvent(char *message, char *paramsJson)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportEvent():  %s params=%s (deviceID = %s)",message, paramsJson, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }

    [AMAAppMetrica reportEvent:amau_stringFromCString(message)
                    parameters:amau_dictionaryFromCString(paramsJson)
                     onFailure:^(NSError *error) {
        if (_unityLogDelegate != nil) {
            NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_reportEvent():  Failed to report event to AppMetrica: %@ . %s params=%s (deviceID = %s)",[error localizedDescription], message, paramsJson, amau_cStringFromString(AMAAppMetrica.deviceID)];
            _unityLogDelegate([logStr UTF8String]);
            amau_logStatus();
        }
        NSLog(@"Failed to report event to AppMetrica: %@", [error localizedDescription]);
    }];
}

void amay_reportExternalAttribution(char *sourceStr, char *value)
{
    AMAAttributionSource source = amau_getExternalAttributionSource(sourceStr);
    if (source == nil) {
        NSLog(@"Failed to report external attribution to AppMetrica. Unknown source %s", sourceStr);
        return;
    }
    
    NSDictionary *dict = amau_dictionaryFromCString(value);
    [AMAAppMetrica reportExternalAttribution:dict source:source onFailure:^(NSError *error) {
        NSLog(@"Failed to report external attribution to AppMetrica: %@", [error localizedDescription]);
    }];
}

void amau_reportRevenue(char *revenueJson)
{
    AMARevenueInfo *revenueInfo = amau_deserializeRevenueInfo(revenueJson);
    if (revenueInfo != nil) {
        [AMAAppMetrica reportRevenue:revenueInfo onFailure:^(NSError *error) {
            NSLog(@"Failed to report Revenue to AppMetrica: %@", [error localizedDescription]);
        }];
    } else {
        NSLog(@"Failed to deserialize AppMetrica Revenue: %s", revenueJson);
    }
}

void amau_reportUnhandledException(char *exception)
{
    [[[AMAAppMetricaCrashes crashes] pluginExtension] reportUnhandledException:amau_deserializeException(exception)
                                                                     onFailure:^(NSError *error) {
        NSLog(@"Failed to report unhandled exception to AppMetrica: %@", [error localizedDescription]);
    }];
}

void amau_reportUserProfile(char *userProfileJson)
{
    AMAUserProfile *userProfile = amau_deserializeUserProfile(userProfileJson);
    if (userProfile != nil) {
        [AMAAppMetrica reportUserProfile:userProfile onFailure:^(NSError *error) {
            NSLog(@"Failed to report UserProfile to AppMetrica: %@", [error localizedDescription]);
        }];
    } else {
        NSLog(@"Failed to deserialize AppMetrica UserProfile: %s", userProfileJson);
    }
}

void amau_requestStartupParams(char *identifiersJson, AMAUStartupParamsCallbackDelegate delegate, AMAUAction actionPtr)
{
    NSArray *identifiers = amau_fixStartupParamsKeys(amau_arrayFromCString(identifiersJson));
    [AMAAppMetrica requestStartupIdentifiersWithKeys:identifiers
                                     completionQueue:nil
                                     completionBlock:^(NSDictionary<AMAStartupKey,id> * _Nullable identifiers, NSError * _Nullable error) {
        if (delegate != nil) {
            delegate(actionPtr, amau_serializeStartupParamsResult(identifiers), amau_serializeStartupParamsError(error));
        }
    }];
}

void amau_resumeSession()
{
    [AMAAppMetrica resumeSession];
}

void amau_sendEventsBuffer()
{
    [AMAAppMetrica sendEventsBuffer];
}

void amau_setDataSendingEnabled(bool enabled)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_setDataSendingEnabled():  %s (deviceID = %s)", enabled ? "true" : "false", amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    [AMAAppMetrica setDataSendingEnabled:enabled];
}

void amau_setLocation(char *location)
{
    AMAAppMetrica.customLocation = amau_deserializeLocation(amau_stringFromCString(location));
}

void amau_setLocationTracking(bool enabled)
{
    AMAAppMetrica.locationTrackingEnabled = enabled;
}

void amau_setUserProfileID(char *userProfileID)
{
    if (_unityLogDelegate != nil) {
        NSString* logStr = [NSString stringWithFormat:@"native_appmetrica.amau_setUserProfileID():  %s (deviceID = %s)", userProfileID, amau_cStringFromString(AMAAppMetrica.deviceID)];
        _unityLogDelegate([logStr UTF8String]);
        amau_logStatus();
    }
    [AMAAppMetrica setUserProfileID:amau_stringFromCString(userProfileID)];
}

void amau_touchReporter(char *apiKey)
{
    [AMAAppMetrica reporterForAPIKey:amau_stringFromCString(apiKey)];
}
