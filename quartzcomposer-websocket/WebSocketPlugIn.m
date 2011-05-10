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

#pragma name WebSocket read callback

void WebSocketPlugInReadCallback(WebSocketRef webSocket, WebSocketClientRef client, CFStringRef value) {
  WebSocketPlugIn *plugIn = webSocket->userInfo;
  if (plugIn) {
    CFErrorRef *error = NULL;
    CFTypeRef json = JSONCreateWithString(webSocket->allocator, value, kJSONReadOptionsDefault, error);
    if (json) {
      if (CFArrayGetTypeID() == CFGetTypeID(json)) {
        if (CFArrayGetCount(json) == 2) {
          CFTypeRef tuple1 = CFArrayGetValueAtIndex(json, 0);
          CFTypeRef tuple2 = CFArrayGetValueAtIndex(json, 1);
          if (CFGetTypeID(tuple1) == CFStringGetTypeID()) {
            if ([plugIn updateValue: tuple2 forOutputKey: tuple1]) {
              NSLog(@"all ok %@, %@", tuple1, tuple2);
              // pass, all ok.
            } else {
              // TODO: probably specified key doesn't exist
            }
          } else {
            // TODO: first value should be string (key)
          }
        } else {
          // TODO: got array but not 2 slots
        }
      } else {
        // TODO: got json, but not an array
      }
      CFRelease(json);
    } else {
      // TODO: got something that can't be parsed as json
    }
    if (error) {
      CFShow(error);
      CFRelease(error);
    }
  }
}

@implementation WebSocketPlugIn

@synthesize inputPorts;
@synthesize outputPorts;

- (BOOL) updateValue: (id) value forOutputKey: (NSString *) key {
  if ([outputPorts objectForKey: key]) {
    
    // Process the output value only for output ports that actually exist
    CFDictionarySetValue(outputValues, key, value);
    
    return YES;
  } else {
    return NO;
  }
}

+ (NSDictionary *) attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
          kQCPlugIn_Name, QCPlugInAttributeNameKey,
          kQCPlugIn_Description, QCPlugInAttributeDescriptionKey,
          nil];
}

+ (NSArray *) plugInKeys {
  return [NSArray arrayWithObjects: @"inputPorts", @"outputPorts", nil];
}

// Specify the optional attributes for property based ports
// (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
//+ (NSDictionary *) attributesForPropertyPortWithKey: (NSString *) key {
//	return nil;
//}

// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeProcessor;
}

// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeIdle;
}

- (void) setValue: (id) value forKey: (NSString *) key {
  if ([key isEqualToString: @"inputPorts"]) {
    if (value) {
      for (NSString *key in [value allKeys]) {
        [self addInputPortWithType: [[value objectForKey: key] objectForKey: QCPortAttributeTypeKey] forKey: key withAttributes: [value objectForKey: key]];
      }
    } else {
      // TODO: Remove all dynamic input ports
    }
  } else if ([key isEqualToString: @"outputPorts"]) {
    if (value) {
      for (NSString *key in [value allKeys]) {
        [self addOutputPortWithType: [[value objectForKey: key] objectForKey: QCPortAttributeTypeKey] forKey: key withAttributes: [value objectForKey: key]];
      }
    } else {
      // TODO: Remove all dynamic output ports
    }
  } else {
    [super setValue: value forKey: key];
  }
}

- (id) init {
	if ((self = [super init])) {
    allocator = NULL;
    outputValues = CFDictionaryCreateMutable(allocator, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    webSocket = WebSocketCreate(allocator, kWebSocketHostAny, 60001, self);
    WebSocketSetClientReadCallback(webSocket, WebSocketPlugInReadCallback);
	}
	return self;
}

- (void) addInputPortWithType:(NSString *)type forKey:(NSString *)key withAttributes:(NSDictionary *)attributes {
  
  // If this is the first time we're adding port, create the dictionary.
  if (!self.inputPorts) {
    NSMutableDictionary *inputPorts_ = [[NSMutableDictionary alloc] init];
    self.inputPorts = inputPorts_;
    [inputPorts_ release];
  }
  
  // Make sure the attribtues include port type
  NSMutableDictionary *attributesWithType = attributes ? [attributes mutableCopy] : [[NSMutableDictionary alloc] init];
  if (![attributesWithType objectForKey: QCPortAttributeTypeKey]) {
    [attributesWithType setObject: type forKey: QCPortAttributeTypeKey];
  }
  
  // If the key already exists, we want to replace it. We need to remove it first from plugin.
  if ([inputPorts objectForKey: key]) {
    [inputPorts removeObjectForKey: key];
    [super removeInputPortForKey: key];
  }
  
  [super addInputPortWithType: type forKey: key withAttributes: attributesWithType];
  [inputPorts setObject: attributesWithType forKey: key];
  
  [attributesWithType release];
}

- (void) removeInputPortForKey:(NSString *)key {
  if (inputPorts) {
    if ([inputPorts objectForKey: key]) {
      [inputPorts removeObjectForKey: key];
      [super removeInputPortForKey: key];
    }
  }
}

- (void) addOutputPortWithType:(NSString *)type forKey:(NSString *)key withAttributes:(NSDictionary *)attributes {
  
  // If this is the first time we're adding port, create the dictionary.
  if (!self.outputPorts) {
    NSMutableDictionary *outputPorts_ = [[NSMutableDictionary alloc] init];
    self.outputPorts = outputPorts_;
    [outputPorts_ release];
  }

  // Make sure the attribtues include port type
  NSMutableDictionary *attributesWithType = attributes ? [attributes mutableCopy] : [[NSMutableDictionary alloc] init];
  if (![attributesWithType objectForKey: QCPortAttributeTypeKey]) {
    [attributesWithType setObject: type forKey: QCPortAttributeTypeKey];
  }
  
  // If the key already exists, we want to replace it. We need to remove it first from plugin.
  if ([outputPorts objectForKey: key]) {
    [outputPorts removeObjectForKey: key];
    [super removeOutputPortForKey: key];
  }
  
  [super addOutputPortWithType: type forKey: key withAttributes: attributesWithType];
  [outputPorts setObject: attributesWithType forKey: key];
  
  [attributesWithType release];
}

- (void) removeOutputPortForKey:(NSString *)key {
  if (outputPorts) {
    if ([outputPorts objectForKey: key]) {
      [outputPorts removeObjectForKey: key];
      [super removeOutputPortForKey: key];
    }
  }
}

// Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
// You can return a subclass of QCPlugInViewController if necessary.
- (QCPlugInViewController *) createViewController {
	return [[WebSocketSettings alloc] initWithPlugIn: self viewNibName: @"WebSocketSettings"];
}

// Release any non garbage collected resources created in -init.
- (void) finalize {
	[super finalize];
}

// Release any resources created in -init.
- (void) dealloc {
  WebSocketRelease(webSocket);
  CFRelease(outputValues);
	[super dealloc];
}

@end

@implementation WebSocketPlugIn (Execution)

// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
- (BOOL) startExecution: (id <QCPlugInContext>) context {
	return YES;
}

// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
- (void) enableExecution: (id <QCPlugInContext>) context {
}

// Called by Quartz Composer whenever the plug-in instance needs to execute.
// Only read from the plug-in inputs and produce a result (by writing to the plug-in
// outputs or rendering to the destination OpenGL context) within that method and nowhere else.
//
// Return NO in case of failure during the execution (this will prevent rendering of the current
// frame to complete).
//
// The OpenGL context for rendering can be accessed and defined for CGL macros using:
// CGLContextObj cgl_ctx = [context CGLContextObj];
- (BOOL) execute: (id <QCPlugInContext>) context atTime: (NSTimeInterval) time withArguments: (NSDictionary *) arguments {
  
  for (NSString *key in [[self inputPorts] keyEnumerator]) {
    if ([self didValueForInputKeyChange: key]) {
      id value = [self valueForInputKey: key];
      
      CFMutableArrayRef array = CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks);
      if (array) {
        CFArrayAppendValue(array, key);
        CFArrayAppendValue(array, value);
        
        CFErrorRef *error = NULL;
        CFStringRef json = JSONCreateString(allocator, array, kJSONReadOptionsDefault, error);
        if (json) {
          NSLog(@"json %@", json);
          WebSocketWriteWithString(webSocket, json);
          CFRelease(json);
        } else {
          // TODO: Couldn't create json string
        }
        
        if (error) {
          CFStringRef string = CFErrorCopyDescription(*error);
          if (string) {
            [context logMessage: @"WebSocket Error: %@", string];
            CFRelease(string);
          }
          CFRelease(error);
        }
        
        CFRelease(array);
      } else {
        // TODO: Couldn't create an array
      }
    }
  }
  
  CFIndex count = CFDictionaryGetCount(outputValues);
  if (count > 0) {
    CFTypeRef *keys = CFAllocatorAllocate(allocator, count * sizeof(CFTypeRef), 0);
    CFTypeRef *values = CFAllocatorAllocate(allocator, count * sizeof(CFTypeRef), 0);
    CFDictionaryGetKeysAndValues(outputValues, keys, values);
    for (CFIndex i = 0; i < count; i++) {
      [self setValue: values[i] forOutputKey: keys[i]];
    }
    CFAllocatorDeallocate(allocator, values);
    CFAllocatorDeallocate(allocator, keys);
    CFDictionaryRemoveAllValues(outputValues);
  }
  
	return YES;
}

// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
- (void) disableExecution: (id <QCPlugInContext>) context {
}

// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
- (void)stopExecution: (id <QCPlugInContext>) context {
}

@end
