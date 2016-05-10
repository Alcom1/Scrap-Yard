import SpriteKit

//Actively escaping ball of trash object
class FollowNode: SKSpriteNode, CustomNodeEvents, EscapeEvents, FollowEvents
{
    var active = true;      //If is active and moving
    var escape = false;     //If has escaped
    var target = CGPoint(x: 385, y: 512)    //Target position that the follow node follows.
    
    //DMTS
    func didMoveToScene()
    {
        //circle boundary, no gravity, mass scales with size
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.427)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = π * size.width * size.width / 160000
        
        //Masks
        physicsBody!.categoryBitMask = PhysicsCategory.Junk
        physicsBody!.collisionBitMask = PhysicsCategory.Junk
    }
    
    //Update
    func update(dt: CGFloat)
    {
        if(active)
        {
            //Boost speed
            if(escape)
            {
                physicsBody!.applyImpulse(
                    ((target - position).normalized() * 1800 * physicsBody!.mass * dt).toCGVector())
            }
                
            //Normal speed
            else
            {
                physicsBody!.applyImpulse(
                    ((target - position).normalized() * 20 * physicsBody!.mass * dt).toCGVector())
            }
        }
    }
    
    //set the target of the follow node
    func setTarget(pos: CGPoint)
    {
        target = pos
    }
    
    //Return if the escaper escaped
    func isOut() -> Bool
    {
        return (position - center).length() > 345 - size.width / 2
    }
    
    //True if has escaped
    func hasEscaped() -> Bool
    {
        return escape
    }
    
    //Set boost for super speedy escape
    func boost()
    {
        escape = true;
    }
}
