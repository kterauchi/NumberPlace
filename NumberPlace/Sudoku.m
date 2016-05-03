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
        [self allRandomFill];

//        [self show];
//        printf("\n");
        
        NSArray *result = [self checkAllCountNull];
        
        // NSNullの個数が0になっていれば、処理を打ち切る。
        if ([result[2] integerValue] == 0) {
            break;
        }
        
        [self crossDeleteX:[result[0] integerValue] andY:[result[1] integerValue]];
    }
    
    [self show];
    
    printf("----End----\n");
    NSLog(@"\n計%d回で完成", count);
    
//    NSLog(@"\n----End----");
}

#pragma mark - Private Methods
/**
 とりあえず全マス埋めるメソッド
 */
- (void)allFill
{
    __block NSInteger num;
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        num = arc4random_uniform(MAXNUM) + 1;

        for (int i = 0; i < MAXNUM; i++) {
            line[i] = [NSNumber numberWithInteger:num];
            num = ++num > self.numBoard.count ? 1 : num;
        }
        
        self.numBoard[idx] = line;
    }];
}

/**
 全てのマスをランダムで埋めるメソッド
 */
- (void)_allRandomFill
{
    __block NSInteger num;
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {

        NSMutableSet *temSet = [NSMutableSet set];
        for (int i = 0; i < MAXNUM; i++) {
            
            do {
                num = arc4random_uniform(MAXNUM) + 1;
            } while ([temSet containsObject:[NSNumber numberWithInteger:num]]);
            
            [temSet addObject:[NSNumber numberWithInteger:num]];
            line[i] = [NSNumber numberWithInteger:num];
            
        }
        self.numBoard[idx] = line;
    }];
}

/**
 全てのマスをランダムで埋めるメソッド
 */
- (void)__allRandomFill
{
    __block NSInteger num;
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // スキップ処理
        if (![line containsObject:[NSNull null]]) {
            return;
        }
        
        NSMutableSet *temSet = [NSMutableSet setWithArray:line];
        for (int i = 0; i < MAXNUM; i++) {
            
            // スキップ処理
            if (![line[i] isMemberOfClass:[NSNull class]]) {
                continue;
            }
            
            do {
                num = arc4random_uniform(MAXNUM) + 1;
            } while ([temSet containsObject:[NSNumber numberWithInteger:num]]);
            
            [temSet addObject:[NSNumber numberWithInteger:num]];
            line[i] = [NSNumber numberWithInteger:num];
            
        }
        self.numBoard[idx] = line;
    }];
}

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
//                line[idxX] = [NSNumber numberWithInteger:num];
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
 全マスに対し、破綻が起きていないかチェックをするメソッド
 */
- (void)_checkAll
{
    // 二次元配列の初期化
    __block NSMutableArray *flag = [@[] mutableCopy];
    for (int i = 0; i < MAXNUM/3; i++) {
        flag[i] = [@[] mutableCopy];
    }
    
    // 各ゾーンで破綻していないか事前チェック // 全探索の省略
    for (int y = 0; y < MAXNUM/3; y++) {
        for (int x = 0; x < MAXNUM/3; x++) {
            flag[y][x] = [NSNumber numberWithBool:[self checkBoxIndexX:x andY:y]];
        }
    }
    
    // 判定開始。破綻は最大2。そのため、事前にゾーンチェックをし、該当した場合のみ、行チェックを行う。
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray* _Nonnull line, NSUInteger idxY, BOOL * _Nonnull stop) {
        [line enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull num, NSUInteger idxX, BOOL * _Nonnull stop) {
            // 自身のゾーンが破綻していなければスキップ
            if (flag[idxY/3][idxX/3]) {
                return;
            }
            
            [self checkColumn:idxX];
            NSLog(@"破綻がないマスはX:%ld Y:%ld\n", idxX, idxY);
        }];
    }];
}

/**
 全マスに対し、行、列、3x3の範囲に何こNSNullがあるかを求め、最小のマス(より完成しているマス)の座標とNSNullの個数を返す
 @return NSArray[3] X軸, Y軸, NSNullの数。 全てのマスでNSNullがなければ、全て0を返す。
 */
// タプル使いたい…
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
    
    // 巨大な値を返すとバグの原因になる為、全て0に置き換え。
    if (minFailCount == NSIntegerMax) {
        posX = 0;
        posY = 0;
        minFailCount = 0;
    }
    
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithInteger:posX], [NSNumber numberWithInteger:posY], [NSNumber numberWithInteger:minFailCount], nil];
    
    return result;
}

#pragma mark 破綻判定ロジック
/**
 3x3マスのチェック(3x3で区切られたZoneIndexを入力)
 @param idxX ゾーンのX軸方向のindex
 @param idxY ゾーンのY軸方向のindex
 @return チェック結果が問題なかった時YESを返す
 */
- (BOOL)checkBoxIndexX:(NSInteger)idxX andY:(NSInteger)idxY
{
    NSMutableSet *delOverlapNumSet = [NSMutableSet set];
    
    for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
            [delOverlapNumSet addObject:self.numBoard[idxY*3 + y][idxX*3 + x]];
        }
    }
    
    NSLog(@"X:%ld Y:%ld 合計:%lu", idxX, idxY, delOverlapNumSet.count);
    
    if (delOverlapNumSet.count == 9) {
        return YES;
    }else{
        return NO;
    }
}

/**
 3x3マスのチェック(座標を直接入力)
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return チェック結果が問題なかった時YESを返す
 */
- (BOOL)checkBoxAtX:(NSInteger)x andY:(NSInteger)y
{
    NSInteger zoneIdxX = (NSInteger)x/3;
    NSInteger zoneIdxY = (NSInteger)y/3;
    
    return [self checkBoxIndexX:zoneIdxX andY:zoneIdxY];
}

/**
 列チェック // 値入力の段階で重複しない数を入れているので、事実上使われない。
 @return チェック結果が問題なかった時YESを返す
 */
- (BOOL)checkRow
{
    
    return YES;
}

/**
 行チェック
 @param x チェックする行のX座標を受け取る
 @return チェック結果が問題なかった時YESを返す
 */
- (BOOL)checkColumn:(NSInteger)x
{
    NSMutableSet *delOverlapNumSet = [NSMutableSet set];

    for (int y = 0; y < MAXNUM; y++) {
        [delOverlapNumSet addObject:self.numBoard[y][x]];
    }
    
//    NSLog(@"\n%ld行チェック 合計:%lu", x, delOverlapNumSet.count);
    if (delOverlapNumSet.count == MAXNUM) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 指定した文字が含まれているか
/**
 3x3マス:
 3x3マスに指定した座標と同じ値があるかをチェックするメソッド
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return 同一な値があればYESを返す
 */
- (BOOL)_checkBoxSameNumAtX:(NSInteger)x andY:(NSInteger)y
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
 列: *未使用のため、未実装*
 指定した座標の列に自身と同じ値があるかをチェックするメソッド
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return 同一な値があればYESを返す
 */
- (BOOL)_checkRowSameNumAtX:(NSInteger)x andY:(NSInteger)y
{
    
    return YES;
}

/**
 行:
 指定した座標の行に自身と同じ値があるかをチェックするメソッド
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return 同一な値があればYESを返す
 */
- (BOOL)_checkColumnSameNumAtX:(NSInteger)x andY:(NSInteger)y
{
    NSMutableArray *inColumnNum = [@[] mutableCopy];
    
    for (int row = 0; row < MAXNUM; row++) {
        if (row != y) {
            [inColumnNum addObject:self.numBoard[row][x]];
        }
    }
    
    return [inColumnNum containsObject:self.numBoard[y][x]];
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
 列: *未使用のため、未実装*
 指定した座標の列に自身と同じ値があるかをチェックするメソッド
 @param x X軸方向の座標
 @param y Y軸方向の座標
 @return 同一な値があればYESを返す
 */
- (BOOL)checkRowSameNumAtX:(NSInteger)x andY:(NSInteger)y
{
    
    return YES;
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

#pragma mark - memo
-(void)memo
{
//    int nilCount;       // nilカウント
//    int index[3][9][9]; // 破綻数、座標index
    
    /* step0. ルールに則って配列にランダムで数字を入れる */
    // 1. 横列に同一の数字がないか。
    //    if 同じ数字があれば現在の値+1を循環しつつ実施。continue。
    
    // 2. 縦列に同一の数字がないか。
    //    if 同じ数字があれば現在の値+1を循環しつつ実施。continue。
    
    // 3. 3x3マスで同一の値がないか。
    //    if (BOOL == YES) 配列に挿入。(BOOL == NO)
    
    // 4. BOOLの合計を求める。合計が1であれば、break。それ以外はnilカウントアップ
    
    // 5. nilカウントが0であれば、完成。そうでなければnilカウントをリセットして続きへ
    
    /* step1. 破綻を検索。破綻があった場合、破綻数1であれば即打ち切り。破綻数2以上であれば、破綻数と座標を確保 */
    /* 　　　　より破綻数が少ないものが出た場合、座標などを上書き */
    /* 判定開始 */
    // 1. 横列に同一の数字がないか。BOOLで返す。
    
    // 2. 縦列に同一の数字がないか。BOOLで返す。
    
    // 3. 3x3マスで同一の値がないか。BOOLで返す。
    
    // 4. 破綻数が1であればbreak。
    
    // 4-1. 全ての数字を入れることが出来なかった場合、強引にランダムな数字を入れる。
    
    // 4-2. 重複した数字を消す。
    
    arc4random_uniform(9);
}
@end
