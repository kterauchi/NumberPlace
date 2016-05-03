//
//  Sudoku.m
//  numBoard
//
//  Created by Keiichiro on 2016/03/01.
//  Copyright © 2016年 Keiichiro. All rights reserved.
//

#define MAXNUM 9

#import "Sudoku.h"

@interface Sudoku()
/// 数独の全マスが入る二次元配列。初期化でNSNullが入り、値はNSNumberを入れる。
@property (nonatomic) NSMutableArray *numBoard;

@end

@implementation Sudoku

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初期化
        self.numBoard = [@[] mutableCopy];
        for (int i = 0; i < MAXNUM; i++) {
            self.numBoard[i] = [@[] mutableCopy];
        }
        
        // 一旦nullで埋める
        for (int y = 0; y < MAXNUM; y++) {
            for (int x = 0; x < MAXNUM; x++) {
                self.numBoard[y][x] = [NSNull null];
            }
        }
    }
    return self;
}

#pragma mark - Public Methods
- (void)fire
{
//    // 処理時間計算用
    NSLog(@"\n---Start---");
    
    int count = 0;
    for (;; count++) {
        // 条件に従い、全てのマスをランダムに埋める。条件に当てはまらない場所は空欄のままスキップ
        [self allRandomFill];

//        [self show];
//        printf("\n");
        
        // NSNullの項目があるか全探索。あった場合、一番完成に近い座標と関連するNSNullの数を返す。
        NSArray *result = [self checkAllCountNull];
        
        // NSNullの個数が0になっていれば、処理を打ち切る。
        if ([result[2] integerValue] == 0) {
            break;
        }
        
        // 完成していなければ、より完成に近いマスの上下左右を削除
        [self crossDeleteX:[result[0] integerValue] andY:[result[1] integerValue]];
    }
    
    [self show];
    
    printf("----End----\n");
    NSLog(@"\n計%d回で完成", count);
}

#pragma mark - Private Methods
/**
 全てのマスを条件に従いランダムで埋めるメソッド。
 条件に適合出来ない場合は、そのマスはスキップする。
 */
- (void)allRandomFill
{
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull line, NSUInteger idxY, BOOL * _Nonnull stop) {
        
        // 処理簡略化
        if (![line containsObject:[NSNull null]]) {
            return;
        }
        
        __block NSMutableSet *temSet = [NSMutableSet setWithArray:line];
        [line enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idxX, BOOL * _Nonnull stop) {
            
            // NSNullの場所のみ処理
            if ([obj isMemberOfClass:[NSNull class]]) {

                NSInteger counter = 0;
                NSInteger num = arc4random_uniform(MAXNUM);
                do {
                    num = ++num > MAXNUM ? 1 : num;
                    line[idxX] = [NSNumber numberWithInteger:num];
                    ++counter;
                } while (((counter < MAXNUM) && [temSet containsObject:[NSNumber numberWithInteger:num]])
                         || ((counter < MAXNUM) && [self checkBoxSameNumAtX:idxX andY:idxY])
                         || ((counter < MAXNUM) && [self checkColumnSameNumAtX:idxX andY:idxY]));
                
                // 全ての値を入れることが出来なければ、再度NSNullを入れておく。
                if (counter == MAXNUM) {
                    line[idxX] = [NSNull null];
                }

                [temSet addObject:[NSNumber numberWithInteger:num]];
            }
        }];

        self.numBoard[idxY] = line;
    }];
}

/**
 マスを表示
 */
- (void)show
{
    [self.numBoard enumerateObjectsUsingBlock:^(NSArray* _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [line enumerateObjectsUsingBlock:^(id _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // NSNull対策
            if (![num isMemberOfClass:[NSNull class]]) {
                printf("%ld ", (long)[num integerValue]);
            }else{
                printf("  ");
            }
            
            if (idx == line.count -1) {
                printf("\n");
            }
        }];
    }];
}

#pragma mark 全探索メソッド
/**
 全マスに対し、行、列、3x3の範囲に何こNSNullがあるかを求め、最小のマス(より完成しているマス)の座標とNSNullの個数を返す
 @return NSArray[3] X軸, Y軸, NSNullの数。 全てのマスでNSNullがなければ、全て0を返す。
 */
-(NSArray*)checkAllCountNull
{
    // 適当な値で初期化
    __block NSInteger minFailCount = NSIntegerMax;
    // エラー処理としてありえない座標を指定。
    __block NSUInteger posX = NSUIntegerMax, posY = NSUIntegerMax;
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray* _Nonnull line, NSUInteger idxY, BOOL * _Nonnull stopY) {
        [line enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idxX, BOOL * _Nonnull stopX) {
            
            // NSNullが入っていない座標はスキップ
            if (![obj isMemberOfClass:[NSNull class]]) {
                return;
            }
            
            NSInteger nullCount = 0;
            
            // 列のNSNullの数を追加
            NSMutableSet *rowWithoutNull = [NSMutableSet setWithArray:line];
            [rowWithoutNull removeObject:[NSNull null]];
            nullCount += MAXNUM - rowWithoutNull.count;
            
            // 行のNSNullの数
            NSMutableSet *columnWithoutNull = [NSMutableSet set];
            
            for (int y = 0; y < MAXNUM; y++) {
                [columnWithoutNull addObject:self.numBoard[y][idxX]];
            }
            
            [columnWithoutNull removeObject:[NSNull null]];
            nullCount += MAXNUM - columnWithoutNull.count;
            
            // 3x3マスのNSNullの数
            NSMutableSet *boxWithoutNull = [NSMutableSet set];
            for (int y = 0; y < 3; y++) {
                for (int x = 0; x < 3; x++) {
                    [boxWithoutNull addObject:self.numBoard[3*(idxY/3) + y][3*(idxX/3) + x]];
                }
            }
            
            [boxWithoutNull removeObject:[NSNull null]];
            nullCount += 9 - boxWithoutNull.count;
            
            // 座標確保
            if (nullCount != 0 && minFailCount > nullCount) {
                minFailCount = nullCount;
                posX = idxX;
                posY = idxY;
                
                if (minFailCount == 3) {
                    *stopY = YES;
                    *stopX = YES;
                }
            }
        }];
    }];
    
    // NSNullが存在しなかった場合。巨大な値を返すとバグの原因になる為、全て0に置き換え。
    if (minFailCount == NSIntegerMax) {
        posX = 0;
        posY = 0;
        minFailCount = 0;
    }
    
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithInteger:posX], [NSNumber numberWithInteger:posY], [NSNumber numberWithInteger:minFailCount], nil];
    
    return result;
}

#pragma mark 自身と同じ文字が含まれているか
/**
 3x3マス:
 3x3マスに指定した座標と同じ値があるかをチェックするメソッド
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return 同一な値があればYESを返す
 */
- (BOOL)checkBoxSameNumAtX:(NSInteger)x andY:(NSInteger)y
{
    NSInteger zoneIdxX = (NSInteger)x/3;
    NSInteger zoneIdxY = (NSInteger)y/3;
    
    NSMutableArray *inZoneNum = [@[] mutableCopy];
    
    for (int addY = 0; addY < 3; addY++) {
        for (int addX = 0; addX < 3; addX++) {
            // 自身は除く
            if (!(zoneIdxY*3 + addY == y && zoneIdxX*3 + addX == x)) {
                [inZoneNum addObject:self.numBoard[zoneIdxY*3 + addY][zoneIdxX*3 + addX]];
            }
        }
    }
    
    if ([self.numBoard[y][x] isMemberOfClass:[NSNull class]]) {
        return NO;
    }
    
    return [inZoneNum containsObject:self.numBoard[y][x]];
}

/**
 行:
 指定した座標の行に自身と同じ値があるかをチェックするメソッド
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return 同一な値があればYESを返す
 */
- (BOOL)checkColumnSameNumAtX:(NSInteger)x andY:(NSInteger)y
{
    NSMutableArray *inColumnNum = [@[] mutableCopy];
    
    for (int row = 0; row < MAXNUM; row++) {
        if (row != y) {
            [inColumnNum addObject:self.numBoard[row][x]];
        }
    }

    return [inColumnNum containsObject:self.numBoard[y][x]];
}

#pragma mark 十字削除
/**
 指定された座標の自分を除く上下左右を削除するメソッド
 @param x マスのX座標
 @param y マスのY座標
 */
- (void)crossDeleteX:(NSInteger)x andY:(NSInteger)y
{
    // 横削除
    [self.numBoard[y] enumerateObjectsUsingBlock:^(NSMutableArray* _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != x) {
            self.numBoard[y][idx] = [NSNull null];
        }
    }];
    
    // 縦削除
    for (int column = 0; column < MAXNUM; column++) {
        if (column != y) {
            self.numBoard[column][x] = [NSNull null];
        }
    }
}

@end
