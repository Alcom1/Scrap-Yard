import SpriteKit

struct PhysicsCategory
{
    static let None: UInt32 = 0
    static let Edge: UInt32 = 0b1
    static let Junk: UInt32 = 0b10
    static let Proj: UInt32 = 0b100
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

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var gameManager:GameViewController?
    var currentLevel: Int = 0                   //Current level
    var player = PlayerNode()                   //Player
    var circles = [
        SKShapeNode(circleOfRadius: 25),
        SKShapeNode(circleOfRadius: 25),
        SKShapeNode(circleOfRadius: 25)]
    var lastUpdateTime: NSTimeInterval = 0      //
    var dt: CGFloat = 0                         //delta time
    var totalTime = CGFloat(0)                  //Total time that has passed
    
    var rectTime = SKShapeNode()        //Bar indicating remaining time
    var circleIndic = SKShapeNode()     //Indicator of current touch location
    
    var fireRate = CGFloat(0.2)         //Fire rate
    var fireRateCounter = CGFloat(0.0)  //Fire rate counter
    
    var losesCur = 0
    var losesMax = 0
    
    var end = false                     //If level has ended
    var releaseStop = true              //If the player stops moving when touch ends
    var pauseFix = false                //Hax bool to prevent massive jump after unpausing.
    
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
        circleIndic.fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        circleIndic.strokeColor = SKColor.clearColor()
        circleIndic.hidden = true
        addChild(circleIndic)
        
        //Yellow circles
        for (var i = 0; i < 3; i++)
        {
            circles[i].position = CGPoint(x: 725, y: 150 - i * 55)
            circles[i].fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.9)
            circles[i].strokeColor = SKColor.clearColor()
            addChild(circles[i])
        }
        
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
            //ring.runAction(SKAction.fadeAlphaTo(0.75, duration: 20.0))    //This breaks subsequent actions
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
        
        //Max number of allowed loses
        losesMax = levelLoses[currentLevel - 1]
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
        }
        
        //Update all objects
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.update(self.dt)
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
                    self.circles[self.losesCur].hidden = true
                    self.losesCur++
                    if(self.losesCur >= self.losesMax)
                    {
                        self.lose()
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
        
        //No stars display
        for (var i = 0; i < 3; i++)
        {
            circles[i].hidden = true
        }
        
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
        
        //Save stars
        NSUserDefaults.standardUserDefaults().setInteger(3 - self.losesCur, forKey: "level\(currentLevel)_stars")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        currentLevel++
        
        setContainmentLabel("Containment: Sucessful!", color: SKColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0))
        
        //Wait and reset level
        let wait = SKAction.waitForDuration(1.5)
        let newGame = SKAction.runBlock({self.newGame(true)})
        runAction(SKAction.sequence([wait, newGame]))
        
        enumerateChildNodesWithName( "ring3", usingBlock:
        { node, _ in
            node.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.05))
        })
        
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
