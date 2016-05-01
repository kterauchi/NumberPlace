//
//  Sudoku.h
//
//  Created by Keiichiro on 2016/03/01.
//  Copyright © 2016年 Keiichiro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sudoku : NSObject
@property (nonatomic) NSMutableArray *numBoard;

/*
 数独問題をランダムに生成
 */
- (void)fire;
@end
