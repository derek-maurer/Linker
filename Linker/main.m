//
//  main.m
//  Linker
//
//  Created by Derek Maurer on 12/31/11.
//  Copyright (c) 2011 Home School Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSLinker.h"

static BOOL validPath(char* path) {
    return [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:path]];
}

int main (int argc, char **argv)
{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        BOOL validInput = NO;
        BOOL currentPath = YES;
        BOOL add = NO;
        BOOL remove = NO;
        
        int c;
        char *path = nil;
        if (argc != 1) {
            while ((c = getopt(argc,argv,"hrap:")) != -1) {
                switch (c) {
                    case 'p':
                        path = optarg;
                        if (validPath(path)) {
                            validInput = YES;
                            currentPath = NO;
                        }
                        break;
                    case 'a':
                        add = YES;
                        break;
                    case 'r':
                        remove = YES;
                        break;
                    case 'h':
                        NSLog(@"\n-p 'path to project folder': will execute the program at the specified folder\n-a: adds theos symbolic links to the projec\n-r: removes theos symbolic links to the project\n Executing the program without specifying a path will automatically make the path the same as the executable.");
                        exit(0);
                        break;
                    default:
                        NSLog(@"You entered an invalid argument. Use the -h parameter to learn how this program works.");
                        break;
                }
            }
        }
        else if (argc == 1) {
            NSLog(@"Please use the -h parameter to learn how this program works");
            exit(0);
        }
            
        if (!add && !remove) {
            NSLog(@"You must specify -r to remove the theos links or -a to add them.");
            exit(0);
        }
        else if (add && remove) {
            NSLog(@"Naughty boy, you can't remove and add the links");
            exit(0);
        }
        
        if (!validInput && currentPath) {
            NSMutableArray *arguments = [NSMutableArray array];
            for (NSUInteger i = 0; i < argc; i++) {
                NSString *argument = [NSString stringWithUTF8String:argv[i]];
                if (argument) [arguments addObject:argument];
            }
            const char *executablePath = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] fileSystemRepresentation];
            NSString *exec = [NSString stringWithUTF8String:executablePath];
            exec = [exec stringByDeletingLastPathComponent];
            
            if (add) remove = NO; else remove = YES;
            HSLinker *linker = [[HSLinker alloc] initWithPath:exec andRemoveOption:remove];
            [linker link];
        }
        else if (validInput) {
            if (add) remove = NO; else remove = YES;
            HSLinker *linker = [[HSLinker alloc] initWithPath:[NSString stringWithUTF8String:path] andRemoveOption:remove];
            [linker link];
        }
        
    [pool release];
    return 0;
}

