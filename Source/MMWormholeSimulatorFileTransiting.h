//
//  MMWormholeSimulatorFileTransiting.h
//  MMWormhole
//
//  Created by Maris Lagzdins on 12/05/2020.
//

#import "MMWormholeTransiting.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMWormholeSimulatorFileTransiting : NSObject <MMWormholeTransiting>

- (instancetype)initWithOptionalDirectory:(nullable NSString *)directory NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSFileManager *fileManager;

- (nullable NSString *)messagePassingDirectoryPath;
- (nullable NSString *)filePathForIdentifier:(nullable NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
