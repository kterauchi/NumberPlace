//
//  Sudoku.m
//  numBoard
//
//  Created by Keiichiro on 2016/03/01.
//  Copyright © 2016年 Keiichiro. All rights reserved.
//

#import "Sudoku.h"

@interface Sudoku()

@end

@implementation Sudoku

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初期化
        self.numBoard = [@[] mutableCopy];
        for (int i = 0; i < 9; i++) {
            self.numBoard[i] = [@[] mutableCopy];
        }
        
        // 一旦nullで埋める
        for (int y = 0; y < 9; y++) {
            for (int x = 0; x < 9; x++) {
                self.numBoard[y][x] = [NSNull null];
            }
        }
    }
    return self;
}

#pragma mark - Public Methods
- (void)fire
{
    [self allFill];
    
    [self show];
    
}

#pragma mark - Private Methods
/*
 とりあえず全マス埋めるメソッド
 */
- (void)allFill
{
    __block NSInteger num;
    [self.numBoard enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        num = arc4random_uniform(9) + 1;

        for (int i = 0; i < 9; i++) {
            line[i] = [NSNumber numberWithInteger:num];
            num = ++num > self.numBoard.count ? 1 : num;
        }
        
        self.numBoard[idx] = line;
    }];
}

/*
 マスを表示
 */
- (void)show
{
    [self.numBoard enumerateObjectsUsingBlock:^(NSArray* _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [line enumerateObjectsUsingBlock:^(NSNumber* _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
            printf("%ld ", (long)[num integerValue]);
            
            if (idx == line.count -1) {
                printf("\n");
            }
        }];
    }];
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
