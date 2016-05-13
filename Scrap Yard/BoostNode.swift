import SpriteKit

//Booster for enemies.
class BoostNode: SKSpriteNode
{
    //Init
    init()
    {
        super.init(
            texture: SKTexture(imageNamed: "triangle"),
            color: UIColor(),
            size: CGSize(width: 100, height: 50))
        self.zPosition = 4
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
