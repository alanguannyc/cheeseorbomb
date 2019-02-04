//
//  GameScene.swift
//  Cheese
//
//  Created by Alan Guan on 2/2/19.
//  Copyright © 2019 Alan Guan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var ground : SKSpriteNode?
    private var ceiling : SKSpriteNode?
    private var figureNode: SKSpriteNode?
    
    var score : Int = 0
    var scoreLabel : SKLabelNode?
    var finalScore : SKLabelNode?
    var startImage : SKSpriteNode?
    
    var cheeseTimer : Timer?
    var bombTimer : Timer?
    let figureNodeCategory : UInt32 = 0x1 << 1
    let cheeseCategory : UInt32 = 0x1 << 2
    let bombCategory : UInt32 = 0x1 << 3
    let groundandCeilingCategory :UInt32 = 0x1 << 4
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        // Get label node from scene and store it for use later
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        ground = childNode(withName: "ground") as? SKSpriteNode
        ceiling = childNode(withName: "ceiling") as? SKSpriteNode
        
        ground?.physicsBody?.categoryBitMask = groundandCeilingCategory
        ceiling?.physicsBody?.categoryBitMask = groundandCeilingCategory
        
        ground?.physicsBody?.collisionBitMask = figureNodeCategory
        ceiling?.physicsBody?.collisionBitMask = figureNodeCategory
        
        figureNode = childNode(withName: "figureNode") as? SKSpriteNode
        figureNode?.physicsBody?.categoryBitMask = figureNodeCategory
        figureNode?.physicsBody?.contactTestBitMask = cheeseCategory | bombCategory
        figureNode?.physicsBody?.collisionBitMask = groundandCeilingCategory
        CreateRunningAnimation(figureNode!)
        createGrass()
        startTimers()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard scene?.isPaused == false else {
            let touch = touches.first
            if let location = touch?.location(in: self) {
                let playNode = nodes(at: location)
                for node in playNode {
                    if node.name == "play" {
                        gameRestart()
                    }
                }
            }
            return
        }
        figureNode?.physicsBody?.applyForce(CGVector(dx: 0, dy: 10000))

        
    }
    
    func CreateRunningAnimation(_ node: SKSpriteNode){
        var RunningAnimation : [SKTexture] = []
        for number in 1...4 {
            RunningAnimation.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        
        var runningAction = SKAction.animate(with: RunningAnimation, timePerFrame: 0.2)
        var repeatAction = SKAction.repeatForever(runningAction)
        
        node.run(repeatAction)
        
    }
    
    func createGrass(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass.png")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        for number in 0...numberOfGrass {
            let grass = SKSpriteNode(imageNamed: "grass.png")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.categoryBitMask = groundandCeilingCategory
            grass.physicsBody?.collisionBitMask = figureNodeCategory
            grass.physicsBody?.isDynamic = false
            let grassX = -size.width / 2 + grass.size.width / 2 + grass.size.width * CGFloat(number)
            let grassY = -size.height / 2 + grass.size.height / 2
            grass.position = CGPoint(x: grassX, y: grassY)
            addChild(grass)
            
            
            let speed = 100.0
            let move = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number)) / speed)
            let resetPositionAction = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            
            let fullMove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width) / speed)
            
            let repeatAction = SKAction.repeatForever(SKAction.sequence([fullMove, resetPositionAction]))
            
            grass.run(SKAction.sequence([move, resetPositionAction, repeatAction]))
            
            
        }
    }
    
    func CreateCheese() {
        let grass = SKSpriteNode(imageNamed: "grass.png")
        let cheese = SKSpriteNode(imageNamed: "cheese.png")
        cheese.physicsBody = SKPhysicsBody(rectangleOf: cheese.size)
        cheese.physicsBody?.categoryBitMask = cheeseCategory
        cheese.physicsBody?.contactTestBitMask = figureNodeCategory
        cheese.physicsBody?.collisionBitMask = 0
        cheese.physicsBody?.affectedByGravity = false
        cheese.name = "cheese"
        
        let maxHeight = size.height/2 - cheese.size.height/2 - grass.size.height
        let minHeight = -size.height/2 + cheese.size.height/2
        
        let range = maxHeight - minHeight
        let startingX = size.width / 2 + cheese.size.width / 2
        let startingY = maxHeight - CGFloat(arc4random_uniform(UInt32(range)))
        
        cheese.position =  CGPoint(x: startingX, y: startingY)
        addChild(cheese)
        
        let moveLeft = SKAction.moveBy(x: -size.width - cheese.size.width/2, y: 0, duration: 4)
        
        cheese.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func CreateBomb() {
        let grass = SKSpriteNode(imageNamed: "grass.png")
        let bomb = SKSpriteNode(imageNamed: "bomb.png")
        bomb.name = "bomb"
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = figureNodeCategory
        bomb.physicsBody?.collisionBitMask = 0
        bomb.physicsBody?.affectedByGravity = false
        
        
        let maxHeight = size.height/2 - bomb.size.height/2 - grass.size.height
        let minHeight = -size.height/2 + bomb.size.height/2
        
        let range = maxHeight - minHeight
        let startingX = size.width / 2 + bomb.size.width / 2
        let startingY = maxHeight - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position =  CGPoint(x: startingX, y: startingY)
        addChild(bomb)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width/2, y: 0, duration: 4)
        
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    
  
    func didBegin(_ contact: SKPhysicsContact) {
        guard contact.bodyA.categoryBitMask != bombCategory else {
            scene?.isPaused = true
            gameOver()
            return
        }
        
        guard contact.bodyB.categoryBitMask != bombCategory else {
            scene?.isPaused = true
            gameOver()
            return
        }

        score += 1
        scoreLabel?.text = "Score : \(score)"
        
        if contact.bodyA.categoryBitMask == cheeseCategory || contact.bodyA.categoryBitMask == bombCategory {
            contact.bodyA.node?.removeFromParent()
        }
        
        if contact.bodyB.categoryBitMask == cheeseCategory || contact.bodyB.categoryBitMask == bombCategory {
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    
    func createStartButton(){
        startImage = SKSpriteNode(imageNamed: "play.png")
        startImage!.position = CGPoint(x: 0, y: -200)
        startImage?.name = "play"
        if let startbtn = startImage {
            addChild(startbtn)
        }

    }
    
    func createEndingLabel(){
        scoreLabel?.position = CGPoint(x: 0, y: 200)
        scoreLabel?.text = "Final Score:"
        
        finalScore = SKLabelNode(text: "\(score)")
        finalScore?.position = CGPoint(x: 0, y: 0)
        finalScore?.fontSize = 100
        
        if let final = finalScore {
            addChild(final)
        }
        
    }
    
    func gameOver(){
        createStartButton()
        createEndingLabel()
        bombTimer?.invalidate()
        cheeseTimer?.invalidate()
    }
    
    func gameRestart(){
        
        
        for child in self.children {
            
            //Determine Details
            if child.name == "bomb" {
                child.removeFromParent()
            } else if child.name == "cheese" {
                child.removeFromParent()
            }
        }
        scoreLabel?.position = CGPoint(x: -160.5, y: 522.561)
        scoreLabel?.text = "Score: 0"
        scoreLabel?.fontSize = 53.0
        scoreLabel?.fontName = "Herculanum"
        
        finalScore?.removeFromParent()
        startImage?.removeFromParent()
        scene?.isPaused = false
        startTimers()
    }
    
    func startTimers(){
        cheeseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.CreateCheese()
        })
        bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.CreateBomb()
        })
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
