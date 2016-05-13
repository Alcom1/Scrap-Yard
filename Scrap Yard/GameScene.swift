import SpriteKit

struct PhysicsCategory
{
    static let None: UInt32 = 0
    static let Edge: UInt32 = 0b1
    static let Junk: UInt32 = 0b10
    static let Proj: UInt32 = 0b100
    static let Foll: UInt32 = 0b1000
}

protocol CustomNodeEvents
{
    func didMoveToScene()
    func update(dt: CGFloat)
}

protocol EscapeEvents
{
    func isOut() -> Bool
    func hasEscaped() -> Bool
    func boost()
}

protocol FollowEvents
{
    func setFollowTarget(pos: CGPoint)
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var gameManager:GameViewController?
    var currentLevel: Int = 0                   //Current level
    var player = PlayerNode()                   //Player
    var circles = [
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png"),
        SKSpriteNode(imageNamed: "star.png")]
    var lastUpdateTime: NSTimeInterval = 0
    var dt: CGFloat = 0                         //delta time
    var totalTime = CGFloat(0)                  //Total time that has passed
    var rectTime = SKShapeNode()            //Bar indicating remaining time
    var circleIndic = SKShapeNode()         //Indicator of current touch location
    var victoryBG1 = SKShapeNode()          //Background for victory screen
    var victoryBG2 = SKShapeNode()          //Lower background for victory screen
    var victoryText = SKLabelNode()
    var resetButtonBase = SKShapeNode()     //Base of the reset button
    var resetButtonCent = SKShapeNode()     //Center of the reset button
    var resetText = SKLabelNode()           //Reset button label
    
    var fireRate = CGFloat(0.2)         //Fire rate
    var fireRateCounter = CGFloat(0.0)  //Fire rate counter
    
    var losesCur = 0
    var losesMax = 3
    
    var end = false                     //If level has ended
    var releaseStop = true              //If the player stops moving when touch ends
    var pauseFix = false                //Hax bool to prevent massive jump after unpausing.
    var flicker = false                 //True if flickering effect should trigger.
    var resetPress = false              //True if the reset button has been pressed, unrelated to release
    
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
        
        //Time bar
        rectTime = SKShapeNode(
            rect: CGRect(
                origin: CGPoint(x: 360, y: 0),
                size: CGSize(
                    width: 480.0,
                    height: 45.0)))
        rectTime.name = "rectTime"
        rectTime.zPosition = -5
        rectTime.position = CGPoint(x : -216, y : 951)
        rectTime.fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
        rectTime.strokeColor = SKColor.clearColor()
        addChild(rectTime)
        
        //Circle indicator
        circleIndic = SKShapeNode(circleOfRadius: 25.0)
        circleIndic.position = CGPoint(x: 384, y: 512)
        circleIndic.zPosition = 50;
        circleIndic.fillColor = SKColor.clearColor()
        circleIndic.lineWidth = 5
        circleIndic.strokeColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        circleIndic.hidden = true
        addChild(circleIndic)
        
        //Victory background
        victoryBG1 = SKShapeNode(rectOfSize: CGSize(width: 400, height: 150), cornerRadius: 40)
        victoryBG1.position = CGPoint(x: 384, y: 512)
        victoryBG1.zPosition = 15
        victoryBG1.fillColor = SKColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        victoryBG1.alpha = 0
        victoryBG1.strokeColor = SKColor.clearColor()
        addChild(victoryBG1)
        
        //Victory background 2
        victoryBG2 = SKShapeNode(rectOfSize: CGSize(width: 580, height: 100), cornerRadius: 40)
        victoryBG2.position = CGPoint(x: 384, y: 410)
        victoryBG2.zPosition = 16
        victoryBG2.fillColor = SKColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        victoryBG2.alpha = 0
        victoryBG2.strokeColor = SKColor.clearColor()
        addChild(victoryBG2)
        
        //Text upon win
        victoryText = SKLabelNode(text: "Victory!")
        victoryText.position = CGPoint(x: 384, y: 382)
        victoryText.zPosition = 17
        victoryText.fontName = "Renegado"
        victoryText.fontSize = 96
        victoryText.fontColor = SKColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        victoryText.alpha = 0
        addChild(victoryText)
        
        //Yellow circles
        for (var i = 0; i < 3; i++)
        {
            circles[i].position = CGPoint(x: 725, y: 155 - i * 55)
            circles[i].zPosition = 20
            circles[i].xScale = (0.6)
            circles[i].yScale = (0.6)
            addChild(circles[i])
        }
        
        //Reset button
        resetButtonBase = SKShapeNode(rectOfSize: CGSize(width: 80, height: 80), cornerRadius: 40)
        resetButtonBase.position = CGPoint(x: 60, y: 90)
        resetButtonBase.fillColor = SKColor.init(red: 0.60, green: 0.15, blue: 0.15, alpha: 1.0)
        resetButtonBase.strokeColor = SKColor.clearColor()
        addChild(resetButtonBase)
        
        resetButtonCent = SKShapeNode(rectOfSize: CGSize(width: 65, height: 65), cornerRadius: 40)
        resetButtonCent.position = CGPoint(x: 60, y: 90)
        resetButtonCent.fillColor = SKColor.init(red: 0.70, green: 0.2, blue: 0.2, alpha: 1.0)
        resetButtonCent.strokeColor = SKColor.clearColor()
        addChild(resetButtonCent)
        
        resetText = SKLabelNode(text: "RESET")
        resetText.position = CGPoint(x: 62, y: 28)
        resetText.fontName = "Renegado"
        resetText.fontSize = 24
        resetText.fontColor = SKColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        addChild(resetText)
        
        //Backround ring particle effect
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
            ring.alpha = 0.0
            addChild(ring)
        }
        
        //Victory ring for victorious victory
        let ring3 = SKSpriteNode(texture: SKTexture(imageNamed: "ring_comp"))
        ring3.name = "ring3"
        ring3.position = center
        ring3.size = CGSize(width: 768, height: 768)
        ring3.alpha = 0
        addChild(ring3)
        
        //Backgroud
        let bg = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
        bg.position = center
        bg.zPosition = -10
        bg.size = CGSize(width: 768, height: 1024)
        addChild(bg)
        
        //DMTS all custom nodes in scene
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.didMoveToScene()
            }
        })
        
        setContainmentLabel("Containment: In Progress", color: SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))
    }
    
    //Touches began
    override func touchesBegan          (touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //Set circle and player to match touch
        for touch in touches
        {
            let location = touch.locationInNode(self)
            circleIndic.position = location
            circleIndic.hidden = false      //Reveal circle while touching
            player.setPosAndRot(location)
            
            if((location - resetButtonBase.position).length() < 70)
            {
                resetPress = true
            }
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
        
        //If touch was pressed and released on the reset button, reset the current level
        for touch in touches
        {
            let location = touch.locationInNode(self)
            
            print((location - resetButtonBase.position).length())
            if(resetPress && (location - resetButtonBase.position).length() < 70)
            {
                newGame(false)
            }
        }
    }
   
    //Update
    override func update(currentTime: CFTimeInterval)
    {
        //Unpause jump fix
        if(pauseFix)
        {
            pauseFix = false
            lastUpdateTime = currentTime
        }
        
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
        totalTime += dt
        
        //fireRate update
        fireRateCounter -= dt
        
        if(totalTime > 1)
        {
            //Victory after 20s
            if(totalTime - 1 > 20.0)
            {
                win()
            }
            
            if(!end)
            {
                //fade rings
                enumerateChildNodesWithName( "ring", usingBlock:
                { node, _ in
                    node.alpha = (self.totalTime - 1) / 26.7
                })
                
                //resize time bar
                rectTime.xScale = (21 - totalTime) / 20
                rectTime.position.x = 384 - 600 * (21 - totalTime) / 20
            }
            else
            {
                if(circles[0].xScale < 1.4)
                {
                    for (var i = 0; i < 3; i++)
                    {
                        circles[i].xScale += circles[i].xScale * 0.85 * dt
                        circles[i].yScale += circles[i].yScale * 0.85 * dt
                    }
                }
            }
        }
        
        //Update all objects
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.update(self.dt)
            }
        })
        
        //Set all follower targets
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? FollowEvents
            {
                customNode.setFollowTarget(self.player.position)
            }
        })
        
        //Check Positions of escapers
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? EscapeEvents
            {
                if(customNode.isOut() && !customNode.hasEscaped())
                {
                    customNode.boost()
                    self.losesCur += levelCurve[self.currentLevel - 1]
                    self.setCirclesVisibility()
                    if(self.losesCur >= self.losesMax)
                    {
                        self.lose()
                    }
                    else
                    {
                        self.flicker = true;
                    }
                }
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
        
        //Flicker
        if(flicker)
        {
            flicker = false;
            enumerateChildNodesWithName( "ring", usingBlock:
            { node, _ in
                node.alpha -= 0.3
                if(node.alpha < 0)
                {
                    node.alpha = 0
                }
            })
        }
    }
    
    //Set the visibility of the circles
    func setCirclesVisibility()
    {
        for(var i = 0; i < 3; i++)
        {
            circles[i].hidden = i < losesCur
        }
    }
    
    //Triggers when a collision occurs
    func didBeginContact(contact: SKPhysicsContact)
    {
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
            }
        }
    }
    
    //Lose
    func lose()
    {
        if(end)
        {
            return
        }
        end = true
        
        rectTime.fillColor = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)  //Color time bar red
        setContainmentLabel("Containment: Failed!", color: SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        
        //Wait and reset level
        let wait = SKAction.waitForDuration(2.0)
        let newGame = SKAction.runBlock({self.newGame(false)})
        runAction(SKAction.sequence([wait, newGame]))
        
        //Fadeout ring
        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.5)
        enumerateChildNodesWithName( "ring", usingBlock:
        { node, _ in
            node.runAction(fadeOut)
        })
        enumerateChildNodesWithName( "ring2", usingBlock:
        { node, _ in
            node.alpha = 0.5
            node.runAction(fadeOut)
        })
        
        //Boost escapers (Whee!)
        enumerateChildNodesWithName( "escaper", usingBlock:
        { node, _ in
            if let customNode = node as? EscapeNode
            {
                customNode.boost()
            }
        })
        
        //Disable ring collision
        physicsBody!.categoryBitMask = PhysicsCategory.None
    }
    
    //Win
    func win()
    {
        if(end)
        {
            return
        }
        end = true
        
        let stars = losesMax - losesCur
        
        //Save stars
        let starsSaved = NSUserDefaults.standardUserDefaults().integerForKey("level\(currentLevel)_stars")
        
        if(stars > starsSaved)
        {
            NSUserDefaults.standardUserDefaults().setInteger(stars, forKey: "level\(currentLevel)_stars")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
            
        currentLevel++
        
        setContainmentLabel("Containment: Sucessful!", color: SKColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0))
        
        //Wait and reset level
        let wait = SKAction.waitForDuration(1.5)
        let newGame = SKAction.runBlock({self.newGame(true)})
        runAction(SKAction.sequence([wait, newGame]))
        
        //Statis ring fade in
        enumerateChildNodesWithName( "ring3", usingBlock:
        { node, _ in
            node.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.05))
        })
        
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.75)
        victoryBG1.runAction(fadeIn)
        victoryBG2.runAction(fadeIn)
        victoryText.runAction(fadeIn)
        if(stars != 1)
        {
            victoryText.text = "\(stars) STARS!"
        }
        else
        {
            victoryText.text = "\(stars) STAR!"
        }
            
        //Stop escapers!
        enumerateChildNodesWithName( "escaper", usingBlock:
        { node, _ in
            if let customNode = node as? EscapeNode
            {
                customNode.active = false
                customNode.physicsBody!.collisionBitMask = 0
                customNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                customNode.physicsBody!.allowsRotation = false
                customNode.physicsBody!.angularVelocity = 0
            }
        })
        
        //Stars display
        let split = 125
        for(var i = 0; i < 3; i++)
        {
            let moveX = -341 + split * i - (5 - stars) * split / 2
            let moveY = 362 + i * 55
            let shift = SKAction.moveBy(
                CGVector(
                    dx: moveX,
                    dy: moveY),
                duration: 1.0)
            circles[i].runAction(shift)
        }
    }
    
    //Start a new game
    func newGame(win: Bool)
    {
        gameManager?.loadGameScene(currentLevel, releaseStop: releaseStop, win: win)
    }
    
    //Add a projectile to the scene
    func addProjectile(position: CGPoint)
    {
        let projectile = ProjectileNode(position: position)
        self.addChild(projectile)
        projectile.didMoveToScene()
        runAction(SKAction.playSoundFileNamed("m_fury.wav", waitForCompletion: false))
    }
    
    func setContainmentLabel(label: String, color: SKColor)
    {
        //DMTS all children in scene
        enumerateChildNodesWithName( "label_cont", usingBlock:
        { node, _ in
            if let customNode = node as? SKLabelNode
            {
                customNode.text = label
                customNode.fontColor = color
            }
        })
    }
    
    //Set pause
    var gameLoopPaused : Bool = true
    {
        didSet
        {
            if gameLoopPaused
            {
                runPauseAction()
            }
            else
            {
                runUnpauseAction()
            }
        }
    }
    
    //Pause action
    func runUnpauseAction()
    {
        self.view?.paused = false
        self.pauseFix = true
        self.physicsWorld.speed = 1.0
    }
    
    //Unpause action
    func runPauseAction()
    {
        physicsWorld.speed = 0.0
        self.view?.paused = true
    }
}
