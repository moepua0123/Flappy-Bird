//
//  ViewController.swift
//  FlappyBird
//
//  Created by 西山萌花 on 2020/06/13.
//  Copyright © 2020 moeka.nishiyama. All rights reserved.
//

import UIKit
import SpriteKit
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // SKViewに型を変換する
        let skView = self.view as! SKView
        
        // FPSプロパティは画面が1秒間に何回更新されているかを示すFPSを画面の右下に表示させる
        skView.showsFPS = true
        
    //ノードの数を表示する　showsNodeCountプロパティはノードが幾つ表示されているかを画面の右下に表示させる
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size) // ←GameSceneクラスに変更する
        
        // ビューにシーンを表示する
        skView.presentScene(scene)
    }
    
    //ステータスバーを非表示
    override var prefersStatusBarHidden: Bool {
    get {
        return true
    }
    }
}

