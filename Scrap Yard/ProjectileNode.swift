import SpriteKit

class ProjectileNode: SKSpriteNode, CustomNodeEvents
{
    init(position: CGPoint)
    {
        super.init(
            texture: SKTexture(imageNamed: "circle"),
            color: UIColor(),
            size: CGSize(width: 34, height: 34))
        let center = CGPoint(x: 512, y: 384)
        self.position = (position - center).normalized() * 350 + center
        self.zRotation = (position - center).angle
        print(self.zRotation.toDegrees())
        physicsBody = SKPhysicsBody(circleOfRadius: 17)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = 0.2
        
        physicsBody!.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Junk
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
}
