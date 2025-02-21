@implementation MyLogMiddleware

+ (os_log_type_t)logTypeForLevel:(NSInteger)logLevel
{
    return OS_LOG_TYPE_DEFAULT;
}

+ (void)useDefaultLogType
{
    Class logMiddlewareClass = NSClassFromString(@"AMAOSLogMiddleware");
    if (!logMiddlewareClass) {
        return;
    }

    Method originalMethod = class_getInstanceMethod(logMiddlewareClass, @selector(logTypeForLevel:));
    Method swizzledMethod = class_getClassMethod([MyLogMiddleware class], @selector(logTypeForLevel:));

    if (!originalMethod || !swizzledMethod) {
        return;
    }

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end