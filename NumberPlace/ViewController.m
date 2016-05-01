//
//  ViewController.m
//  NumberPlace
//
//  Created by Keiichiro on 2016/05/01.
//  Copyright © 2016年 Keiichiro. All rights reserved.
//

#import "ViewController.h"
#import "Sudoku.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Sudoku *sudoku = [[Sudoku alloc]init];
    // 数独問題をランダムに生成、表示
    [sudoku fire];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
