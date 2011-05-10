//
//  WebSocketSettings.h
//  quartzcomposer-websocket
//
//  Created by Mirek Rusin on 30/04/2011.
//  Copyright 2011 Inteliv Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "WebSocketPlugIn.h"

@class WebSocketPlugIn;

@interface WebSocketSettings : QCPlugInViewController <NSTableViewDataSource> {
@private
 
  IBOutlet NSTableView *inputPortsTableView;
  IBOutlet NSTextField *inputPortNameTextField;
  IBOutlet NSComboBox *inputPortTypeComboBox;
  
  IBOutlet NSTableView *outputPortsTableView;
  IBOutlet NSTextField *outputPortNameTextField;
  IBOutlet NSComboBox *outputPortTypeComboBox;
}

- (WebSocketPlugIn *) plugIn;

- (IBAction) addInputPort: (id) sender;
- (IBAction) removeInputPort: (id) sender;

- (IBAction) addOutputPort: (id) sender;
- (IBAction) removeOutputPort: (id) sender;

@end
