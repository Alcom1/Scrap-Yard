import SpriteKit

//Actively escaping ball of trash object
class FollowNode: SKSpriteNode, CustomNodeEvents, EscapeEvents, FollowEvents
{
    var active = true;      //If is active and moving
    var escape = false;     //If has escaped
    var target = CGPoint(x: 385, y: 512)    //Target position that the follow node follows.
    var booster = BoostNode()    //Booster that displays
    
    //DMTS
    func didMoveToScene()
    {
        //circle boundary, no gravity, mass scales with size
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.427)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = π * size.width * size.width / 160000
        
        //Masks
        physicsBody!.categoryBitMask = PhysicsCategory.Foll
        physicsBody!.collisionBitMask = PhysicsCategory.Junk
        
        //Booster
        booster.xScale = size.width / 200
        booster.yScale = size.height / 200
        addChild(booster)
    }
    
    //Update
    func update(dt: CGFloat)
    {
        if(active)
        {
            //Boost speed
            if(escape)
            {
                booster.setAngle((position - center).normalized().angle - zRotation)
                physicsBody!.applyImpulse(
                    ((position - center).normalized() * 1800 * physicsBody!.mass * dt).toCGVector())
            }
                
            //Normal speed
            else
            {
                booster.setAngle((target - position).normalized().angle - zRotation)
                physicsBody!.applyImpulse(
                    ((target - position).normalized() * 120 * physicsBody!.mass * dt).toCGVector())
                
                //Limit velocity of follower enemy
                if(physicsBody!.velocity.length() > 60)
                {
                    physicsBody!.velocity = physicsBody!.velocity.normalized() * 60
                }
            }
        }
    }
    
    //set the target of the follow node
    func setFollowTarget(pos: CGPoint)
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
