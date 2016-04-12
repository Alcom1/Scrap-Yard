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
    var lastUpdateTime: NSTimeInterval = 0
    var dt: CGFloat = 0
    
    override func didMoveToView(view: SKView)
    {
        /*let maxAspectRatio: CGFloat = 4.0/3.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        let playableArea = CGRect(
            x: 0,
            y: playableMargin,
            width: size.width,
            height: size.height-playableMargin *  2)*/
        physicsBody = SKPhysicsBody(edgeLoopFromPath: polygonPath(
            512,
            y: 384,
            radius: 350,
            sides: 40))
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.didMoveToScene()
            }
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.locationInNode(self)
            addProjectile(location)
        }
    }
   
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
        
        //Check Positions of escapers
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
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        print(collision)
        
        if collision == PhysicsCategory.Proj | PhysicsCategory.Junk
        {
            if(contact.bodyA.categoryBitMask == PhysicsCategory.Proj)
            {
                (contact.bodyA.node as! ProjectileNode).disabled = true;
            }
            else
            {
                (contact.bodyB.node as! ProjectileNode).disabled = true;
            }
        }
    }
    
    //Start a new game.
    func newGame()
    {
        view!.presentScene(GameScene.getLevel(currentLevel))
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
