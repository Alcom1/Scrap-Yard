import SpriteKit

class EscapeNode: SKSpriteNode, CustomNodeEvents, EscapeEvents
{
    var escape = false;
    
    func didMoveToScene()
    {
        
    }
    
    func update(dt: CGFloat)
    {
        physicsBody!.applyImpulse(CGVector(dx: -25 * dt, dy: -25 * dt))
    }
    
    func isOut() -> Bool
    {
        return (position - center).length() > 345 - size.width / 2
    }
    
    func boost()
    {
        
    }
}
