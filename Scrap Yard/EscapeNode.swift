import SpriteKit

class EscapeNode: SKSpriteNode, CustomNodeEvents, EscapeEvents
{
    var escape = false;
    
    func didMoveToScene()
    {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.427)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = π * size.width * size.width / 160000
        
        physicsBody!.categoryBitMask = PhysicsCategory.Junk
        physicsBody!.collisionBitMask = PhysicsCategory.Junk | PhysicsCategory.Edge | PhysicsCategory.Proj
    }
    
    func update(dt: CGFloat)
    {
        physicsBody!.applyImpulse(((position - center).normalized() * 20 * physicsBody!.mass * dt).toCGVector())
    }
    
    func isOut() -> Bool
    {
        return (position - center).length() > 345 - size.width / 2
    }
    
    func boost()
    {
        
    }
}
