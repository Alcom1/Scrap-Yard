import SpriteKit

struct PhysicsCategory
{
    static let None: UInt32 = 0
    static let Edge: UInt32 = 0b1
    static let Junk: UInt32 = 0b10
}


protocol CustomNodeEvents
{
    func didMoveToScene()
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var currentLevel: Int = 0
    
    override func didMoveToView(view: SKView)
    {
        let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5
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
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
       /* Called when a touch begins */
        
        for touch in touches
        {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
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
