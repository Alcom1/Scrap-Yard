import SpriteKit

class ProjectileNode: SKSpriteNode, CustomNodeEvents
{
    init(position: CGPoint)
    {
        super.init(
            texture: SKTexture(imageNamed: "circle"),
            color: UIColor(),
            size: CGSize(width: 50, height: 50))
        self.position = position
        physicsBody = SKPhysicsBody(circleOfRadius: 25)
        physicsBody!.applyImpulse(CGVector(dx: 25, dy: 0))
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didMoveToScene()
    {
        
    }
    
    func update(dt: CGFloat)
    {

    }
}
