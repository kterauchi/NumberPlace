//
//  Sudoku.h
//
//  Created by Keiichiro on 2016/03/01.
//  Copyright © 2016年 Keiichiro. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 数独の解答をランダムに作成するためのクラス
 */
@interface Sudoku : NSObject
/**
 数独の解答をランダムに生成
 */
- (void)fire;
@end
