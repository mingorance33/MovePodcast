//
//  ViewController.h
//  MovePodcast
//
//  Created by Jose Antonio Vazquez Mingorance on 22/10/15.
//  Copyright (c) 2015 Jose Vazquez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *AbreDirectorio;


- (IBAction)AbreDirectorio:(id)sender;

- (IBAction)exit:(id)sender;

@end

