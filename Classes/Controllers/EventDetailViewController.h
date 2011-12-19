//
//  EventDetailViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"
#import <EventKitUI/EventKitUI.h>

@class SLFEvent;
@interface EventDetailViewController : SLFTableViewController <RKObjectLoaderDelegate, EKEventEditViewDelegate>
@property (nonatomic, retain) RKTableViewModel *tableViewModel;
@property (nonatomic,retain) SLFEvent *event;
- (id)initWithEventID:(NSString *)objID;
- (id)initWithEvent:(SLFEvent *)event;
@end
