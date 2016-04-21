import SpriteKit

//Actively escaping ball of trash object
class EscapeNode: SKSpriteNode, CustomNodeEvents, EscapeEvents
{
    var active = true;      //If is active and moving
    var escape = false;     //If has escaped
    
    //DMTS
    func didMoveToScene()
    {
        //circle boundary, no gravity, mass scales with size
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.427)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = π * size.width * size.width / 160000
        
        //Masks
        physicsBody!.categoryBitMask = PhysicsCategory.Junk
        physicsBody!.collisionBitMask = PhysicsCategory.Junk | PhysicsCategory.Edge | PhysicsCategory.Proj
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
                    ((position - center).normalized() * 400 * physicsBody!.mass * dt).toCGVector())
            }
                
            //Normal speed
            else
            {
                physicsBody!.applyImpulse(
                    ((position - center).normalized() * 20 * physicsBody!.mass * dt).toCGVector())
            }
        }
    }
    
    //Return if the escaper escaped
    func isOut() -> Bool
    {
        return (position - center).length() > 345 - size.width / 2
    }
    
    //Set boost for super speedy escape
    func boost()
    {
        escape = true;
    }
}
