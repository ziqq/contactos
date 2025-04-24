#import "ContactosPlugin.h"

#if __has_include(<contactos/contactos-Swift.h>)
#import <contactos/contactos-Swift.h>
#else
#import "contactos-Swift.h"
#endif

@implementation ContactosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftContactosPlugin registerWithRegistrar:registrar];
}
@end
