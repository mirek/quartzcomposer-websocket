//
//  quartzcomposer_websocketPlugIn.m
//  quartzcomposer-websocket
//
//  Created by Mirek Rusin on 28/04/2011.
//  Copyright 2011 Inteliv Ltd. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "WebSocketPlugIn.h"

#define	kQCPlugIn_Name				  @"WebSocket"
#define	kQCPlugIn_Description		@"http://github.com/mirek/quartzcomposer-websocket"

@implementation WebSocketPlugIn

@synthesize inputs;
@synthesize outputs;

@dynamic inputFoo;
/*
Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputFoo, outputBar;
*/

+ (NSDictionary *) attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
          kQCPlugIn_Name, QCPlugInAttributeNameKey,
          kQCPlugIn_Description, QCPlugInAttributeDescriptionKey,
          nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	/*
	Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	*/
	
	return nil;
}

// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeConsumer;
}

// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeNone;
}

- (id) init {
	if ((self = [super init])) {
    allocator = NULL;
    webSocket = WebSocketCreate(allocator, kWebSocketHostAny, 60001, self);
	}
	return self;
}

// Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
// You can return a subclass of QCPlugInViewController if necessary.
- (QCPlugInViewController *) createViewController {
	return [[QCPlugInViewController alloc] initWithPlugIn: self viewNibName: @"WebSocketSettings"];
}

// Release any non garbage collected resources created in -init.
- (void) finalize {
	[super finalize];
}

// Release any resources created in -init.
- (void) dealloc {
  WebSocketRelease(webSocket);
	[super dealloc];
}

@end

@implementation WebSocketPlugIn (Execution)

// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
- (BOOL)startExecution:(id <QCPlugInContext>)context {
//  [context logMessage: @"start"];
	return YES;
}

// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
- (void) enableExecution: (id <QCPlugInContext>) context {
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments {
  if ([self didValueForInputKeyChange: @"inputFoo"]) {
    
    id v = [self valueForInputKey: @"inputFoo"];
    
    CFMutableArrayRef array = CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(array, CFSTR("inputFoo"));
    CFArrayAppendValue(array, v);
    
//    [self addInputPortWithType: QCPortType forKey:<#(NSString *)#> withAttributes:<#(NSDictionary *)#>]
    
    //NSLog(@"v %@, c %i", v, [v count]);
//    if ([v respondsToSelector: @selector(_list)]) {
//      id list = [v performSelector: @selector(_list)];
//      NSLog(@"list %@", list);
//      if ([list respondsToSelector: @selector(dictionary)])
//        NSLog(@"str2 %@", [list performSelector: @selector(dictionary)]);
//    }
    
    CFStringRef json = JSONCreateString(allocator, array, kJSONReadOptionsDefault, NULL);
    NSLog(@"json %@", json);
    WebSocketWriteWithString(webSocket, json);
    CFRelease(json);

    CFRelease(array);
    
//    [context logMessage: @"changed"];
//    NSLog(@"changed");
  }
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
}

@end
