import SpriteKit

class EscapeNode: SKSpriteNode, CustomNodeEvents
{
    func didMoveToScene()
    {
        
    }
    
    func update(dt: CGFloat)
    {
        physicsBody!.applyImpulse(CGVector(dx: -25 * dt, dy: -25 * dt))
    }
}
