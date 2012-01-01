//
//  HSLinker.h
//  Linker
//
//  Created by Derek Maurer on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "stdio.h"

@interface HSLinker : NSObject {
    NSString *path;
    NSString *theosPath;
    BOOL remove;
}
-(id)initWithPath:(NSString *)p andRemoveOption:(BOOL)r;
-(void)link;
-(BOOL)theosExists:(NSString *)p;
-(NSArray *)subprojectsAtPath:(NSString *)p;
-(NSString *)substringWithString:(NSString *)s startingAtIndex:(NSUInteger)start endingAtCharacter:(NSString *)ch;
-(void)linkTheosForProjects:(NSArray *)projects withPath:(NSString *)p;
@end
