//
//  GameScene.swift
//  FlappyBird
//
//  Created by 西山萌花 on 2020/06/13.
//  Copyright © 2020 moeka.nishiyama. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    //node=アニメーションや物体を表示させる役割
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var itemNode:SKNode!//追加
    
    // 衝突判定カテゴリー　32桁のどこに1があるかで衝突相手を判断する
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemScoreCategory: UInt32 = 1 << 4//追加
   //壁の間に見えないものをおいて、通過したと判断してスコアを入れる↑
    
    // スコア用
    var score = 0
    var itemScore = 0//追加
    
    //画面上部にスコアを表示するもためのもの
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!//追加
    
    //スコア保存のためのUserDefaultsを取得
    let userDefaults:UserDefaults = UserDefaults.standard
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        // スクロールするスプライトの親ノード→ゲームオーバーになった時画面を一括で止めるため
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //アイテム用のノード
        itemNode = SKNode()
        scrollNode.addChild(itemNode)//追加
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        setupScoreLabel() //スコア表示のため
    }
    
    // 画面をタップした時に鳥を上方向に動かす
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero

            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
    }
        
    func setupGround() {
        // 地面の画像を読み込む　//groundを指定
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        //(画像荒いけど処理早い)
        
        //(スプライトは、コンピュータの処理の負荷を上げずに早く画像を処理するもの)
        // *テクスチャを指定してスプライトを作成する
        //let groundSprite = SKSpriteNode(texture: groundTexture)
        
        // 必要な枚数を計算 //追加する枚数を増やす
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成 //ここに問題？duration変更
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            // スプライトの表示する位置を指定する（position)
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            //70~地面にぶつかるようにする
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            // スプライトを追加する
            scrollNode.addChild(sprite)
            // *シーンにスプライトを表示
            //addChild(groundSprite)
        }
    }
    
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3
        
        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥
            
            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            wall.addChild(under)
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory

            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory

            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false

            wall.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            wall.addChild(scoreNode)
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        //以下カテゴリー設定
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false

        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
   
    func setupItem() {
        // 壁の画像を読み込む
        let itemTexture = SKTexture(imageNamed: "ground")
        itemTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveitem = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        
        // 自身を取り除くアクションを作成
        let removeitem = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([moveitem, removeitem])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3
        
        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_item_lowest_y = center_y - slit_length / 2 - itemTexture.size().height / 2 - random_y_range / 2
        
        // 壁を生成するアクションを作成
        let createitemAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0)
            item.zPosition = -50 // 雲より手前、地面より奥
            
            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_item_y = under_item_lowest_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: itemTexture)
            under.position = CGPoint(x: 0, y: under_item_y)
            
            item.addChild(under)
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
            under.physicsBody?.categoryBitMask = self.itemScoreCategory

            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: itemTexture)
            upper.position = CGPoint(x: 0, y: under_item_y + itemTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
            upper.physicsBody?.categoryBitMask = self.itemScoreCategory

            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false

            item.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            item.addChild(scoreNode)
            item.run(itemAnimation)
            
            self.wallNode.addChild(item)
        })

        
        
    }
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    //didBegin(_:)メソッド=衝突時に呼ばれる

    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない（壁にあったあとに地面にも必ず衝突するのでそこで2度めの処理を行わないようにするため）
        if scrollNode.speed <= 0 {
            return
        }
    //bodyAbodyBで何と何が衝突したか判定
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
        // スコア用の物体と衝突した{
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)" //スコアラベルの表示
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)" //スコアラベルの表示
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
        }else if (contact.bodyA.categoryBitMask & itemScoreCategory) == itemScoreCategory || (contact.bodyB.categoryBitMask & itemScoreCategory) == itemScoreCategory {
            //アイテムに衝突した
            print("ItemGet")
            itemScore += 1
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
        
            //itemPlayer?.play()
            
            if (contact.bodyA.categoryBitMask & itemScoreCategory) == itemScoreCategory {
            contact.bodyA.node?.removeFromParent()
            }
            if (contact.bodyB.categoryBitMask & itemScoreCategory) == itemScoreCategory {
            contact.bodyB.node?.removeFromParent()
            }
            
        } else {
            // 壁か地面と衝突した
            print("GameOver")

            // スクロールを停止させる
            //speedはアクションのはやさを示すプロパティ
            scrollNode.speed = 0

        //collisionBitMaskをgroundCategoryだけにして壁とは衝突しないようにする＝壁とぶつかった時に地面まで落ちるようにする
            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0

        wallNode.removeAllChildren()

        bird.speed = 1
        scrollNode.speed = 1
    }
    //スコアラベルの表示
    func setupScoreLabel() {
           score = 0
           scoreLabelNode = SKLabelNode()
           scoreLabelNode.fontColor = UIColor.black
           scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
           scoreLabelNode.zPosition = 100 // 一番手前に表示する
           scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
           scoreLabelNode.text = "Score:\(score)"
           self.addChild(scoreLabelNode)

           bestScoreLabelNode = SKLabelNode()
           bestScoreLabelNode.fontColor = UIColor.black
           bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
           bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
           bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left

           let bestScore = userDefaults.integer(forKey: "BEST")
           bestScoreLabelNode.text = "Best Score:\(bestScore)"
           self.addChild(bestScoreLabelNode)
        
           itemScore = 0
           itemScoreLabelNode = SKLabelNode()
           itemScoreLabelNode.fontColor = UIColor.black
           itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
           itemScoreLabelNode.zPosition = 100 // 一番手前に表示する
           itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
           itemScoreLabelNode.text = "Item Score:\(itemScore)"
           self.addChild(itemScoreLabelNode)
        
       }
}
