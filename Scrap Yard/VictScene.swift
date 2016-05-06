import SpriteKit


class VictScene: SKScene, SKPhysicsContactDelegate
{
    var gameManager:GameViewController?
    var lastUpdateTime: NSTimeInterval = 0      //
    var dt: CGFloat = 0                         //delta time
    var totalTime = CGFloat(0)                  //Total time that has passed
    
    var releaseStop = true              //If the player stops moving when touch ends
    
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
        
        //DMTS all children in scene and set fonts
        enumerateChildNodesWithName( "//*", usingBlock:
        { node, _ in
            if let customNode = node as? CustomNodeEvents
            {
                customNode.didMoveToScene()
            }
        })
    }
    
    //Touches began
    override func touchesBegan          (touches: Set<UITouch>, withEvent event: UIEvent?)
    {

    }
    
    //Touches moved
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {

    }
    
    //Touches ended
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        newGame()
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
        
        totalTime += dt
        if(totalTime > 5)
        {
            newGame()
        }
        
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
    }
    
    //Triggers when a collision occurs
    func didBeginContact(contact: SKPhysicsContact)
    {

    }
    
    //Start a new game
    func newGame()
    {
        gameManager!.loadHomeScene(releaseStop)
    }
}
