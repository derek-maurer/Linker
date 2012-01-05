//
//  HSLinker.m
//  Linker
//
//  Created by Derek Maurer on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HSLinker.h"

@implementation HSLinker

-(id)initWithPath:(NSString *)p andRemoveOption:(BOOL)r {
    if ((self = [super init])) {
        path = [[NSString alloc] initWithString:p];
        remove = r;
    }
    return self;
}

-(void)dealloc {
    [path release];
    [super dealloc];
}

-(void)link {
    
    if (!remove) {
        BOOL exist = NO;
        
        do {
            char str[500];
            printf("Please enter the directory for theos:");
            scanf("%s",str);
            theosPath = [NSString stringWithUTF8String:str];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:theosPath])
                exist = YES;
            else
                NSLog(@"Invalid path. Try again.");
        } while (!exist);
    }
    
    NSString *makeFilePath = [NSString stringWithFormat:@"%@/Makefile",path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:makeFilePath]) {
        NSLog(@"No Makefile at path: %@",path);
        exit(0);
    }
    
    NSArray *subprojects = [self subprojectsAtPath:path];
    
    if (subprojects) {
        NSLog(@"Working...");
        NSString *theos = [NSString stringWithFormat:@"%@/theos",path];
        if ([self theosExists:path] && remove) 
            [[NSFileManager defaultManager] removeItemAtPath:theos error:nil];
        else if (!remove) {
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:theos withDestinationPath:theosPath error:nil];
        }
        
        [self linkTheosForProjects:subprojects withPath:path];
        NSLog(@"Finished");
    }
    else {
        NSString *theos = [NSString stringWithFormat:@"%@/theos",path];
        if ([self theosExists:path] && remove) 
            [[NSFileManager defaultManager] removeItemAtPath:theos error:nil];
        else if (!remove) {
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:theos withDestinationPath:theosPath error:nil];
        }
    }
}

-(void)linkTheosForProjects:(NSArray *)projects withPath:(NSString *)p {
    for (NSUInteger i=0; i<projects.count; i++) {
        if (remove) {
            NSString *project = [NSString stringWithFormat:@"%@/%@",p,[projects objectAtIndex:i]];
            NSString *theos = [NSString stringWithFormat:@"%@/%@/theos",p,[projects objectAtIndex:i]];
            if ([self theosExists:theos])
                [[NSFileManager defaultManager] removeItemAtPath:theos error:nil];
            NSArray *subprojects = [self subprojectsAtPath:project];
            if (subprojects) {
                [self linkTheosForProjects:subprojects withPath:project];
            }
        }
        else {
            NSString *project = [NSString stringWithFormat:@"%@/%@",p,[projects objectAtIndex:i]];
            NSString *theos = [NSString stringWithFormat:@"%@/%@/theos",p,[projects objectAtIndex:i]];
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:theos withDestinationPath:theosPath error:nil];
            NSArray *subprojects = [self subprojectsAtPath:project];
            if (subprojects) {
                [self linkTheosForProjects:subprojects withPath:project];
            }
        }
    }
}

-(NSArray *)subprojectsAtPath:(NSString *)p {
    NSStringEncoding encoding;
    NSError *error = nil;
    NSString *makeFilePath = [NSString stringWithFormat:@"%@/Makefile",p];
    
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:makeFilePath usedEncoding:&encoding error:&error];
    NSRange subprojectsRange = [fileContents rangeOfString:@"SUBPROJECTS"];
    
    if (subprojectsRange.length == 0) return  nil;
    
    NSString *subprojectsString = [self substringWithString:fileContents startingAtIndex:subprojectsRange.location endingAtCharacter:@"\n"];
    
    NSMutableArray *subprojects = [[NSMutableArray alloc] initWithArray:[subprojectsString componentsSeparatedByString:@" "]];
    [subprojects removeObject:@"SUBPROJECTS"];
    [subprojects removeObject:@"="];
    
    return subprojects;
}

-(BOOL)theosExists:(NSString *)p {
    return [[NSFileManager defaultManager] fileExistsAtPath:p];
}

-(NSString *)substringWithString:(NSString *)s startingAtIndex:(NSUInteger)start endingAtCharacter:(NSString *)ch {
    NSString *substring = [s substringFromIndex:start];
    NSString *results = nil;
    
    NSRange range = [substring rangeOfString:@"\n"];
    
    results = [substring substringToIndex:range.location];
    
    return results;
}

@end
