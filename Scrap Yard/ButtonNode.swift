import SpriteKit

//Actively escaping ball of trash object
class ButtonNode: SKSpriteNode, CustomNodeEvents
{
    //DMTS
    func didMoveToScene()
    {
        //circle boundary, no gravity, mass scales with size
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.427)
        physicsBody!.dynamic = false
        
        //Masks
        physicsBody!.categoryBitMask = PhysicsCategory.Junk
    }
    
    //Update
    func update(dt: CGFloat)
    {

    }
}
