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

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var currentLevel: Int = 0
    var lastUpdateTime: NSTimeInterval = 0
    var dt: CGFloat = 0
    var mainCircle: EscapeNode!
    
    override func didMoveToView(view: SKView)
    {
        let maxAspectRatio: CGFloat = 4.0/3.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        let playableRect = CGRect(
            x: 0,
            y: playableMargin,
            width: size.width,
            height: size.height-playableMargin *  2)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.didMoveToScene()
            }
        })
        
        mainCircle = childNodeWithName("circle_m") as! EscapeNode
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
    }
    
    //Triggers when a collision occurs
    func didBeginContact(contact: SKPhysicsContact)
    {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Proj | PhysicsCategory.Junk
        {

        }
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
}
