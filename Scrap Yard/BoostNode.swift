import SpriteKit

//Passive junk ball object
class BoostNode: SKSpriteNode, CustomNodeEvents
{
    //Init
    init()
    {
        super.init(
            texture: SKTexture(imageNamed: "player"),
            color: UIColor(),
            size: CGSize(width: 100, height: 130))
        
        self.position = center + CGPoint(x: 0, y: 340)
        self.zPosition = 10
        self.zRotation = (self.position - center).angle
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
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
