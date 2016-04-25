import SpriteKit


class HomeScene: SKScene, SKPhysicsContactDelegate
{
    var player = PlayerNode()                   //Player
    var lastUpdateTime: NSTimeInterval = 0      //
    var dt: CGFloat = 0                         //delta time
    var totalTime = CGFloat(0)                  //Total time that has passed
    
    var circleIndic = SKShapeNode()     //Indicator of current touch location
    
    var fireRate = CGFloat(0.2)         //Fire rate
    var fireRateCounter = CGFloat(0.0)  //Fire rate counter
    
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
            ring.alpha = 1.0
            addChild(ring)
        }
        
        let ring3 = SKSpriteNode(texture: SKTexture(imageNamed: "ring_comp"))
        ring3.name = "ring3"
        ring3.position = center
        ring3.size = CGSize(width: 768, height: 768)
        ring3.alpha = 0
        addChild(ring3)
        
        //DMTS all children in scene
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
    
    //Start a new game
    func newGame()
    {
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        view!.presentScene(GameScene.getLevel(1)!, transition: reveal)
    }
    
    //Add a projectile to the scene
    func addProjectile(position: CGPoint)
    {
        let projectile = ProjectileNode(position: position)
        self.addChild(projectile)
        projectile.didMoveToScene()
    }
}