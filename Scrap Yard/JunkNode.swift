import SpriteKit

//Passive junk ball object
class JunkNode: SKSpriteNode, CustomNodeEvents
{
    //DMTS
    func didMoveToScene()
    {
        //circle boundary, no gravity, mass scales with size
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.427)
        physicsBody!.affectedByGravity = false;
        physicsBody!.mass = π * size.width * size.width / 160000
        
        //Masks
        physicsBody!.categoryBitMask = PhysicsCategory.Junk
        physicsBody!.collisionBitMask = PhysicsCategory.Junk | PhysicsCategory.Edge | PhysicsCategory.Proj | PhysicsCategory.Foll
    }
    
    //Update
    func update(dt: CGFloat)
    {
        
    }
}
