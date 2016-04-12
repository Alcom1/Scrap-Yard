import SpriteKit

class ProjectileNode: SKSpriteNode, CustomNodeEvents
{
    var disabled = false;
    
    init(position: CGPoint)
    {
        super.init(
            texture: SKTexture(imageNamed: "circle"),
            color: UIColor(),
            size: CGSize(width: 20, height: 20))
        let center = CGPoint(x: 512, y: 384)
        self.position = (position - center).normalized() * 340 + center
        self.zRotation = (position - center).angle
        print(self.zRotation.toDegrees())
        physicsBody = SKPhysicsBody(circleOfRadius: 17)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = 0.3
        
        physicsBody!.categoryBitMask = PhysicsCategory.Proj
        physicsBody!.collisionBitMask = PhysicsCategory.Junk
        physicsBody!.contactTestBitMask = PhysicsCategory.Junk | PhysicsCategory.Edge
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didMoveToScene()
    {
        physicsBody!.applyImpulse(
            CGVector(
                dx: -50 * cos(self.zRotation),
                dy: -50 * sin(self.zRotation)))
    }
    
    func update(dt: CGFloat)
    {

    }
    
    func isDisabled() -> Bool
    {
        return disabled
    }
}
