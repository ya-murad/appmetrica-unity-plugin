#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

@interface LocalStorageCleaner : NSObject

+ (void)clean;

@end

@implementation LocalStorageCleaner

+ (void)clean
{
    NSString *key = @"AppMetrica.storage.removed.580";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL deleted = [defaults boolForKey:key];
    
    if (deleted) {
        return;
    }

    [defaults setBool:YES forKey:key];
    [defaults synchronize];
    
    NSString *path = [AMAFileUtility persistentPath];
    [AMAFileUtility deleteFileAtPath:path];
}
@end