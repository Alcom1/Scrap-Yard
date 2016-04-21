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
    func boost()
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var currentLevel: Int = 0                   //Current level
    var player = PlayerNode()                   //Player
    var lastUpdateTime: NSTimeInterval = 0      //
    var dt: CGFloat = 0                         //delta time
    var totalTime = CGFloat(0)                  //Total time that has passed
    
    var rectTime = SKShapeNode()        //Bar indicating remaining time
    var circleIndic = SKShapeNode()     //Indicator of current touch location
    
    var fireRate = CGFloat(0.2)         //Fire rate
    var fireRateCounter = CGFloat(0.0)  //Fire rate counter
    var tutorialWait = false            //If waiting in tutorial
    var loss = false
    
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
                origin: CGPoint(x: 300, y: 0),
                size: CGSize(
                    width: 600.0,
                    height: 35.0)))
        rectTime.name = "rectTime"
        rectTime.zPosition = -5
        rectTime.position = CGPoint(x : 0, y : 950)
        rectTime.fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
        rectTime.strokeColor = SKColor.clearColor()
        addChild(rectTime)
        
        //Circle indicator
        circleIndic = SKShapeNode(circleOfRadius: 25.0)
        circleIndic.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 500)
        circleIndic.fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        circleIndic.strokeColor = SKColor.clearColor()
        circleIndic.hidden = true
        addChild(circleIndic)
        
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
        
        //DMTS all children in scene
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.didMoveToScene()
            }
        })
        
        //Set tutorial for level 1
        if(currentLevel == 1)
        {
            tutorialWait = true
            
            enumerateChildNodesWithName( "escaper", usingBlock:
            { node, _ in
                if let customNode = node as? EscapeNode
                {
                    customNode.active = false
                }
            })
        }
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
        
        //End tutoral wait
        if(currentLevel == 1)
        {
            tutorialWait = false
            enumerateChildNodesWithName( "escaper", usingBlock:
            { node, _ in
                if let customNode = node as? EscapeNode
                {
                    customNode.active = true
                }
            })
        }
        
        //Hide circle and stop player
        circleIndic.hidden = true
        player.targetAngle = player.currentAngle
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
        
        //Don't update totalTime if waiting on tutorial
        if(!tutorialWait && !loss)
        {
            totalTime += dt
        }
        
        //fireRate update
        fireRateCounter -= dt
        
        //Victory after 20s
        if(totalTime > 20.0)
        {
            currentLevel++
            if(currentLevel > levelCount)
            {
                currentLevel = 1
            }
            newGame()
        }
        
        //resize time bar
        rectTime.xScale = (20 - totalTime) / 20
        rectTime.position.x = 384 - 600 * (20 - totalTime) / 20
        
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
                if(customNode.isOut())
                {
                    self.lose()
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
        }
    }
    
    //Lose
    func lose()
    {
        loss = true
        rectTime.fillColor = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
        
        let wait = SKAction.waitForDuration(2.0)
        let newGame = SKAction.runBlock({self.newGame()})
        runAction(SKAction.sequence([wait, newGame]))
        
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
        
        enumerateChildNodesWithName( "escaper", usingBlock:
        { node, _ in
            if let customNode = node as? EscapeNode
            {
                customNode.boost()
            }
        })
        
        physicsBody!.categoryBitMask = PhysicsCategory.None
    }
    
    //Win
    func win()
    {
        
    }
    
    //Start a new game
    func newGame()
    {
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        view!.presentScene(GameScene.getLevel(currentLevel)!, transition: reveal)
    }
    
    //Add a projectile to the scene
    func addProjectile(position: CGPoint)
    {
        let projectile = ProjectileNode(position: position)
        self.addChild(projectile)
        projectile.didMoveToScene()
    }
    
    //Static function that instantiates a scene of a given level number.
    class func getLevel(levelNum: Int) -> GameScene?
    {
        let scene = GameScene(fileNamed: "Level_\(levelNum)")!
        scene.currentLevel = levelNum
        scene.scaleMode = .AspectFill
        return scene
    }
    
    //Generate an array of points arranged in a circle
    func polygonPointArray(
        sides: Int,
        x: CGFloat,
        y: CGFloat,
        radius: CGFloat) -> [CGPoint]
    {
        
        var points = [CGPoint]()
        for(var i = 0; i < sides; i++)
        {
            points.append(
                CGPoint(
                    x: x + radius * cos(2.0 * π * CGFloat(i) / CGFloat(sides)),
                    y: y + radius * sin(2.0 * π * CGFloat(i) / CGFloat(sides))))
        }
        return points
    }
    
    //Generate a path of a regular polygon
    func polygonPath(x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int) -> CGPathRef
    {
        let path = CGPathCreateMutable()
        let points = polygonPointArray(sides, x: x, y: y, radius: radius)
        let cpg = points[0]
        CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
        for p in points
        {
            CGPathAddLineToPoint(path, nil, p.x, p.y)
        }
        CGPathCloseSubpath(path)
        return path
    }
}
