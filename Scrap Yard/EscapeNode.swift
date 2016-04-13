import SpriteKit

class EscapeNode: SKSpriteNode, CustomNodeEvents, EscapeEvents
{
    var escape = false;
    
    func didMoveToScene()
    {
        
    }
    
    func update(dt: CGFloat)
    {
        physicsBody!.applyImpulse(((position - center).normalized() * 3 * dt).toCGVector())
    }
    
    func isOut() -> Bool
    {
        return (position - center).length() > 345 - size.width / 2
    }
    
    func boost()
    {
        
    }
}
