//
//  LevelSelectScene.swift
//  Scrap Yard
//
//  Created by igmstudent on 5/13/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import SpriteKit


class LevelSelectScene: SKScene, SKPhysicsContactDelegate
{
    var gameManager:GameViewController?
    var gameS:GameScene?
    var player = PlayerNode()                   //Player
    var lastUpdateTime: NSTimeInterval = 0      //
    var dt: CGFloat = 0                         //delta time
    var circleIndic = SKShapeNode()     //Indicator of current touch location
    var score = [SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png")]
    var fireRate = CGFloat(0.2)         //Fire rate
    var fireRateCounter = CGFloat(0.0)  //Fire rate counter
    var releaseStop = true              //If the player stops moving when touch ends
    var starCount = 0
    
    //DMTV
    override func didMoveToView(view: SKView)
    {
        //Round play area
        physicsBody = SKPhysicsBody(edgeLoopFromPath: polygonPath(
            384,
            y: 512,
            radius: 350,
            sides: 40))
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        //Add player
        addChild(player)
        
        //Circle indicator
        circleIndic = SKShapeNode(circleOfRadius: 25.0)
        circleIndic.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 500)
        circleIndic.fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        circleIndic.strokeColor = SKColor.clearColor()
        circleIndic.hidden = true
        addChild(circleIndic)
        var num = 0
        for (var i = 0; i < 18; i++)
        {
            switch(i){
            case 0...2: // level 1
                score[i].position = CGPoint(x: 354 + (i * 35), y: 680)
                score[i].zPosition = 20
                score[i].xScale = (0.5)
                score[i].yScale = (0.5)
                addChild(score[i])
            case 3...5: // level 2
                if(i == 3){num = 0}
                score[i].position = CGPoint(x: 590 + (num * 35) , y: 510)
                score[i].zPosition = 20
                score[i].xScale = (0.5)
                score[i].yScale = (0.5)
                addChild(score[i])
                num += 1
            case 6...8: // level 3
                if(i == 6){num = 0}
                score[i].position = CGPoint(x: 590 + (num * 35), y: 288)
                score[i].zPosition = 20
                score[i].xScale = (0.5)
                score[i].yScale = (0.5)
                addChild(score[i])
                num += 1
            case 9...11: // level 4
                if(i == 9){num = 0}
                score[i].position = CGPoint(x: 354 + (num * 35), y: 182)
                score[i].zPosition = 20
                score[i].xScale = (0.5)
                score[i].yScale = (0.5)
                addChild(score[i])
                num += 1
            case 12...14: // level 5
                if(i == 12){num = 0}
                score[i].position = CGPoint(x: 124 + (num * 35), y: 288)
                score[i].zPosition = 20
                score[i].xScale = (0.5)
                score[i].yScale = (0.5)
                addChild(score[i])
                num += 1
            case 15...17: // level 6
                if(i == 15){num = 0}
                score[i].position = CGPoint(x: 124 + (num * 35), y: 510)
                score[i].zPosition = 20
                score[i].xScale = (0.5)
                score[i].yScale = (0.5)
                addChild(score[i])
                num += 1
            default:
                return
                
            }
            
        }
        
        //Backroung ring particle effect
        for(var i = CGFloat(-1); i < 2; i += 2)
        {
            let ring = RotateNode(
                texture: SKTexture(imageNamed: "Ring Cloud"),
                size: CGSize(width: 768, height: 768),
                rotSpeed: i * π / 8)
            ring.name = "ring"
            ring.position = center
            ring.size = CGSize(width: 768, height: 768)
            ring.zPosition = -2
            ring.alpha = 0.5
            addChild(ring)
        }
        
        //Backgroud
        let bg = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
        bg.position = center
        bg.zPosition = -10
        bg.size = CGSize(width: 768, height: 1024)
        addChild(bg)
        
        //Set fonts
        enumerateChildNodesWithName( "Label", usingBlock:
            { node, _ in
                if let customNode = node as? SKLabelNode
                {
                    customNode.fontName = "Renegado"
                }
        })
        
        //DMTS all children in scene
        enumerateChildNodesWithName( "//*", usingBlock:
            { node, _ in
                if let customNode = node as? CustomNodeEvents
                {
                    customNode.didMoveToScene()
                }
        })
        
        //Set the label of the current control system
        //setControlLabel()
        
        //Set starting description alphas
        if let customNode = childNodeWithName("des_1") as? SKLabelNode
        {
            customNode.alpha = 0.0
        }
        if let customNode = childNodeWithName("des_2") as? SKLabelNode
        {
            customNode.alpha = 0.0
        }
    }
    
    //Touches began
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //Set circle and player to match touch
        for touch in touches
        {
            let location = touch.locationInNode(self)
            circleIndic.position = location
            circleIndic.hidden = false      //Reveal circle while touching
            player.setPosAndRot(location)
        }
    }
    
    //Touches moved
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //Set circle and player to match touch
        for touch in touches
        {
            let location = touch.locationInNode(self)
            circleIndic.position = location
            player.setPosAndRot(location)
        }
    }
    
    //Touches ended
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //Fire after release
        if(fireRateCounter < 0)
        {
            fireRateCounter = fireRate
            addProjectile(player.position)
        }
        
        if(releaseStop)
        {
            //Hide circle and stop player
            circleIndic.hidden = true
            player.targetAngle = player.currentAngle
        }
    }
    
    //Update
    override func update(currentTime: CFTimeInterval)
    {
        //Set delta time
        if(lastUpdateTime > 0)
        {
            dt = CGFloat(currentTime - lastUpdateTime)
        }
        else
        {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        //fireRate update
        fireRateCounter -= dt
        
        //Update all objects
        enumerateChildNodesWithName( "//*", usingBlock:
            { node, _ in
                if let customNode = node as? CustomNodeEvents
                {
                    customNode.update(self.dt)
                }
        })
        
        //Kill projectiles
        enumerateChildNodesWithName( "//*", usingBlock:
            { node, _ in
                if let customNode = node as? ProjectileNode
                {
                    if(customNode.isDisabled())
                    {
                        customNode.removeFromParent()
                    }
                }
        })
        
        starCount = 0
        enumerateChildNodesWithName("//*", usingBlock: {
        node, _ in
        if let customNode = node as? ButtonNode
        {
            let stars:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(self.starCount / 3 + 1)_stars")
            
            for(var i = 0; i < 3; i++)
            {
                self.score[i + self.starCount].hidden = true
            }
            
            for(var i = 0; i < 3; i++)
            {
                self.score[i + self.starCount].hidden = i >= stars!
            }
            
            self.starCount += 3
        }
    })
    
    }
    //Triggers when a collision occurs
    func didBeginContact(contact: SKPhysicsContact)
    {
        var currentLevel:Int
        //Enforce what bodyA and bodyB are.
        let bodyA = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyA : contact.bodyB
        let bodyB = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyB : contact.bodyA
        
        //Collision int
        let collision = bodyA.categoryBitMask | bodyB.categoryBitMask
        
        //Destroy projectile after junk or edge collisioncollision
        if
            collision == PhysicsCategory.Proj | PhysicsCategory.Junk ||
                collision == PhysicsCategory.Proj | PhysicsCategory.Edge
        {
            (bodyB.node as! ProjectileNode).disabled = true;
            if collision == PhysicsCategory.Proj | PhysicsCategory.Junk
            { 
                runAction(SKAction.playSoundFileNamed("hit_1.wav", waitForCompletion: false))
                if (bodyA.node as! ButtonNode).name == "1" 
                {
                    currentLevel = 1
                    let starsSaved:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
                    if(starsSaved != nil && starsSaved != 0)
                    {
                        gameManager?.loadGameScene(1, releaseStop: releaseStop, win: true)
                    }
                
                }
                if (bodyA.node as! ButtonNode).name == "2"
                {
                    currentLevel = 2
                    let starsSaved:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
                    if(starsSaved != nil && starsSaved != 0)
                    {
                        gameManager?.loadGameScene(2, releaseStop: releaseStop, win: true)
                    }
                }
                if (bodyA.node as! ButtonNode).name == "3"
                {
                    currentLevel = 3
                    let starsSaved:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
                    if(starsSaved != nil && starsSaved != 0)
                    {
                        gameManager?.loadGameScene(3, releaseStop: releaseStop, win: true)
                    }
                }
                if (bodyA.node as! ButtonNode).name == "4"
                {
                    currentLevel = 4
                    let starsSaved:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
                    if(starsSaved != nil && starsSaved != 0)
                    {
                        gameManager?.loadGameScene(4, releaseStop: releaseStop, win: true)
                    }
                }
                if (bodyA.node as! ButtonNode).name == "5"
                {
                    currentLevel = 5
                    let starsSaved:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
                    if(starsSaved != nil && starsSaved != 0)
                    {
                        gameManager?.loadGameScene(5, releaseStop: releaseStop, win: true)
                    }
                }
                if (bodyA.node as! ButtonNode).name == "6"
                {
                    currentLevel = 6
                    let starsSaved:Int? = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
                    if(starsSaved != nil && starsSaved != 0)
                    {
                        gameManager?.loadGameScene(6, releaseStop: releaseStop, win: true)
                    }
                }
                
            }
        }
    }
    
    //Start a new game
    func newGame()
    {
        gameManager!.loadGameScene(4, releaseStop: releaseStop, win: true)
    }
    
    
    
    //Add a projectile to the scene
    func addProjectile(position: CGPoint)
    {
        let projectile = ProjectileNode(position: position)
        self.addChild(projectile)
        projectile.didMoveToScene()
        runAction(SKAction.playSoundFileNamed("m_fury.wav", waitForCompletion: false))
    }
}
