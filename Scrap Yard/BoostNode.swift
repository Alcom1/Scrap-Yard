import SpriteKit

//Booster for enemies.
class BoostNode: SKSpriteNode
{
    //Init
    init()
    {
        super.init(
            texture: SKTexture(imageNamed: "engine"),
            color: UIColor(),
            size: CGSize(width: 100, height: 50))
        self.zPosition = 4
        let fire = SKEmitterNode(fileNamed: "fire_big")
        fire!.position = CGPoint(x: -30, y: 0)
        fire!.xScale = 1.25
        fire!.yScale = 1.25
        fire!.zPosition = -1
        fire!.zRotation -= π
        self.addChild(fire!)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAngle(angle: CGFloat)
    {
        self.zRotation = angle;
    }
}
