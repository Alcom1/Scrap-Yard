import SpriteKit

class ProjectileNode: SKSpriteNode, CustomNodeEvents
{
    var disabled = false;   //True after being disabled
    
    //Init
    init(position: CGPoint)
    {
        super.init(
            texture: SKTexture(imageNamed: "missile"),
            color: UIColor(),
            size: CGSize(width: 30, height: 30))
        self.position = (position - center).normalized() * 310 + center
        self.zRotation = (position - center).angle
        let fire = SKEmitterNode(fileNamed: "fire")
        fire!.zPosition = -1
        self.addChild(fire!)
        
        //Physics
        physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 20))
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = 0.3
        
        //Masks
        physicsBody!.categoryBitMask = PhysicsCategory.Proj
        physicsBody!.collisionBitMask = PhysicsCategory.Junk
        physicsBody!.contactTestBitMask = PhysicsCategory.Junk | PhysicsCategory.Edge
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //DMTS
    func didMoveToScene()
    {
        physicsBody!.applyImpulse(
            CGVector(
                dx: -50 * cos(self.zRotation),
                dy: -50 * sin(self.zRotation)))
    }
    
    //Update
    func update(dt: CGFloat)
    {

    }
    
    //Return if the projectile is disabled from impact
    func isDisabled() -> Bool
    {
        return disabled
    }
}
