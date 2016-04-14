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
    var currentLevel: Int = 0
    var player = PlayerNode()
    var lastUpdateTime: NSTimeInterval = 0
    var dt: CGFloat = 0
    var totalTime = CGFloat(0)
    
    var rectTime = SKShapeNode()
    var circleIndic = SKShapeNode()
    
    override func didMoveToView(view: SKView)
    {
        physicsBody = SKPhysicsBody(edgeLoopFromPath: polygonPath(
            384,
            y: 512,
            radius: 350,
            sides: 40))
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        addChild(player)
        
        rectTime = SKShapeNode(
            rect: CGRect(
                origin: CGPoint(x: 300, y: 0),
                size: CGSize(
                    width: 600.0,
                    height: 35.0)))
        rectTime.name = "rectTime"
        rectTime.position = CGPoint(x : 0, y : 950)
        rectTime.fillColor = SKColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
        rectTime.strokeColor = SKColor.clearColor()
        addChild(rectTime)
        
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.didMoveToScene()
            }
        })
    }
    
    //
    override func touchesBegan          (touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.locationInNode(self)
            player.setPosAndRot(location)
        }
    }
    
    //
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.locationInNode(self)
            player.setPosAndRot(location)
        }
    }
    
    //
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        addProjectile(player.position)
        player.targetAngle = player.currentAngle
    }
   
    //
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
        
        totalTime += dt
        
        if(totalTime > 20.0)
        {
            currentLevel++
            if(currentLevel > levelCount)
            {
                currentLevel = 1
            }
            newGame()
        }
        
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
                    self.newGame()
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
        let bodyA = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyA : contact.bodyB
        let bodyB = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyB : contact.bodyA
        
        let collision = bodyA.categoryBitMask | bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Proj | PhysicsCategory.Junk
        {
            (bodyB.node as! ProjectileNode).disabled = true;
        }
        
        if collision == PhysicsCategory.Proj | PhysicsCategory.Edge
        {
            (bodyB.node as! ProjectileNode).disabled = true;
        }
    }
    
    //Start a new game.
    func newGame()
    {
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        view!.presentScene(GameScene.getLevel(currentLevel)!, transition: reveal)
    }
    
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
