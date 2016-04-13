import SpriteKit

class JunkNode: SKSpriteNode, CustomNodeEvents
{
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
        
    }
}
