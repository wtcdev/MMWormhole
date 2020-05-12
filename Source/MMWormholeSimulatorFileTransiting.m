//
//  MMWormholeSimulatorFileTransiting.m
//  MMWormhole
//
//  Created by Maris Lagzdins on 12/05/2020.
//

#import <Foundation/Foundation.h>

#import "MMWormholeSimulatorFileTransiting.h"

@interface MMWormholeSimulatorFileTransiting ()

@property (nonatomic, copy) NSString *directory;
@property (nonatomic, strong, readwrite) NSFileManager *fileManager;

@end

@implementation MMWormholeSimulatorFileTransiting

- (instancetype)init {
    return [self initWithOptionalDirectory:nil];
}

- (instancetype)initWithOptionalDirectory:(nullable NSString *)directory {
    #if !(TARGET_OS_SIMULATOR)
    NSAssert(NO, @"MMWormholeSimulatorFileTransiting is only meant to be run on iOS simulators.");
    #endif

    if ((self = [super init])) {
        _directory = [directory copy];
        _fileManager = [[NSFileManager alloc] init];
    }

    return self;
}

#pragma mark - Private File Operation Methods

- (nullable NSString *)messagePassingDirectoryPath {
    // Accessing simulator
    NSString *directoryPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"SIMULATOR_SHARED_RESOURCES_DIRECTORY"];

    NSAssert(directoryPath != nil, @"SIMULATOR_SHARED_RESOURCES_DIRECTORY must be accessible.");

    if (self.directory != nil) {
        directoryPath = [directoryPath stringByAppendingPathComponent:self.directory];
    }

    [self.fileManager createDirectoryAtPath:directoryPath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];

    return directoryPath;
}

- (nullable NSString *)filePathForIdentifier:(nullable NSString *)identifier {
    if (identifier == nil || identifier.length == 0) {
        return nil;
    }

    NSString *directoryPath = [self messagePassingDirectoryPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.archive", identifier];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];

    return filePath;
}


#pragma mark - Public Protocol Methods

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }

    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        NSString *filePath = [self filePathForIdentifier:identifier];

        if (data == nil || filePath == nil) {
            return NO;
        }

        BOOL success = [data writeToFile:filePath atomically:YES];

        if (!success) {
            return NO;
        }
    }

    return YES;
}

- (id<NSCoding>)messageObjectForIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return nil;
    }

    NSString *filePath = [self filePathForIdentifier:identifier];

    if (filePath == nil) {
        return nil;
    }

    NSData *data = [NSData dataWithContentsOfFile:filePath];

    if (data == nil) {
        return nil;
    }

    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    return messageObject;
}

- (void)deleteContentForIdentifier:(NSString *)identifier {
    [self.fileManager removeItemAtPath:[self filePathForIdentifier:identifier] error:NULL];
}

- (void)deleteContentForAllMessages {
    if (self.directory != nil) {
        NSArray *messageFiles = [self.fileManager contentsOfDirectoryAtPath:[self messagePassingDirectoryPath] error:NULL];

        NSString *directoryPath = [self messagePassingDirectoryPath];

        for (NSString *path in messageFiles) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:path];

            [self.fileManager removeItemAtPath:filePath error:NULL];
        }
    }
}

@end
