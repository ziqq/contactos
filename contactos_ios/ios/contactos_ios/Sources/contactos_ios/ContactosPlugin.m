#import "ContactosPlugin.h"

#if __has_include(<contactos_ios/contactos_ios-Swift.h>)
#import <contactos_ios/contactos_ios-Swift.h>
#else
#import "contactos_ios-Swift.h"
#endif

@implementation ContactosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftContactosPlugin registerWithRegistrar:registrar];
}
@end
