//
//  WebSocketSettings.m
//  quartzcomposer-websocket
//
//  Created by Mirek Rusin on 30/04/2011.
//  Copyright 2011 Inteliv Ltd. All rights reserved.
//

#import "WebSocketSettings.h"


@implementation WebSocketSettings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Custom plugIn

- (WebSocketPlugIn *) plugIn {
  return (WebSocketPlugIn *)[super plugIn];
}

#pragma mark Actions

- (IBAction) addInputPort: (id) sender {
  NSString *portTypeName = [inputPortTypeComboBox objectValue];
  NSString *key = [inputPortNameTextField stringValue];
  if (![portTypeName isEqualToString: @""] && ![key isEqualToString: @""]) {
    [self.plugIn addInputPortWithType: [@"QCPortType" stringByAppendingString: portTypeName]
                               forKey: key
                       withAttributes: nil];
    [inputPortsTableView reloadData];
  }
}

- (IBAction) removeInputPort: (id) sender {
  NSInteger selectedRow = [inputPortsTableView selectedRow];
  if (selectedRow >= 0) {
    NSString *key = [self.plugIn.inputPorts.allKeys objectAtIndex: selectedRow];
    if (key) {
      [self.plugIn removeInputPortForKey: key];
      [inputPortsTableView reloadData];
    }
  }
}

- (IBAction) addOutputPort: (id) sender {
  NSString *portTypeName = [outputPortTypeComboBox objectValue];
  NSString *key = [outputPortNameTextField stringValue];
  if (![portTypeName isEqualToString: @""] && ![key isEqualToString: @""]) {
    [self.plugIn addOutputPortWithType: [@"QCPortType" stringByAppendingString: portTypeName]
                                forKey: key
                        withAttributes: nil];
    [outputPortsTableView reloadData];
  }
}

- (IBAction) removeOutputPort: (id) sender {
  NSInteger selectedRow = [outputPortsTableView selectedRow];
  if (selectedRow >= 0) {
    NSString *key = [self.plugIn.outputPorts.allKeys objectAtIndex: selectedRow];
    if (key) {
      [self.plugIn removeOutputPortForKey: key];
      [outputPortsTableView reloadData];
    }
  }
}

#pragma mark NSTableViewDataSource delegate methods

- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView {
  NSInteger rows = 0;
  if (tableView == inputPortsTableView) {
    rows = [self.plugIn.inputPorts count];
  } else if (tableView == outputPortsTableView) {
    rows = [self.plugIn.outputPorts count];
  }
  return rows;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  id objectValue = nil;
  
  NSMutableDictionary *ports = nil;
  if (tableView == inputPortsTableView) {
    ports = self.plugIn.inputPorts;
  } else if (tableView == outputPortsTableView) {
    ports = self.plugIn.outputPorts;
  }
  
  if (ports) {
    NSString *key = [[ports allKeys] objectAtIndex: row];
    if (key) {
      NSDictionary *port = [ports objectForKey: key];
      if (port) {
        NSString *headerCellStringValue = [[tableColumn headerCell] stringValue];
        if ([headerCellStringValue isEqualToString: @"Name"]) {
          NSString *name = [port objectForKey: QCPortAttributeNameKey];
          objectValue = name ? name : key;
        } else if ([headerCellStringValue isEqualToString: @"Type"]) {
          objectValue = [port objectForKey: QCPortAttributeTypeKey];
        }
      }
    }
  }
  
  return objectValue;
}

#pragma mark NSTextFieldDelegate methods

- (BOOL) control: (NSControl *) control textShouldEndEditing: (NSText *) fieldEditor {
  NSLog(@"str: %@", fieldEditor.string);
  return YES;
}

@end
