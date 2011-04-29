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

@interface WebSocketPlugIn : QCPlugIn {
  CFAllocatorRef allocator;
  WebSocketRef webSocket;
}

@property (retain) NSDictionary *inputFoo;

/*
Declare here the properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@end
