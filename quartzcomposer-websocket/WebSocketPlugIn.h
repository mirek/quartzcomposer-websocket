//
//  WebSocketPlugIn.h
//  http://github.com/mirek/quartzcomposer-websocket
//
//  Created by Mirek Rusin on 28/04/2011.
//  Copyright 2011 Inteliv Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "CoreJSON.h"
#import "WebSocket.h"
#import "WebSocketSettings.h"

@interface WebSocketPlugIn : QCPlugIn {
  CFAllocatorRef allocator;
  WebSocketRef webSocket;
  
  NSMutableDictionary *inputPorts;
  NSMutableDictionary *outputPorts;
  
  CFMutableDictionaryRef outputValues;
}

@property (nonatomic, retain) NSMutableDictionary *inputPorts;
@property (nonatomic, retain) NSMutableDictionary *outputPorts;

- (QCPlugInViewController *) createViewController NS_RETURNS_RETAINED;

// Not like setValue..., updateValue can be set from outside execute.
// Duplicate values will be added to the queue or replaced, depending on the settings.
- (BOOL) updateValue: (id) value forOutputKey: (NSString *) key;

@end
